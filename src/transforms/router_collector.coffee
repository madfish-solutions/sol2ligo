{ default_walk } = require "./default_walk"


walk = (root, ctx)->
  {walk} = ctx
  switch root.constructor.name
    when "Class_decl"
      return root if root.need_skip
      return root if root.is_library
      return root if root.is_contract and !root.is_last
      ctx.inheritance_list = root.inheritance_list
      ctx.next_gen root, ctx
    
    when "Fn_decl_multiret"
      if root.visibility not in ["private", "internal"]
        ctx.router_func_list.push root
      root
    
    else
      ctx.next_gen root, ctx

@router_collector = (root, opt)->
  walk root, ctx = obj_merge({walk, next_gen: default_walk, router_func_list: []}, opt)
  ctx.router_func_list