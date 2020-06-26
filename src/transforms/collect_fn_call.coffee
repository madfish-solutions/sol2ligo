{ default_walk } = require "./default_walk"

do() =>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Fn_decl_multiret"
        # usual walk doesn't touch modifier_list. But we do
        for mod in root.modifier_list
          walk mod, ctx
        ctx.next_gen root, ctx
      
      when "Fn_call"
        switch root.fn.constructor.name
          when "Var"
            ctx.fn_map[root.fn.name] = true
          
          when "Field_access"
            if root.fn.t.constructor.name == "Var"
              if root.fn.t.name == "this"
                ctx.fn_map[root.fn.name] = true
        
        ctx.next_gen root, ctx
      
      else
        ctx.next_gen root, ctx
    

  @collect_fn_call = (root)->
    fn_map = {}
    walk root, {walk, next_gen: default_walk, fn_map}
    fn_map