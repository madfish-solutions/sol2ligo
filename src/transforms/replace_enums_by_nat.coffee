{ default_walk } = require "./default_walk"
ast = require "../ast"
Type = require "type"

# this transform replaces all enums with nat consts so they can be compared just like in Solidity

do () =>
  walk = (root, ctx)->
      {walk} = ctx
      switch root.constructor.name
        when "Scope"
          if root.original_node_type == "SourceUnit"
            ctx.enums_map = new Map
            ctx.new_declarations = []
            root = ctx.next_gen root, ctx
            # prepend collected declarations to global scope
            root.list = ctx.new_declarations.concat root.list
            root
          else
            ctx.next_gen root, ctx
        
        when "Enum_decl"
          ctx.enums_map.set root.name, true
          for value, idx in root.value_list
            decl = new ast.Var_decl
            decl.name = "#{root.name}_#{value.name}"
            decl.type = new Type "uint"
            decl.assign_value = new ast.Const
            decl.assign_value.type = new Type "uint"
            decl.assign_value.val = idx
            decl.is_enum_decl = true
            ctx.new_declarations.push decl
          
          ret = new ast.Comment
          ret.text = "enum #{root.name} converted into list of nats"
          ret

        when "Var_decl"
          if root.type
            if root.type.main == "map"
              for type, idx in root.type?.nest_list
                if ctx.enums_map.has type.main
                  root.type.nest_list[idx] = new Type "uint"
            else
              if ctx.enums_map.has root.type.main
                root.type = new Type "uint"
          ctx.next_gen root, ctx

        when "Field_access"
          if root.t.constructor.name == "Var"
            if ctx.enums_map.has root.t.name
              v = new ast.Var
              v.name = "#{root.t.name}_#{root.name}"
              v.type = new Type "nat"
              return v

          ctx.next_gen root, ctx
        
        else
          ctx.next_gen root, ctx
    
  @replace_enums_by_nat = (root, ctx)->
    walk root, {walk, next_gen: default_walk}