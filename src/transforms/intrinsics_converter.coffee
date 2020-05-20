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
      
      when "Field_access"
        switch root.t.name
          when "block"
            if root.name == "timestamp"
              return timestamp_node()
          when "msg"
            switch root.name
              when "sender"
                root.t.name = "@Tezos"
                root.name = "@sender"
              when "value"
                ret = new ast.Bin_op
                ret.op = "DIV"
                ret.a = new ast.Var
                ret.a.name = "@amount"
                ret.a.type = new Type "uint"
                ret.b = new ast.Const
                ret.b.val = 1
                ret.b.type = new Type "mutez"
                return ctx.next_gen ret, ctx
          when "tx"
            if root.name == "origin"
              root.t.name = "@Tezos"
              root.name = "@source"
        
        ctx.next_gen root, ctx

      else
        ctx.next_gen root, ctx
    
    
  @intrinsics_converter = (root)->
    walk root, {walk, next_gen: default_walk}