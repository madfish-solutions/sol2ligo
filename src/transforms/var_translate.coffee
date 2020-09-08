{ default_walk } = require "./default_walk"
{translate_var_name} = require "../translate_var_name"
config = require "../config"
ast = require "../ast"

do() =>
  walk = (root, ctx)->
    switch root.constructor.name
      when "Class_decl"
        ctx.current_class = root
        if root.is_library
          ctx.libraries[root.name] = true
        default_walk root, ctx

      when "Var"
        root.name = translate_var_name root.name
        root
      
      when "Var_decl"
        if root.assign_value
          root.assign_value = walk root.assign_value, ctx
        root.name = translate_var_name root.name
        root

      when "Field_access"
        if root.t.type?.main == "enum"
          name = translate_var_name root.name, ctx
          if root.t?.name != config.router_enum
            prefix = ""
            if ctx.current_class.name
              prefix = "#{ctx.current_class.name}_"
            root.name = "#{translate_var_name prefix + root.t.name}_#{root.name}"
          else
            name = "#{ctx.current_class.name.toUpperCase()}_#{name}"
            root.name = "#{name}(unit)"

        root.name = translate_var_name root.name

        #TODO library prefix
        default_walk root, ctx

      
      when "Var_decl_multi"
        if root.assign_value
          root.assign_value = walk root.assign_value, ctx
        for _var in root.list
          _var.name = translate_var_name _var.name
        root
      
      when "Fn_decl_multiret"
        name = root.name
        if ctx.current_class?.is_library
          name = "#{ctx.current_class.name}_#{name}"
        root.name = translate_var_name name

        root.scope = walk root.scope, ctx
        for name,idx in root.arg_name_list
          root.arg_name_list[idx] = translate_var_name name
        root

      when "Fn_call"
        name = root.fn.name
        if root.fn.constructor.name == "Var"
          if ctx.current_class?.is_library and ctx.current_class._prepared_field2type[name]
            root.fn.name = "#{ctx.current_class.name}_#{name}"
        else if root.fn.constructor.name == "Field_access"
          library_name = root.fn.t.name
          if ctx.libraries.hasOwnProperty library_name
            name = "#{library_name}_#{name}"
            root.fn = new ast.Var
            root.fn.name = name
        
        default_walk root, ctx

      when "Enum_decl"
        root.name = translate_var_name root.name
        for value, idx in root.value_list
          root.value_list[idx].name = "#{value.name}"

        root

      when "Event_decl"
        for arg, idx in root.arg_list
          root.arg_list[idx]._name = translate_var_name arg._name

        root
      
      else
        default_walk root, ctx
      
  @var_translate = (root, ctx) ->
    walk root, {walk, next_gen: default_walk, libraries: {}}