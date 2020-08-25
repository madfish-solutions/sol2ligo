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
            # add new prepend context to the top, top properly handle nested scopes
            # we can update temp_index every statement as well since LIGO handles variable shadowing magnificently
            ctx.scope_sink.unshift {statements_to_prepend: [], temp_index: 0}
            res = walk v, ctx
            statements.append ctx.scope_sink[0].statements_to_prepend
            ctx.scope_sink.shift()
            statements.push res
          root.list = statements
          root
        
        when "Bin_op"
          root.a = walk root.a, ctx
          is_nested_index_access = root.op == "INDEX_ACCESS" and
                                   root.a.constructor.name == "Bin_op" and
                                   root.a.op == "INDEX_ACCESS"
          if is_nested_index_access
            current_scope_sink = ctx.scope_sink[0] 
            tmp = new ast.Var_decl
            tmp.name = "temp_idx_access" + current_scope_sink.temp_index
            tmp.type = root.a.type
            tmp.assign_value = root.a
            current_scope_sink.statements_to_prepend.push tmp
            
            root.a = new ast.Var
            root.a.name = tmp.name
            current_scope_sink.temp_index += 1
          root.b = walk root.b, ctx
          return root

        else
          ctx.next_gen root, ctx
    
  @split_nested_index_access = (root, ctx)->
    walk root, {walk, next_gen: default_walk, scope_sink: []}