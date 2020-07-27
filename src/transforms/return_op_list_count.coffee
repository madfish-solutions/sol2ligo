{ default_walk } = require "./default_walk"

ast = require "../ast"
astBuilder = require "../ast_builder"
Type = require "type"

walk = (root, ctx)->
  switch root.constructor.name
    when "Fn_decl_multiret"
      ctx.current_fn_opcount = 0
      ctx.next_gen root, ctx

    when "Fn_call"
      if root.fn.name == "transaction"
        op_index = ctx.current_fn_opcount
        declaration = astBuilder.declaration("op" + op_index, root, new Type "operation")
        ctx.current_fn_opcount += 1
        return declaration

      ctx.next_gen root, ctx

    when "Ret_multi"
      if ctx.current_fn_opcount > 0
        list_init = new ast.Array_init
        list_init.type = new Type "built_in_op_list"
        for i in [0..ctx.current_fn_opcount - 1]
          list_init.list.push v = new ast.Var
          v.name = "op" + i

        root.t_list[0] = list_init

        root
      else
        ctx.next_gen root, ctx
        
    else
      ctx.next_gen root, ctx
  
  
@return_op_list_count = (root)->
  walk root, {walk, next_gen: default_walk}