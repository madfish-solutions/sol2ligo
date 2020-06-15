{ default_walk } = require "./default_walk"

walk = (root, ctx)->
  {walk} = ctx
  switch root.constructor.name
    when "Comment"
      return root if root.text != "COMPILER MSG PlaceholderStatement"
      ret = ctx.target_ast.clone()
      unless ctx.need_nest
        last = ret.list.last()
        if last and last.constructor.name == "Ret_multi"
          last = ret.list.pop()
      ret
    else
      ctx.next_gen root, ctx

@placeholder_replace = (root, target_ast)->
  walk root, {walk, next_gen: default_walk, target_ast}