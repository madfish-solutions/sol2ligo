{ default_walk } = require "./default_walk"
ast = require "../ast"

do () =>
  walk = (root, ctx)->
      {walk} = ctx
      switch root.constructor.name
        when "Event_decl"
          ctx.emit_decl_map[root.name] = true
          root
        
        when "Fn_call"
          if root.fn.constructor.name == "Var"
            if ctx.emit_decl_map.hasOwnProperty root.fn.name
              perr "WARNING (AST transform). EmitStatement is not supported. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#solidity-events"
              ret = new ast.Comment
              args = root.arg_list.map (arg) -> arg.name
              ret.text = "EmitStatement #{root.fn.name}(#{args.join(", ")})"
              return ret
          ctx.next_gen root, ctx
        
        else
          ctx.next_gen root, ctx
      
    
  @fix_missing_emit = (root)->
    walk root, {walk, next_gen: default_walk, emit_decl_map: {}}