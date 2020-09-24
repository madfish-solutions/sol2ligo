# bottom-to-top walk + type reference

Type = require "type"
config = require "../config"
require "../type_safe"
ti = require "./common"
type_generalize = require "../type_generalize"

@walk = (root, ctx)->
  switch root.constructor.name
    # ###################################################################################################
    #    expr
    # ###################################################################################################
    when "Var"
      root.type = ti.type_spread_left root.type, ctx.check_id(root.name), ctx
    
    when "Const"
      root.type
    
    when "Bin_op"
      ctx.walk root.a, ctx
      ctx.walk root.b, ctx
      
      switch root.op
        when "ASSIGN"
          root.a.type = ti.type_spread_left root.a.type, root.b.type, ctx
          root.b.type = ti.type_spread_left root.b.type, root.a.type, ctx
          
          root.type = ti.type_spread_left root.type, root.a.type, ctx
          root.a.type = ti.type_spread_left root.a.type, root.type, ctx
          root.b.type = ti.type_spread_left root.b.type, root.type, ctx
        
        when "EQ", "NE", "GT", "GTE", "LT", "LTE"
          root.type = ti.type_spread_left root.type, new Type("bool"), ctx
          root.a.type = ti.type_spread_left root.a.type, root.b.type, ctx
          root.b.type = ti.type_spread_left root.b.type, root.a.type, ctx
        
        when "INDEX_ACCESS"
          switch root.a.type?.main
            when "string"
              root.b.type = ti.type_spread_left root.b.type, new Type("uint256"), ctx
              root.type = ti.type_spread_left root.type, new Type("string"), ctx
            
            when "map"
              root.b.type = ti.type_spread_left root.b.type, root.a.type.nest_list[0], ctx
              root.type   = ti.type_spread_left root.type, root.a.type.nest_list[1], ctx
            
            when "array"
              root.b.type = ti.type_spread_left root.b.type, new Type("uint256"), ctx
              root.type   = ti.type_spread_left root.type, root.a.type.nest_list[0], ctx
            
            else
              if config.bytes_type_map.hasOwnProperty root.a.type?.main
                root.b.type = ti.type_spread_left root.b.type, new Type("uint256"), ctx
                root.type = ti.type_spread_left root.type, new Type("bytes1"), ctx
      
      # bruteforce only at stage 2
      
      root.type
    
    when "Un_op"
      a = ctx.walk root.a, ctx
      
      if root.op == "DELETE"
        if root.a.constructor.name == "Bin_op"
          if root.a.op == "INDEX_ACCESS"
            if root.a.a.type?.main == "array"
              return root.type
            if root.a.a.type?.main == "map"
              return root.type
      
      root.type
    
    when "Field_access"
      root_type = ctx.walk(root.t, ctx)
      
      field_map = {}
      if root_type
        switch root_type.main
          when "array"
            field_map = ti.array_field_map
          
          when "address"
            field_map = ti.address_field_map
          
          when "struct"
            field_map = root_type.field_map
          
          when "enum"
            field_map = root_type.field_map
          
          else
            if config.bytes_type_map.hasOwnProperty root_type.main
              field_map = ti.bytes_field_map
            else
              class_decl = ctx.check_type root_type.main
              if class_decl?._prepared_field2type
                field_map = class_decl._prepared_field2type
              else
                type = type_generalize root_type.main
                using_list = ctx.current_class.using_map[type] or ctx.current_class.using_map["*"]
                if using_list
                  for using in using_list
                    class_decl = ctx.check_type using
                    if !class_decl
                      perr "WARNING (Type inference). Bad using '#{using}'"
                      continue
                    continue if !fn_decl = class_decl._prepared_field2type[root.name]
                    ret_type = fn_decl.clone()
                    a_type = ret_type.nest_list[0].nest_list.shift()
                    if !a_type.cmp root_type
                      perr "WARNING (Type inference). Bad using '#{using}' types for self are not same #{a_type} != #{root_type}"
                    
                    root.type = ti.type_spread_left root.type, ret_type, ctx
                    return root.type
                  
                  perr "WARNING (Type inference). Can't find #{root.name} for Field_access"
                  return root_type
                else
                  perr "WARNING (Type inference). Can't find declaration for Field_access .#{root.name}"
                  return root_type

      if !field_map.hasOwnProperty root.name
        # perr root.t
        # perr field_map
        perr "WARNING (Type inference). Unknown field. '#{root.name}' at type '#{root_type}'. Allowed fields [#{Object.keys(field_map).join ', '}]"
        return root.type
      field_type = field_map[root.name]
      
      # Seems to be useless
      # field_type = ast.type_actualize field_type, root.t.type
      if typeof field_type == "function"
        field_type = field_type root.t.type
      
      root.type = ti.type_spread_left root.type, field_type, ctx
      root.type
    
    when "Fn_call"
      switch root.fn.constructor.name
        when "Var"
          if root.fn.name == "super"
            perr "WARNING (Type inference). Skipping super() call"
            for arg in root.arg_list
              ctx.walk arg, ctx
            
            return root.type
        
        when "Field_access"
          if root.fn.t.constructor.name == "Var"
            if root.fn.t.name == "super"
              perr "WARNING (Type inference). Skipping super.fn call"
              for arg in root.arg_list
                ctx.walk arg, ctx
              
              return root.type
      
      root_type = ctx.walk root.fn, ctx
      root_type = ti.type_resolve root_type, ctx
      if !root_type
        perr "WARNING (Type inference). Can't resolve function type for Fn_call"
        return root.type
      
      offset = 0
      for arg,i in root.arg_list
        ctx.walk arg, ctx
        if root_type.main != "struct"
          expected_type = root_type.nest_list[0].nest_list[i+offset]
          arg.type = ti.type_spread_left arg.type, expected_type, ctx
      
      
      if root_type.main == "struct"
        # this is contract(address) case
        if root.arg_list.length != 1
          perr "WARNING (Type inference). contract(address) call should have 1 argument. real=#{root.arg_list.length}"
          return root.type
        [arg] = root.arg_list
        arg.type = ti.type_spread_left arg.type, new Type("address"), ctx
        root.type = ti.type_spread_left root.type, root_type, ctx
      else
        root.type = ti.type_spread_left root.type, root_type.nest_list[1].nest_list[offset], ctx
    
    when "Struct_init"
      root_type = ctx.walk root.fn, ctx
      root_type = ti.type_resolve root_type, ctx
      if !root_type
        perr "WARNING (Type inference). Can't resolve function type for Struct_init"
        return root.type
      
      if root.type
        type_key = root.type.main
      else if root.fn
        type_key = root.fn.name
      else
        throw new Error "ERROR (Type inference). Can't find struct's type in this AST branch"
      if !(type_cached = ctx.type_map[type_key])
        perr "WARNING (Type inference). No type declaration for #{type_key}."
        return root_type
      for val, idx in root.val_list
        val.type = ti.type_spread_left val.type, type_cached.scope.list[idx].type, ctx
        ctx.walk val, ctx
      
      root_type
    
    # ###################################################################################################
    #    stmt
    # ###################################################################################################
    when "Comment"
      null
    
    when "Continue", "Break"
      root
    
    when "Var_decl"
      if root.assign_value
        root.assign_value.type = ti.type_spread_left root.assign_value.type, root.type, ctx
        ctx.walk root.assign_value, ctx
      ctx.var_map[root.name] = root.type
      null
    
    when "Var_decl_multi"
      if root.assign_value
        root.assign_value.type = ti.type_spread_left root.assign_value.type, root.type, ctx
        ctx.walk root.assign_value, ctx
      for decl in root.list
        ctx.var_map[decl.name] = decl.type
      null
    
    when "Throw"
      if root.t
        ctx.walk root.t, ctx
      null
    
    when "Scope"
      ctx_nest = ctx.mk_nest()
      for v in root.list
        if v.constructor.name == "Class_decl"
          ti.class_prepare v, ctx
      for v in root.list
        ctx.walk v, ctx_nest
      
      null
    
    when "Ret_multi"
      for v,idx in root.t_list
        v.type = ti.type_spread_left v.type, ctx.parent_fn.type_o.nest_list[idx], ctx
        expected = ctx.parent_fn.type_o.nest_list[idx]
        real = v.type
        if !expected.cmp real
          perr root
          perr "fn_type=#{ctx.parent_fn.type_o}"
          perr v
          throw new Error "Ret_multi type mismatch [#{idx}] expected=#{expected} real=#{real} @fn=#{ctx.parent_fn.name}"
        
        ctx.walk v, ctx
      null
    
    when "Class_decl"
      ti.class_prepare root, ctx
      
      ctx_nest = ctx.mk_nest()
      ctx_nest.current_class = root
      
      for k,v of root._prepared_field2type
        ctx_nest.var_map[k] = v
      
      # ctx_nest.var_map["this"] = new Type root.name
      ctx.walk root.scope, ctx_nest
      root.type
    
    when "Fn_decl_multiret"
      complex_type = new Type "function2"
      complex_type.nest_list.push root.type_i
      complex_type.nest_list.push root.type_o
      ctx.var_map[root.name] = complex_type
      ctx_nest = ctx.mk_nest()
      ctx_nest.parent_fn = root
      for name,k in root.arg_name_list
        type = root.type_i.nest_list[k]
        ctx_nest.var_map[name] = type
      ctx.walk root.scope, ctx_nest
      root.type
    
    when "PM_switch"
      null
    
    # ###################################################################################################
    #    control flow
    # ###################################################################################################
    when "If"
      ctx.walk(root.cond, ctx)
      ctx.walk(root.t, ctx.mk_nest())
      ctx.walk(root.f, ctx.mk_nest())
      null
    
    when "While"
      ctx.walk root.cond, ctx.mk_nest()
      ctx.walk root.scope, ctx.mk_nest()
      null
    
    when "Enum_decl"
      ctx.type_map[root.name] = root
      for decl in root.value_list
        ctx.var_map[decl.name] = decl.type

      new Type "enum"
    
    when "Type_cast"
      ctx.walk root.t, ctx
      root.type
    
    when "Ternary"
      ctx.walk root.cond, ctx
      t = ctx.walk root.t, ctx
      f = ctx.walk root.f, ctx
      root.t.type = ti.type_spread_left root.t.type, root.f.type, ctx
      root.f.type = ti.type_spread_left root.f.type, root.t.type, ctx
      root.type = ti.type_spread_left root.type, root.t.type, ctx
      root.type
    
    when "New"
      # TODO check suitable constructor
      for arg in root.arg_list
        ctx.walk arg, ctx
      root.type
    
    when "Tuple"
      for v in root.list
        ctx.walk v, ctx
      
      # -> ret
      nest_list = []
      for v in root.list
        nest_list.push v.type
      
      type = new Type "tuple<>"
      type.nest_list = nest_list
      root.type = ti.type_spread_left root.type, type, ctx
      
      # <- ret
      
      for v,idx in root.type.nest_list
        tuple_value = root.list[idx]
        tuple_value.type = ti.type_spread_left tuple_value.type, v, ctx
      
      root.type
    
    when "Array_init"
      for v in root.list
        ctx.walk v, ctx
      
      nest_type = null
      if root.type
        if root.type.main != "array"
          throw new Error "Array_init can have only array type"
        nest_type = root.type.nest_list[0]
      
      for v in root.list
        nest_type = ti.type_spread_left nest_type, v.type, ctx
      
      for v in root.list
        v.type = ti.type_spread_left v.type, nest_type, ctx
      
      type = new Type "array<>"
      type.nest_list[0] = nest_type.clone()
      root.type = ti.type_spread_left root.type, type, ctx
      root.type
    
    when "Event_decl"
      null
    
    else
      ### !pragma coverage-skip-block ###
      perr root
      throw new Error "ti phase 1 unknown node '#{root.constructor.name}'"
