{ default_walk } = require "./default_walk"
ast = require "../ast"
Type = require "type"

do () =>
  walk = (root, ctx)->
      {walk} = ctx
      switch root.constructor.name
        when "Scope"
          statements = []
          for v, idx in root.list
            ctx.statements_to_prepend = []
            ctx.tmp_index = 0
            res = walk v, ctx
            if ctx.statements_to_prepend.length > 0
              statements = statements.concat ctx.statements_to_prepend
            statements.push res
          root.list = statements
          root
        
        when "Bin_op"
          if root.op == "INDEX_ACCESS"
            tmp = new ast.Var_decl
            tmp.name = "tmp_idx_access"+ctx.tmp_index
            tmp.type = root.a.type 
            tmp.assign_value = root.a
            ctx.statements_to_prepend.push tmp
            
            root.a = new ast.Var
            root.a.name = tmp.name
            ctx.tmp_index += 1
          ctx.next_gen root, ctx
        
        else
          ctx.next_gen root, ctx
    
  @split_nested_index_access = (root, ctx)->
    walk root, {walk, next_gen: default_walk}