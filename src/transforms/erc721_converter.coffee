{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"
astBuilder = require "../ast_builder"

# Approximate correspondance of ERC721 to FA2 token interface

# function balanceOf(address _owner) external view returns (uint256); -> Balance_of(record [requests = list [ record [owner = arg[0], token_id = callee] ], callback = Tezos.self(%callback))
# function ownerOf(uint256 _tokenId) external view returns (address); ->?Balance_of(record [ owner = arg[0], operator = Tezos.sender, callback = self("%is_operator_callback")

# TODO translate the following
# function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable; -> ???
# function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable; -> ???

# function transferFrom(address _from, address _to, uint256 _tokenId) external payable; -> Transfer( list [ record [ from_ = arg[0], txs = list [ record [ to_ = arg[1], token_id = arg[2], amount = 1n ] ] ] ])
# function approve(address _approved, uint256 _tokenId) external payable; -> Update_operators(list [ AddOperator( record [ owner = Tezos.sender, operator = arg[0] ] ) ]
# function setApprovalForAll(address _operator, bool _approved) external; -> Update_operators(list [ AddOperator( record [ owner = Tezos.sender, operator = arg[0] ] ) ]
# function getApproved(uint256 _tokenId) external view returns (address); -> ???
# function isApprovedForAll(address _owner, address _operator) external view returns (bool); -> Is_operator(record [ operator = record [ owner = arg[0], operator = arg[1] ], callback = Tezos.self("%is_operator_callback") ])

declare_callback = (name, fn, ctx) ->
  if not ctx.callbacks_to_declare_map.has name
    # TODO why are we using nest_list of nest_list?
    return_type = fn.type.nest_list[ast.RETURN_VALUES].nest_list[ast.INPUT_ARGS]
    cb_decl = astBuilder.callback_declaration(name, return_type)
    ctx.callbacks_to_declare_map.set name, cb_decl # no "Callback" suffix for key

tx_node = (address_expr, arg_list, name, ctx) ->
  address_expr = astBuilder.contract_addr_transform address_expr
  entrypoint = astBuilder.foreign_entrypoint(address_expr, name)
  tx = astBuilder.transaction(arg_list, entrypoint)
  return tx

walk = (root, ctx)->
  switch root.constructor.name
    when "Class_decl"
      # ignore ERC20 interface declaration
      for entry in root.scope.list
        if entry.constructor.name == "Fn_decl_multiret"
          switch entry.name
            when "balanceOf", \
                 "ownerOf", \
                 "safeTransferFrom", \
                 "transferFrom", \
                 "approve", \
                 "setApprovalForAll", \
                 "getApproved", \
                 "isApprovedForAll"
              # replace whole class (interface) declaration if we are converting it to FA2 anyway
              ret = new ast.Include
              ret.path = "fa2.ligo"
              return ret
      
      # collect callback declaration dummies
      ctx.callbacks_to_declare_map = new Map
      root = ctx.next_gen root, ctx
      ctx.callbacks_to_declare_map.forEach (decl)->
        root.scope.list.unshift decl
      return root

    when "Fn_decl_multiret"
      ctx.current_scope_ops_count = 0
      ctx.next_gen root, ctx

    when "Fn_call"
      if root.fn.t?.type
        switch root.fn.t.type.main
          when "struct"
            switch root.fn.name
              when "transferFrom"
                args = root.arg_list

                tx = astBuilder.struct_init {
                  to_: args[1],
                  token_id: args[2],
                  amount: astBuilder.nat_literal(1)
                }
                
                arg_record = astBuilder.struct_init {
                  from_ : args[0],
                  txs :  astBuilder.list_init([tx])
                }
                
                arg_list_obj = astBuilder.list_init([arg_record])
                args = root.arg_list

                return tx_node(root.fn.t, [arg_list_obj], "Transfer", ctx)
              when "balanceOf"
                name = "Balance_of"
                args = root.arg_list
                balance_request = astBuilder.struct_init {
                  owner : args[0],
                  token_id : root.fn.t
                }
                arg_record = astBuilder.struct_init {
                  requests: astBuilder.list_init [balance_request]
                  callback : astBuilder.self_entrypoint "%#{name}Callback"
                }

                declare_callback name, root.fn, ctx
                
                return tx_node(root.fn.t, [arg_record], name, ctx)
              when "approve"
                arg_record = astBuilder.struct_init {
                  owner : astBuilder.tezos_var("sender")
                  operator : root.arg_list[0]
                }

                enum_val = astBuilder.enum_val("@Add_operator", [arg_record])

                list = astBuilder.list_init [enum_val]
                return tx_node(root.fn.t, [list], "Update_operators", ctx)
              when "setApprovalForAll"
                args = root.arg_list
                arg_record = astBuilder.struct_init {
                  owner : astBuilder.tezos_var("sender")
                  operator : args[0]
                }

                if args[1].val == 'true'
                  action = "@Add_operator"
                else
                  action = "@Remove_operator"

                enum_val = astBuilder.enum_val(action, [arg_record])             

                list = astBuilder.list_init [enum_val]
                return tx_node(root.fn.t, [list], "Update_operators", ctx)

      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx


@erc721_converter = (root, ctx)-> 
  walk root, ctx = obj_merge({walk, next_gen: default_walk}, ctx)