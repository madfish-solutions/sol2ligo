{ default_walk } = require "./default_walk"
ast = require "../ast"
Type = require "type"

do () =>
  walk = (root, ctx)->
      {walk} = ctx
      switch root.constructor.name
        when "Scope"
          if root.original_node_type == "SourceUnit"
            # prepend collected declarations to global scope
            ctx.new_declarations = []
            root = ctx.next_gen root, ctx
            root.list = ctx.new_declarations.concat root.list
            root          
          else
            ctx.next_gen root, ctx
        
        when "Enum_decl"
          for value, idx in root.value_list
            decl = new ast.Var_decl
            decl.name = "#{root.name}_#{value.name}"
            decl.type = new Type "uint"
            decl.assign_value = new ast.Const
            decl.assign_value.type = new Type "uint"
            decl.assign_value.val = idx
            ctx.new_declarations.push decl
          
          ret = new ast.Comment
          ret.text = "enum #{root.name} converted into list of nats"
          ret
        
        else
          ctx.next_gen root, ctx
    
  @replace_enums_by_nat = (root, ctx)->
    walk root, {walk, next_gen: default_walk}