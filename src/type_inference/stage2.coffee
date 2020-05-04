config = require "../config"
Type = require "type"
ti = require "./common"

get_list_sign = (list)->
  has_signed   = false
  has_unsigned = false
  has_wtf      = false
  for v in list
    if config.int_type_map.hasOwnProperty(v) or v == "signed_number"
      has_signed = true
    else if config.uint_type_map.hasOwnProperty(v) or v == "unsigned_number"
      has_unsigned = true
    else if v == "number"
      has_signed = true
      has_unsigned = true
    else
      has_wtf = true
  
  return null if has_wtf
  return "number"           if  has_signed  and  has_unsigned
  return "signed_number"    if  has_signed  and !has_unsigned
  return "unsigned_number"  if !has_signed  and  has_unsigned
  throw new Error "unreachable"
 
@walk = (root, ctx)->
  switch root.constructor.name
    when "Var"
      root.type = ti.type_spread_left root.type, ctx.check_id(root.name), ctx
    
    when "Const"
      root.type
    
    when "Bin_op"
      @walk root.a, ctx
      @walk root.b, ctx
      
      switch root.op
        when "ASSIGN"
          root.a.type = ti.type_spread_left root.a.type, root.b.type, ctx
          root.b.type = ti.type_spread_left root.b.type, root.a.type, ctx
          
          root.type = ti.type_spread_left root.type, root.a.type, ctx
          root.a.type = ti.type_spread_left root.a.type, root.type, ctx
          root.b.type = ti.type_spread_left root.b.type, root.type, ctx
          return root.type
        
        when "EQ", "NE", "GT", "GTE", "LT", "LTE"
          root.type = ti.type_spread_left root.type, new Type("bool"), ctx
          root.a.type = ti.type_spread_left root.a.type, root.b.type, ctx
          root.b.type = ti.type_spread_left root.b.type, root.a.type, ctx
          return root.type
        
        when "INDEX_ACCESS"
          switch root.a.type?.main
            when "string"
              root.b.type = ti.type_spread_left root.b.type, new Type("uint256"), ctx
              root.type = ti.type_spread_left root.type, new Type("string"), ctx
              return root.type
            
            when "map"
              root.b.type = ti.type_spread_left root.b.type, root.a.type.nest_list[0], ctx
              root.type   = ti.type_spread_left root.type, root.a.type.nest_list[1], ctx
              return root.type
            
            when "array"
              root.b.type = ti.type_spread_left root.b.type, new Type("uint256"), ctx
              root.type   = ti.type_spread_left root.type, root.a.type.nest_list[0], ctx
              return root.type
            
            else
              if config.bytes_type_map.hasOwnProperty root.a.type?.main
                root.b.type = ti.type_spread_left root.b.type, new Type("uint256"), ctx
                root.type = ti.type_spread_left root.type, new Type("bytes1"), ctx
                return root.type
      
      bruteforce_a  = ti.is_not_defined_type root.a.type
      bruteforce_b  = ti.is_not_defined_type root.b.type
      bruteforce_ret= ti.is_not_defined_type root.type
      a   = (root.a.type or "").toString()
      b   = (root.b.type or "").toString()
      ret = (root.type   or "").toString()
      
      if !list = ti.bin_op_ret_type_map_list[root.op]
        throw new Error "unknown bin_op #{root.op}"
        
      # filter for fully defined types
      found_list = []
      for tuple in list
        continue if tuple[0] != a   and !bruteforce_a
        continue if tuple[1] != b   and !bruteforce_b
        continue if tuple[2] != ret and !bruteforce_ret
        found_list.push tuple
      
      # filter for partially defined types
      if ti.is_number_type root.a.type
        filter_found_list = []
        for tuple in found_list
          continue if !config.any_int_type_map.hasOwnProperty tuple[0]
          filter_found_list.push tuple
        
        found_list = filter_found_list
      
      if ti.is_number_type root.b.type
        filter_found_list = []
        for tuple in found_list
          continue if !config.any_int_type_map.hasOwnProperty tuple[1]
          filter_found_list.push tuple
        
        found_list = filter_found_list
      
      if ti.is_number_type root.type
        filter_found_list = []
        for tuple in found_list
          continue if !config.any_int_type_map.hasOwnProperty tuple[2]
          filter_found_list.push tuple
        
        found_list = filter_found_list
      
      # ###################################################################################################
      
      if found_list.length == 0
        throw new Error "type inference stuck bin_op #{root.op} invalid a=#{a} b=#{b} ret=#{ret}"
      else if found_list.length == 1
        [a, b, ret] = found_list[0]
        root.a.type = ti.type_spread_left root.a.type, new Type(a), ctx
        root.b.type = ti.type_spread_left root.b.type, new Type(b), ctx
        root.type   = ti.type_spread_left root.type,   new Type(ret), ctx
      else
        if bruteforce_a
          a_type_list = []
          for tuple in found_list
            a_type_list.upush tuple[0]
          if a_type_list.length == 0
            perr "bruteforce stuck bin_op #{root.op} caused a can't be any type"
          else if a_type_list.length == 1
            root.a.type = ti.type_spread_left root.a.type, new Type(a_type_list[0]), ctx
          else
            if new_type = get_list_sign a_type_list
              root.a.type = ti.type_spread_left root.a.type, new Type(new_type), ctx
        
        if bruteforce_b
          b_type_list = []
          for tuple in found_list
            b_type_list.upush tuple[1]
          if b_type_list.length == 0
            perr "bruteforce stuck bin_op #{root.op} caused b can't be any type"
          else if b_type_list.length == 1
            root.b.type = ti.type_spread_left root.b.type, new Type(b_type_list[0]), ctx
          else
            if new_type = get_list_sign b_type_list
              root.b.type = ti.type_spread_left root.b.type, new Type(new_type), ctx
        
        if bruteforce_ret
          ret_type_list = []
          for tuple in found_list
            ret_type_list.upush tuple[2]
          if ret_type_list.length == 0
            perr "bruteforce stuck bin_op #{root.op} caused ret can't be any type"
          else if ret_type_list.length == 1
            root.type = ti.type_spread_left root.type, new Type(ret_type_list[0]), ctx
          else
            if new_type = get_list_sign ret_type_list
              root.type = ti.type_spread_left root.type, new Type(new_type), ctx
      
      root.type
    
    when "Un_op"
      @walk root.a, ctx
      
      if root.op == "DELETE"
        if root.a.constructor.name == "Bin_op"
          if root.a.op == "INDEX_ACCESS"
            if root.a.a.type?.main == "array"
              return root.type
            if root.a.a.type?.main == "map"
              return root.type
      
      bruteforce_a  = ti.is_not_defined_type root.a.type
      bruteforce_ret= ti.is_not_defined_type root.type
      a   = (root.a.type or "").toString()
      ret = (root.type   or "").toString()
      
      if !list = ti.un_op_ret_type_map_list[root.op]
        throw new Error "unknown un_op #{root.op}"
      # filter for fully defined types
      found_list = []
      for tuple in list
        continue if tuple[0] != a   and !bruteforce_a
        continue if tuple[1] != ret and !bruteforce_ret
        found_list.push tuple
      
      # filter for partially defined types
      if ti.is_number_type root.a.type
        filter_found_list = []
        for tuple in found_list
          continue if !config.any_int_type_map.hasOwnProperty tuple[0]
          filter_found_list.push tuple
        
        found_list = filter_found_list
      
      if ti.is_number_type root.type
        filter_found_list = []
        for tuple in found_list
          continue if !config.any_int_type_map.hasOwnProperty tuple[1]
          filter_found_list.push tuple
        
        found_list = filter_found_list
      
      # ###################################################################################################
      
      if found_list.length == 0
        throw new Error "type inference stuck un_op #{root.op} invalid a=#{a} ret=#{ret}"
      else if found_list.length == 1
        [a, ret] = found_list[0]
        root.a.type = ti.type_spread_left root.a.type, new Type(a), ctx
        root.type   = ti.type_spread_left root.type,   new Type(ret), ctx
      else
        if bruteforce_a
          a_type_list = []
          for tuple in found_list
            a_type_list.upush tuple[0]
          if a_type_list.length == 0
            throw new Error "type inference bruteforce stuck un_op #{root.op} caused a can't be any type"
          else if a_type_list.length == 1
            root.a.type = ti.type_spread_left root.a.type, new Type(a_type_list[0]), ctx
          else
            if new_type = get_list_sign a_type_list
              root.a.type = ti.type_spread_left root.a.type, new Type(new_type), ctx
        
        if bruteforce_ret
          ret_type_list = []
          for tuple in found_list
            ret_type_list.upush tuple[1]
          if ret_type_list.length == 0
            throw new Error "type inference bruteforce stuck un_op #{root.op} caused ret can't be any type"
          else if ret_type_list.length == 1
            root.type = ti.type_spread_left root.type, new Type(ret_type_list[0]), ctx
          else
            if new_type = get_list_sign ret_type_list
              root.type = ti.type_spread_left root.type, new Type(new_type), ctx
      
      root.type
    
    when "Field_access"
      root_type = @walk(root.t, ctx)
      
      field_map = {}
      if root_type
        switch root_type.main
          when "array"
            field_map = ti.array_field_map
          
          when "bytes"
            field_map = ti.bytes_field_map
          
          when "address"
            field_map = ti.address_field_map
          
          when "struct"
            field_map = root_type.field_map
          
          when "enum"
            field_map = root_type.field_map
          
          else
            class_decl = ctx.check_type root_type.main
            field_map = class_decl._prepared_field2type
      
      if !field_map.hasOwnProperty root.name
        # perr root.t
        # perr field_map
        perr "CRITICAL WARNING unknown field. '#{root.name}' at type '#{root_type}'. Allowed fields [#{Object.keys(field_map).join ', '}]"
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
            perr "CRITICAL WARNING skip super() call"
            for arg in root.arg_list
              @walk arg, ctx
            
            return root.type
        
        when "Field_access"
          if root.fn.t.constructor.name == "Var"
            if root.fn.t.name == "super"
              perr "CRITICAL WARNING skip super.fn call"
              for arg in root.arg_list
                @walk arg, ctx
              
              return root.type
      
      root_type = @walk root.fn, ctx
      root_type = ti.type_resolve root_type, ctx
      if !root_type
        perr "CRITICAL WARNING can't resolve function type for Fn_call"
        return root.type
      
      if root_type.main == "function2_pure"
        offset = 0
      else
        offset = 2
      
      for arg,i in root.arg_list
        @walk arg, ctx
        if root_type.main != "struct"
          expected_type = root_type.nest_list[0].nest_list[i+offset]
          arg.type = ti.type_spread_left arg.type, expected_type, ctx
      
      if root_type.main == "struct"
        # this is contract(address) case
        if root.arg_list.length != 1
          perr "CRITICAL WARNING contract(address) call should have 1 argument. real=#{root.arg_list.length}"
          return root.type
        [arg] = root.arg_list
        arg.type = ti.type_spread_left arg.type, new Type("address"), ctx
        root.type = ti.type_spread_left root.type, root_type, ctx
      else
        root.type = ti.type_spread_left root.type, root_type.nest_list[1].nest_list[offset], ctx
    
    when "Struct_init"        
      root_type = @walk root.fn, ctx
      root_type = ti.type_resolve root_type, ctx
      if !root_type
        perr "CRITICAL WARNING can't resolve function type for Struct_init"
        return root.type
      for arg,i in root.val_list
        @walk arg, ctx
      root.type
    
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
        @walk root.assign_value, ctx
      ctx.var_map[root.name] = root.type
      null
    
    when "Var_decl_multi"
      if root.assign_value
        root.assign_value.type = ti.type_spread_left root.assign_value.type, root.type, ctx
        @walk root.assign_value, ctx
      
      for decl in root.list
        ctx.var_map[decl.name] = decl.type
      
      null
    
    when "Throw"
      if root.t
        @walk root.t, ctx
      null
    
    when "Scope"
      ctx_nest = ctx.mk_nest()
      for v in root.list
        if v.constructor.name == "Class_decl"
          ti.class_prepare v, ctx
      for v in root.list
        @walk v, ctx_nest
      
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
        
        @walk v, ctx
      null
    
    when "Class_decl"
      ti.class_prepare root, ctx
      
      ctx_nest = ctx.mk_nest()
      ctx_nest.current_class = root
      
      for k,v of root._prepared_field2type
        ctx_nest.var_map[k] = v
      
      # ctx_nest.var_map["this"] = new Type root.name
      @walk root.scope, ctx_nest
      root.type
    
    when "Fn_decl_multiret"
      if root.state_mutability == "pure"
        complex_type = new Type "function2_pure"
      else
        complex_type = new Type "function2"
      complex_type.nest_list.push root.type_i
      complex_type.nest_list.push root.type_o
      ctx.var_map[root.name] = complex_type
      ctx_nest = ctx.mk_nest()
      ctx_nest.parent_fn = root
      for name,k in root.arg_name_list
        type = root.type_i.nest_list[k]
        ctx_nest.var_map[name] = type
      @walk root.scope, ctx_nest
      root.type
    
    when "PM_switch"
      null
    
    # ###################################################################################################
    #    control flow
    # ###################################################################################################
    when "If"
      @walk(root.cond, ctx)
      @walk(root.t, ctx.mk_nest())
      @walk(root.f, ctx.mk_nest())
      null
    
    when "While"
      @walk root.cond, ctx.mk_nest()
      @walk root.scope, ctx.mk_nest()
      null
    
    when "Enum_decl"
      ctx.type_map[root.name] = root
      for decl in root.value_list
        ctx.var_map[decl.name] = decl.type
        
      new Type "enum"
    
    when "Type_cast"
      @walk root.t, ctx
      root.type
    
    when "Ternary"
      @walk root.cond, ctx
      t = @walk root.t, ctx
      f = @walk root.f, ctx
      root.t.type = ti.type_spread_left root.t.type, root.f.type, ctx
      root.f.type = ti.type_spread_left root.f.type, root.t.type, ctx
      root.type = ti.type_spread_left root.type, root.t.type, ctx
      root.type
    
    when "New"
      # TODO check suitable constructor
      for arg in root.arg_list
        @walk arg, ctx
      root.type
    
    when "Tuple"
      for v in root.list
        @walk v, ctx
      
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
        @walk v, ctx
      
      nest_type = null
      if root.type
        if root.type.main != "array"
          throw new Error "Array_init can have only array type"
        nest_type = root.type.nest_list[0]
      
      for v in root.list
        nest_type = ti.type_spread_left nest_type, v.type, ctx
      
      for v in root.list
        v.type = ti.type_spread_left v.type, nest_type, ctx
      
      type = new Type "array<#{nest_type}>"
      root.type = ti.type_spread_left root.type, type, ctx
      root.type
    
    when "Event_decl"
      null
    
    else
      ### !pragma coverage-skip-block ###
      perr root
      throw new Error "ti phase 2 unknown node '#{root.constructor.name}'"
