{ default_walk } = require "./default_walk"
config = require "../config"
Type   = require "type"
ast = require "../ast"
{translate_type} = require "../translate_ligo"
{translate_var_name} = require "../translate_var_name"

walk = (root, ctx)->
  switch root.constructor.name
    when "Un_op"
      if root.op == "DELETE"
        if root.a.constructor.name == "Bin_op" and root.a.op == "INDEX_ACCESS"
          ctx_lvalue = clone ctx
          ctx_lvalue.lvalue = true
          root.a.a = walk root.a.a, ctx_lvalue
        else
          perr "WARNING DELETE without INDEX_ACCESS can be handled improperly (extra state pass + return)"
          # fallback
          root.a = walk root.a, ctx_lvalue
      
      root.a = walk root.a, ctx
      root
    
    when "Bin_op"
      if /^ASS/.test root.op
        ctx_lvalue = clone ctx
        ctx_lvalue.lvalue = true
        root.a = walk root.a, ctx_lvalue
      else
        root.a = walk root.a, ctx
      
      root.b = walk root.b, ctx
      root
    
    when "Var_decl"
      if !ctx.loc_var_decl and !root.is_enum_decl
        ctx.global_var_decl_map.set root.name, true
      
      if root.assign_value?
        walk root.assign_value, ctx
      root
    
    when "Var_decl_multi"
      if !ctx.loc_var_decl and !root.is_enum_decl
        for v in root.list
          ctx.global_var_decl_map.set v.name, true
      
      if root.assign_value?
        walk root.assign_value, ctx
      root
    
    when "Var"
      if ctx.global_var_decl_map.has root.name
        if ctx.lvalue
          if !ctx.modifies_storage.val
            ctx.modifies_storage.val = true
            ctx.change_count.val++
        if !ctx.uses_storage.val
          ctx.uses_storage.val = true
          ctx.change_count.val++
      root
    
    when "Class_decl"
      prev_class = ctx.current_class
      ctx.current_class = root
      for v in root.scope.list
        walk v, ctx
      ctx.current_class = prev_class
      root
    
    when "Fn_call"
      if root.fn.name in ["transfer", "send", "call", "built_in_pure_callback", "delegatecall", "transaction"]
        if !ctx.returns_op_list.val
          ctx.returns_op_list.val = true
          ctx.change_count.val++
      else
        switch root.fn.constructor.name
          when "Var"
            if nest_fn = ctx.fn_decl_map.get root.fn.name
              if nest_fn.returns_op_list and !ctx.returns_op_list.val
                ctx.returns_op_list.val = true
                ctx.change_count.val++
              if nest_fn.uses_storage and !ctx.uses_storage.val
                ctx.uses_storage.val = true
                ctx.change_count.val++
              if nest_fn.modifies_storage and !ctx.modifies_storage.val
                ctx.modifies_storage.val = true
                ctx.change_count.val++
              
              root.fn_decl = nest_fn
          
          when "Field_access"
            if root.fn.t.constructor.name == "Var" and root.fn.t.name == "this"
              if nest_fn = ctx.fn_decl_map.get root.fn.name
                if nest_fn.returns_op_list and !ctx.returns_op_list.val
                  ctx.returns_op_list.val = true
                  ctx.change_count.val++
                if nest_fn.uses_storage and !ctx.uses_storage.val
                  ctx.uses_storage.val = true
                  ctx.change_count.val++
                if nest_fn.modifies_storage and !ctx.modifies_storage.val
                  ctx.modifies_storage.val = true
                  ctx.change_count.val++
                
                root.fn_decl = nest_fn
              else if ctx.global_var_decl_map.has root.fn.name
                if ctx.lvalue
                  if !ctx.modifies_storage.val
                    ctx.modifies_storage.val = true
                    ctx.change_count.val++
                if !ctx.uses_storage.val
                  ctx.uses_storage.val = true
                  ctx.change_count.val++
            else if root.fn.name == "push"
              # TODO check that root.fn.type is array
              # e.g. arr.push(10)
              ctx_lvalue = clone ctx
              ctx_lvalue.lvalue = true
              root.fn = walk root.fn, ctx_lvalue
            else
              # using case
              # TODO check for using decl
              # BUG 2 libraries with same method name will break this
              found = false
              for _type, using_list of ctx.current_class.using_map
                for using in using_list
                  synthetic_name = translate_var_name "#{using}_#{root.fn.name}", null
                  if nest_fn = ctx.fn_decl_map.get synthetic_name
                    if nest_fn.returns_op_list and !ctx.returns_op_list.val
                      ctx.returns_op_list.val = true
                      ctx.change_count.val++
                    if nest_fn.uses_storage and !ctx.uses_storage.val
                      ctx.uses_storage.val = true
                      ctx.change_count.val++
                    if nest_fn.modifies_storage and !ctx.modifies_storage.val
                      ctx.modifies_storage.val = true
                      ctx.change_count.val++
                    
                    root.fn_decl = nest_fn
                    root.is_fn_decl_from_using = true
                    root.fn_name_using = synthetic_name
                    
                    found = true
                    break
                break if found
      
      for v,idx in root.arg_list
        root.arg_list[idx] = walk v, ctx
      root.fn = walk root.fn, ctx
      root
    
    when "Fn_decl_multiret"
      ctx.fn_decl_map.set root.name, root
      # val for clone bypass
      ctx.returns_op_list  = val : root.returns_op_list 
      ctx.uses_storage     = val : root.uses_storage    
      ctx.modifies_storage = val : root.modifies_storage
      ctx.loc_var_decl     = true
      
      root.scope = walk root.scope, ctx
      
      root.returns_op_list  = ctx.returns_op_list.val 
      root.uses_storage     = ctx.uses_storage.val    
      root.modifies_storage = ctx.modifies_storage.val
      root.returns_value    = root.type_o.nest_list.length > 0
      
      ctx.loc_var_decl     = false
      
      root

    else
      ctx.next_gen root, ctx

@deep_check_storage_and_oplist_use = (root, ctx)->
  ctx = {
    walk
    next_gen: default_walk
    change_count: val : 1 # pass first while, val for clone bypass
    global_var_decl_map: new Map
    fn_decl_map: new Map
    current_class : null
    # BUG 2 classes with same method name will replace fn_decl of each other
    # to fix use mk_nest and obj_set-like for fn_decl_map
  }
  for prevent_loop in [0 ... 100]
    break if ctx.change_count.val == 0
    ctx.change_count.val = 0
    root = walk root, ctx
  
  if ctx.change_count.val
    perr "WARNING prevent infinite loop trigger catched. Please notify developer about it with code example. Generated code can be invalid"
  
  root
  