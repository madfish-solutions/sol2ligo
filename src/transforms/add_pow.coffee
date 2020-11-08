{ default_walk } = require "./default_walk"
ast = require "../ast"
Type = require "type"

walk = (root, ctx)->
  if root.constructor.name == "Bin_op" and root.op == "POW"
    ctx.need_pow = true
  ctx.next_gen root, ctx

@add_pow = (root)->
  ctx = {
    walk,
    next_gen: default_walk,
    need_pow: false,
  }
  walk root, ctx
  if ctx.need_pow
    decl = new ast.Fn_decl_multiret
    decl.name = "pow"
    root.list.unshift decl
  root
