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

tx_node = (address_expr, arg_list, name, ctx) ->
  address_expr = astBuilder.contract_addr_transform address_expr
  entrypoint = astBuilder.foreign_entrypoint(address_expr, "fa12_action")
  enum_val = astBuilder.enum_val("@" + name, arg_list)
  tx = astBuilder.transaction([enum_val], entrypoint)
  return tx

callback_tx_node = (name, root, ctx) ->
  cb_name = name.substr(0,1).toLowerCase() + name.substr(1) + "Callback"

  contract_type = new Type "contract"
  contract_type.val = "nat"
  return_callback = astBuilder.self_entrypoint("%" + cb_name, contract_type)

  if not ctx.callbacks_to_declare_map.has cb_name
    # TODO why are we using nest_list of nest_list?
    return_type = root.fn.type.nest_list[ast.RETURN_VALUES].nest_list[ast.INPUT_ARGS]
    cb_decl = astBuilder.callback_declaration name, return_type
    ctx.callbacks_to_declare_map.set cb_name, cb_decl

  arg_list = root.arg_list
  arg_list.push return_callback
  return tx_node(root.fn.t, arg_list, name, ctx)

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
              when "transfer"
                sender = astBuilder.tezos_var("sender")
                arg_list = root.arg_list
                arg_list.unshift(sender)
                return tx_node(root.fn.t, arg_list, "Transfer", ctx)
              when "approve"
                arg_list = root.arg_list
                arg_list[0] = astBuilder.cast_to_address arg_list[0]
                return tx_node(root.fn.t, arg_list, "Approve", ctx)
              when "transferFrom"
                arg_list = root.arg_list
                arg_list[1] = astBuilder.cast_to_address arg_list[1]
                return tx_node(root.fn.t, arg_list, "Transfer", ctx)
              
              when "allowance"
                ret = root
                ret.arg_list[0] = astBuilder.cast_to_address ret.arg_list[0]
                ret.arg_list[1] = astBuilder.cast_to_address ret.arg_list[1]
                return callback_tx_node("GetAllowance", ret,  ctx)
              when "balanceOf"
                ret = root
                ret.arg_list[0] = astBuilder.cast_to_address ret.arg_list[0]
                return callback_tx_node("GetBalance", ret,  ctx)
              when "totalSupply"
                ret = root
                ret.arg_list.unshift astBuilder.unit()
                return callback_tx_node("GetTotalSupply", ret,  ctx)
              
      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx


@erc20_converter = (root, ctx)-> 
  init_ctx = {
    walk,
    next_gen: default_walk,
  }
  walk root, obj_merge(init_ctx, ctx)