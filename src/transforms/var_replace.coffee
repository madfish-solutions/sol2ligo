{ default_walk } = require "./default_walk"

do() =>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Var"
        return root if root.name != ctx.var_name
        ctx.target_ast.clone()
      else
        ctx.next_gen root, ctx

  @var_replace = (root, var_name, target_ast)->
    walk root, {walk, next_gen: default_walk, var_name, target_ast}