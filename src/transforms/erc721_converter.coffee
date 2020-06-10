{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"
astBuilder = require "../ast_builder"

# Approximate correspondance of ERC721 to FA2 token interface

# @notice Count all NFTs assigned to an owner
# @dev NFTs assigned to the zero address are considered invalid, and this
#  function throws for queries about the zero address.
# @param _owner An address for whom to query the balance
# @return The number of NFTs owned by `_owner`, possibly zero


# function balanceOf(address _owner) external view returns (uint256); -> Balance_of(record [requests = list [ record [owner = arg[0], token_id = callee] ], callback = Tezos.self(%callback))

# @notice Find the owner of an NFT
# @dev NFTs assigned to zero address are considered invalid, and queries
#  about them do throw.
# @param _tokenId The identifier for an NFT
# @return The address of the owner of the NFT
# function ownerOf(uint256 _tokenId) external view returns (address);
# Is_operator(record [ owner = arg[0], operator = Tezos.sender, callback = self("%is_operator_callback")

# @notice Transfers the ownership of an NFT from one address to another address
# @dev Throws unless `msg.sender` is the current owner, an authorized
#  operator, or the approved address for this NFT. Throws if `_from` is
#  not the current owner. Throws if `_to` is the zero address. Throws if
#  `_tokenId` is not a valid NFT. When transfer is complete, this function
#  checks if `_to` is a smart contract (code size > 0). If so, it calls
#  `onERC721Received` on `_to` and throws if the return value is not
#  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
# @param _from The current owner of the NFT
# @param _to The new owner
# @param _tokenId The NFT to transfer
# @param data Additional data with no specified format, sent in call to `_to`
# function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;

# @notice Transfers the ownership of an NFT from one address to another address
# @dev This works identically to the other function with an extra data parameter,
#  except this function just sets data to "".
# @param _from The current owner of the NFT
# @param _to The new owner
# @param _tokenId The NFT to transfer
# function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

# @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
#  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
#  THEY MAY BE PERMANENTLY LOST
# @dev Throws unless `msg.sender` is the current owner, an authorized
#  operator, or the approved address for this NFT. Throws if `_from` is
#  not the current owner. Throws if `_to` is the zero address. Throws if
#  `_tokenId` is not a valid NFT.
# @param _from The current owner of the NFT
# @param _to The new owner
# @param _tokenId The NFT to transfer
# function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
# Transfer( list [ record [ from_ = arg[0], txs = list [ record [ to_ = arg[1], token_id = arg[2], amount = 1n ] ] ] ])

# @notice Change or reaffirm the approved address for an NFT
# @dev The zero address indicates there is no approved address.
#  Throws unless `msg.sender` is the current NFT owner, or an authorized
#  operator of the current owner.
# @param _approved The new approved NFT controller
# @param _tokenId The NFT to approve
# function approve(address _approved, uint256 _tokenId) external payable;

# @notice Enable or disable approval for a third party ("operator") to manage
#  all of `msg.sender`'s assets
# @dev Emits the ApprovalForAll event. The contract MUST allow
#  multiple operators per owner.
# @param _operator Address to add to the set of authorized operators
# @param _approved True if the operator is approved, false to revoke approval
# function setApprovalForAll(address _operator, bool _approved) external;

# @notice Get the approved address for a single NFT
# @dev Throws if `_tokenId` is not a valid NFT.
# @param _tokenId The NFT to find the approved address for
# @return The approved address for this NFT, or the zero address if there is none
# function getApproved(uint256 _tokenId) external view returns (address);

# @notice Query if an address is an authorized operator for another address
# @param _owner The address that owns the NFTs
# @param _operator The address that acts on behalf of the owner
# @return True if `_operator` is an approved operator for `_owner`, false otherwise
# function isApprovedForAll(address _owner, address _operator) external view returns (bool);

callback_declaration = (name, arg_type) ->
  cb_decl = new ast.Fn_decl_multiret
  cb_decl.name = name + "Callback"
  
  cb_decl.type_i = new Type "function"
  cb_decl.type_o =  new Type "function"
  
  cb_decl.arg_name_list.push "arg"
  cb_decl.type_i.nest_list.push arg_type

  hint = new ast.Comment
  hint.text = "This method should handle return value of #{name} of foreign contract"
  cb_decl.scope.list.push hint
  return cb_decl

tx_node = (address_expr, arg_list, name, ctx) ->
  entrypoint = astBuilder.foreign_entrypoint(address_expr, name)
  tx = astBuilder.transaction(arg_list, entrypoint)
  return tx

callback_tx_node = (name, root, ctx) ->
  cb_name = name + "Callback"
  return_callback = astBuilder.self_entrypoint("%" + cb_name)

  if not ctx.callbacks_to_declare.hasOwnProperty cb_name
    # TODO why are we using nest_list of nest_list?
    return_type = root.fn.type.nest_list[ast.RETURN_VALUES].nest_list[ast.INPUT_ARGS]
    cb_decl = callback_declaration(name, return_type)
    ctx.callbacks_to_declare[cb_name] = cb_decl

  arg_list = root.arg_list
  arg_list.push return_callback
  address_expr = root.fn.t
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
      ctx.callbacks_to_declare = {}
      root = ctx.next_gen root, ctx
      for name, decl of ctx.callbacks_to_declare
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

                tx = new ast.Struct_init
                tx.arg_names = ["to_", "token_id", "amount"]
                tx.val_list =  [args[1], args[2], astBuilder.nat_literal(1)]
                
                txs = new ast.Array_init
                txs.type = new Type "built_in_op_list"
                txs.list = [tx]

                arg_record = new ast.Struct_init
                arg_record.arg_names = ["from_", "txs",]
                arg_record.val_list = [args[0], astBuilder.list_init([tx])]
                
                arg_list_obj = astBuilder.list_init([arg_record])


                return tx_node(root.fn.t, [arg_list_obj], "Transferie", ctx)
              when "approve"
                return tx_node(root.fn.t, root.arg_list, "Approve", ctx)
              when "transferFrom"
                return tx_node(root.fn.t, root.arg_list, "Transfer", ctx)

      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx


@erc721_converter = (root, ctx)-> 
  walk root, ctx = obj_merge({walk, next_gen: default_walk}, ctx)