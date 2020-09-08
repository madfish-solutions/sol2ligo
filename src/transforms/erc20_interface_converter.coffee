{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"
astBuilder = require "../ast_builder"

# Approximate correspondance of ERC20 to FA1.2 token interface

# totalSupply() returns (uint) -> GetTotalSupply of (unit * contract(amt))
# balanceOf(address tokenOwner) returns (uint balance) -> GetBalance of (address * contract(amt))
# allowance(address tokenOwner, address spender) returns (uint remaining) -> GetAllowance of (address * address * contract(amt))
# transfer(address to, uint tokens) returns (bool success) -> Transfer of (address * address * amt)
# transferFrom(address from, address to, uint tokens) returns (bool success) -> Transfer of (address * address * amt)
# approve(address spender, uint tokens) returns (bool success) -> Approve of (address * amt)

ERC20_METHODS_TOTAL = 6

callback_tx_node = (name, root, ctx) ->
  cb_name = name.substr(0,1).toLowerCase() + name.substr(1) + "Callback"

  contract_type = new Type "contract"
  contract_type.val = "nat"
  return_callback = astBuilder.self_entrypoint("%" + cb_name, contract_type)

  if not ctx.callbacks_to_declare_map.has cb_name
    return_type = root.fn.type.nest_list[ast.RETURN_VALUES].nest_list[ast.INPUT_ARGS]
    cb_decl = astBuilder.callback_declaration name, return_type
    ctx.callbacks_to_declare_map.set cb_name, cb_decl

  arg_list = root.arg_list
  arg_list.push return_callback
  return tx_node(root.fn.t, arg_list, name, ctx)

walk = (root, ctx)->
  switch root.constructor.name
    when "Class_decl"
      erc20_methods_count = 0
      for entry in root.scope.list
        if entry.constructor.name == "Fn_decl_multiret"
          if entry.scope.list.length != 0 # only replace interfaces
            switch entry.name
              when "approve",\
                  "totalSupply",\
                  "balanceOf",\ 
                  "allowance",\ 
                  "transfer",\
                  "transferFrom"
                erc20_methods_count += 1
            
      is_erc20 = erc20_methods_count == ERC20_METHODS_TOTAL
      new_scope = []
      if is_erc20
        for entry, idx in root.scope.list
          if entry.constructor.name == "Fn_decl_multiret"
            switch entry.name
              when "approve"
                null # left the same
              when "totalSupply"
                contract_type = new Type "contract"
                contract_type.val = "nat"
                entry.type_i.nest_list.push contract_type
                entry.arg_name_list.push "callback"
                entry.name = "getTotalSupply"
                
                comment = new ast.Comment
                comment.text = "in Tezos `totalSupply` method should not return a value, but perform a transaction to the passed contract callback with a needed value"
                new_scope.push comment

              when "transferFrom"
                comment = new ast.Comment
                comment.text = "`transferFrom` and `transfer` methods should merged into one in Tezos' FA1.2"
                new_scope.push comment

              when "transfer"
                entry.type_i.nest_list.unshift new Type "address"
                entry.arg_name_list.unshift "from"

              when "balanceOf"
                contract_type = new Type "contract"
                contract_type.val = "nat"
                entry.type_i.nest_list.push contract_type
                entry.arg_name_list.push "callback"
                entry.name = "getBalance"

                comment = new ast.Comment
                comment.text = "in Tezos `balanceOf` method should not return a value, but perform a transaction to the passed contract callback with a needed value"
                new_scope.push comment

              when "allowance"
                contract_type = new Type "contract"
                contract_type.val = "nat"
                entry.type_i.nest_list.push contract_type
                entry.arg_name_list.push "callback"
                entry.name = "getAllowance"

                comment = new ast.Comment
                comment.text = "in Tezos `allowance` method should not return a value, but perform a transaction to the passed contract callback with a needed value"
                new_scope.push comment

          new_scope.push entry

      if new_scope.length
        root.scope.list = new_scope

      ctx.next_gen root, ctx

    else
      ctx.next_gen root, ctx


@erc20_interface_converter = (root, ctx)-> 
  init_ctx = {
    walk,
    next_gen: default_walk,
  }
  walk root, obj_merge(init_ctx, ctx)