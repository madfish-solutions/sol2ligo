{ default_walk } = require "./default_walk"

do() =>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Fn_decl_multiret"
        ctx.fn_map[root.name] = root
        ctx.next_gen root, ctx

      else
        ctx.next_gen root, ctx
    

  @collect_fn_decl = (root)->
    fn_map = {}
    walk root, {walk, next_gen: default_walk, fn_map}
    fn_map