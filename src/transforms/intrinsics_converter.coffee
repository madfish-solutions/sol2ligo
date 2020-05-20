{ default_walk } = require "./default_walk"
ast = require "../ast"
Type = require "type"
module = @

timestamp_node = ()->
  timestamp = new ast.Bin_op
  timestamp.op = "SUB"
  timestamp.a = new ast.Var
  timestamp.a.name = "@now"
  timestamp.a.name_translate = false

  timestamp.b = new ast.Type_cast
  timestamp.b.target_type = new Type "timestamp"
  timestamp.b.t = new ast.Const
  timestamp.b.t.type = new Type "string"
  timestamp.b.t.val = "1970-01-01T00:00:00Z"

  # this code relies on a fact that subtracting two uints always wrapped in "abs" later on
  timestamp.a.type = new Type "uint"
  timestamp.b.type = new Type "uint"

  timestamp

do() =>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Var"
        if root.name == "now"
          return timestamp_node()

        ctx.next_gen root, ctx
      
        ctx.next_gen root, ctx
    
    
  @intrinsics_converter = (root)->
    walk root, {walk, next_gen: default_walk}