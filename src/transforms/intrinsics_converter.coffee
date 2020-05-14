{ default_walk } = require "./default_walk"
ast = require "../ast"
Type = require "type"
module = @

@walk = (root, ctx)->
  {walk} = ctx
  switch root.constructor.name
    when "Var"
      if root.name == "now"
        # abs(now - (\"1970-01-01T00:00:00Z\": timestamp))
        abs_call = new ast.Fn_call
        abs_call.fn = new ast.Var
        abs_call.fn.left_unpack = true
        abs_call.fn.name = "abs"
        abs_call.fn.type = new Type "function2"
        abs_call.fn.type.nest_list[ast.INPUT_ARGS] = new Type "function<nat>"
        abs_call.fn.type.nest_list[ast.RETURN_VALUES] = new Type "function<nat>"

        abs_call.arg_list.push arg = new ast.Bin_op
        arg.op = "SUB"
        arg.a = new ast.Var
        arg.a.name = "now"
        arg.a.type = new Type "nat"
        arg.a.name_translate = false

        arg.b = new ast.Type_cast
        arg.b.target_type = new Type "timestamp"
        arg.b.t = new ast.Const
        arg.b.t.type = new Type "string"
        arg.b.t.val = "1970-01-01T00:00:00Z"

        return abs_call
      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx
  
  
@intrinsics_converter = (root)->
  module.walk root, {walk: module.walk, next_gen: default_walk}