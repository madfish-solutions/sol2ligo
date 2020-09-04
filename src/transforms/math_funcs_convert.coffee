{ default_walk } = require "./default_walk"
ast = require "../ast"

do() =>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Fn_call"
        if root.fn.constructor.name == "Var"
          switch root.fn.name
            when "addmod"
              add = new ast.Bin_op
              add.op = "ADD"
              add.a = root.arg_list[0]
              add.b = root.arg_list[1]
              
              addmod = new ast.Bin_op
              addmod.op = "MOD"
              addmod.b = root.arg_list[2]
              addmod.a = add
              
              perr "WARNING (AST transform). `addmod` translation may compute incorrectly due to possible overflow. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#number-types"
              
              return addmod
            
            when "mulmod"
              mul = new ast.Bin_op
              mul.op = "MUL"
              mul.a = root.arg_list[0]
              mul.b = root.arg_list[1]
              
              mulmod = new ast.Bin_op
              mulmod.op = "MOD"
              mulmod.b = root.arg_list[2]
              mulmod.a = mul
              
              perr "WARNING (AST transform). `mulmod` translation may compute incorrectly due to possible overflow. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#number-types"
              
              return mulmod
        root
      else
        ctx.next_gen root, ctx

  @math_funcs_convert = (root, ctx)->
    walk root, obj_merge({walk, next_gen: default_walk}, ctx)