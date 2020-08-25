{ default_walk } = require "./default_walk"
ast = require "../ast"

walk = (root, ctx)->
  {walk} = ctx
  switch root.constructor.name
    when "Bin_op"
      if reg_ret = /^ASS_(.*)/.exec root.op
        ext = new ast.Bin_op
        ext.op = "ASSIGN"
        ext.a = root.a.clone()
        ext.b = root
        root.op = reg_ret[1]
        ext
      else
        root.a = walk root.a, ctx
        root.b = walk root.b, ctx
        root
    else
      ctx.next_gen root, ctx
  

@ass_op_unpack = (root)->
  walk root, {walk, next_gen: default_walk}
