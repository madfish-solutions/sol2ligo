{ default_walk } = require "./default_walk"

module = @

@walk = (root, ctx)->
  {walk} = ctx
  switch root.constructor.name
    when "Fn_call"
      if root.fn.constructor.name == "Var"
        if root.fn.name == "require"
          if root.arg_list.length == 2
            root.fn.name = "require2"
      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx
  
  
@require_distinguish = (root)->
  module.walk root, {walk: module.walk, next_gen: default_walk}