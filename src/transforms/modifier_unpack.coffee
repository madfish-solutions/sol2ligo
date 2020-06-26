{ default_walk } = require "./default_walk"
ast = require "../ast"
{placeholder_replace} = require "./placeholder_replace"

do() =>
  fn_apply_modifier = (fn, mod, ctx)->
    ###
    Possible intersections
      1. Var_decl
      2. Var_decl in arg_list
      3. Multiple placeholders = multiple cloned Var_decl
    ###
    if mod.fn.constructor.name != "Var"
      throw new Error "unimplemented"
    if !ctx.modifier_map.hasOwnProperty mod.fn.name
      throw new Error "unknown modifier #{mod.fn.name}"
    mod_decl = ctx.modifier_map[mod.fn.name]
    ret = mod_decl.scope.clone()
    prepend_list = []
    for arg, idx in mod.arg_list
      continue if arg.name == mod_decl.arg_name_list[idx]
      prepend_list.push var_decl = new ast.Var_decl
      # TODO search **fn** for this_var name and replace in **ret** with tmp
      var_decl.name = mod_decl.arg_name_list[idx]

      var_decl.assign_value = arg.clone()
      var_decl.type = mod_decl.type_i.nest_list[idx]
    ret = placeholder_replace ret, fn
    ret.list = arr_merge prepend_list, ret.list
    ret

  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Fn_decl_multiret"
        if root.is_modifier
          ctx.modifier_map[root.name] = root
          
          # remove node
          ret = new ast.Comment
          ret.text = "modifier #{root.name} inlined"
          ret
        else 
          if root.is_constructor
            ctx.modifier_map[root.contract_name] = root
          return root if root.modifier_list.length == 0
          inner = root.scope.clone()
          # TODO clarify modifier's order
          for mod, idx in root.modifier_list
            inner.need_nest = false
            inner = fn_apply_modifier inner, mod, ctx
          inner.need_nest = true
          ret = root.clone()
          ret.modifier_list.clear()
          ret.scope = inner
          ret
      else
        ctx.next_gen root, ctx
    

  @modifier_unpack = (root)->
    walk root, {walk, next_gen: default_walk, modifier_map: {}}
