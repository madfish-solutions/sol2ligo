{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"
astBuilder = require "../ast_builder"

# Approximate correspondance of ERC721 to FA2 token interface

# function balanceOf(address _owner) external view returns (uint256); -> Balance_of(record [requests = list [ record [owner = arg[0], token_id = callee] ], callback = Tezos.self(%callback))
# function ownerOf(uint256 _tokenId) external view returns (address); ->?Balance_of(record [ owner = arg[0], operator = Tezos.sender, callback = self("%is_operator_callback")

# function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable; -> ???
# function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable; -> ???

# function transferFrom(address _from, address _to, uint256 _tokenId) external payable; -> Transfer( list [ record [ from_ = arg[0], txs = list [ record [ to_ = arg[1], token_id = arg[2], amount = 1n ] ] ] ])
# function approve(address _approved, uint256 _tokenId) external payable; -> Update_operators(list [ AddOperator( record [ owner = Tezos.sender, operator = arg[0] ] ) ]
# function setApprovalForAll(address _operator, bool _approved) external; -> Update_operators(list [ AddOperator( record [ owner = Tezos.sender, operator = arg[0] ] ) ]
# function getApproved(uint256 _tokenId) external view returns (address); -> ???
# function isApprovedForAll(address _owner, address _operator) external view returns (bool); -> Is_operator(record [ operator = record [ owner = arg[0], operator = arg[1] ], callback = Tezos.self("%is_operator_callback") ])

declare_callback = (name, arg_type, ctx) ->
  if not ctx.callbacks_to_declare_map.has name
    # TODO why are we using nest_list of nest_list?
    cb_decl = astBuilder.callback_declaration(name, arg_type)
    ctx.callbacks_to_declare_map.set name, cb_decl # no "Callback" suffix for key

tx_node = (address_expr, arg_list, ctx) ->
  address_expr = astBuilder.contract_addr_transform address_expr
  entrypoint = astBuilder.foreign_entrypoint(address_expr, "fa2_entry_points")
  tx = astBuilder.transaction(arg_list, entrypoint)
  return tx

walk = (root, ctx)->
  switch root.constructor.name
    when "Class_decl"
      # collect callback declaration dummies
      ctx.callbacks_to_declare_map = new Map
      root = ctx.next_gen root, ctx
      ctx.callbacks_to_declare_map.forEach (decl)->
        root.scope.list.unshift decl
      return root

    when "Var_decl"
      if root.type?.main == ctx.interface_name 
        root.type = new Type "address"
      ctx.next_gen root, ctx

    when "Fn_decl_multiret"
      ctx.current_scope_ops_count = 0
      ctx.next_gen root, ctx

    when "Fn_call"
      # replace constructor
      if root.fn.name == ctx.interface_name
        return astBuilder.cast_to_address(root.arg_list[0])
        
      # search for interface methods
      if root.fn.t?.type
        switch root.fn.t.type.main
          when "struct", ctx.interface_name
            switch root.fn.name
              when "transferFrom", \
                   "safeTransferFrom"
                args = root.arg_list

                dst = new ast.Tuple
                dst.list.push astBuilder.cast_to_address args[1] # to
                dst.list.push astBuilder.nat_literal(1) # amount always 1 because nft

                token_and_dst = new ast.Tuple
                token_and_dst.list.push args[2] # token_id
                token_and_dst.list.push dst

                transfer = new ast.Tuple
                transfer.list.push astBuilder.list_init [token_and_dst] # txs
                transfer.list.push astBuilder.cast_to_address args[0] # from

                transfers = astBuilder.list_init([transfer])

                call = astBuilder.enum_val("@Transfer", [transfers])

                tx = tx_node(root.fn.t, [call], ctx)

                if root.fn.name == "safeTransferFrom"
                  block = new ast.Scope
                  block.need_nest = false
                  block.list.push root
                  block.list.push comment = new ast.Comment
                  comment.text = "^ #{root.fn.name} is not supported in LIGO. Read more https://git.io/JJFij ^"
                  return block
                else
                  return tx
              when "balanceOf"
                name = "Balance_of"
                args = root.arg_list

                param = new ast.Tuple

                # DOC there is no direct translation of this call to FA2
                # Solidity asks how many tokens address possesses
                # LIGO must specify token ID, which means only balance of one type of token can be retrieved 
                param.list.push astBuilder.nat_literal(0)  # token_id
                param.list.push astBuilder.cast_to_address args[0] # owner
                
                arg_type = new Type "list<>"
                arg_type.nest_list[0] = new Type "@balance_of_response_michelson"

                contract_type = new Type "contract"
                contract_type.nest_list.push(arg_type)

                request = new ast.Tuple
                request.list.push astBuilder.list_init [param]
                request.list.push astBuilder.self_entrypoint "%#{name}Callback", contract_type

                declare_callback name, arg_type, ctx

                call = astBuilder.enum_val("@Balance_of", [request])
                
                return tx_node(root.fn.t, [call], ctx)
              when "approve"
                # DOC we can't set token_id in LIGO like we do in Solidity
                param = new ast.Tuple
                param.list.push astBuilder.tezos_var("sender")
                param.list.push astBuilder.cast_to_address root.arg_list[0] #_approved

                add = astBuilder.enum_val("@Add_operator", [param])
                right_comb_add = astBuilder.to_right_comb [add]
                add_list = astBuilder.list_init [right_comb_add]

                update = astBuilder.enum_val("@Update_operators", [add_list])

                return tx_node(root.fn.t, [update], ctx)
              when "setApprovalForAll"
                args = root.arg_list
                param = new ast.Tuple
                param.list.push astBuilder.tezos_var("sender")
                param.list.push astBuilder.cast_to_address root.arg_list[0] #operator

                if args[1].val == 'true'
                  action = "@Add_operator"
                else
                  action = "@Remove_operator"

                action_enum = astBuilder.enum_val(action, [param])
                right_comb_action = astBuilder.to_right_comb [action_enum]
                action_list = astBuilder.list_init [right_comb_action]
                update = astBuilder.enum_val("@Update_operators", [action_list])

                return tx_node(root.fn.t, [update], ctx)
              when "isApprovedForAll", \
                   "getApproved", \ 
                   "ownerOf"
                block = new ast.Scope
                block.need_nest = false

                block.list.push root

                block.list.push comment = new ast.Comment
                comment.text = "^ #{root.fn.name} is not supported in LIGO. Read more https://git.io/JJFij ^"

                return block
      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx


@erc721_converter = (root, ctx)-> 
  init_ctx = {
    walk,
    next_gen: default_walk,
  }
  walk root, obj_merge(init_ctx, ctx)