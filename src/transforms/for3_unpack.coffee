{ default_walk } = require "./default_walk"
ast = require "../ast"
Type = require "type"

do() =>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "For3"
        ret = new ast.Scope
        ret.need_nest = false
        
        if root.init
          ret.list.push root.init
        
        while_inside = new ast.While
        if root.cond
          while_inside.cond = root.cond
        else
          while_inside.cond = new ast.Const
          while_inside.cond.val = "true"
          while_inside.cond.type = new Type "bool"
        # clone scope
        while_inside.scope.list.append root.scope.list
        if root.iter
          while_inside.scope.list.push root.iter
        ret.list.push while_inside
        
        ret
      else
        ctx.next_gen root, ctx
    

  @for3_unpack = (root)->
    walk root, {walk, next_gen: default_walk}