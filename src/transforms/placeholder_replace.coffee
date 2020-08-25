{ default_walk } = require "./default_walk"

walk = (root, ctx)->
  {walk} = ctx
  switch root.constructor.name
    when "Scope"
      root = ctx.next_gen root, ctx
      list = []
      for v in root.list
        if v.constructor.name == "Scope"
          list.append v.list
        else
          list.push v
      root.list = list
      root
    
    when "Comment"
      return root if root.text != "COMPILER MSG PlaceholderStatement"
      ctx.target_ast.clone()
    else
      ctx.next_gen root, ctx

@placeholder_replace = (root, target_ast)->
  walk root, {walk, next_gen: default_walk, target_ast}