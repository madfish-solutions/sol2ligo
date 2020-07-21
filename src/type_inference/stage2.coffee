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
    # just do the same as first stage for following nodes
    when  "Var",\
          "Const",\
          "Field_access",\
          "Struct_init",\   
          "Comment",\
          "Continue",\
          "Break",\
          "Var_decl",\
          "Var_decl_multi",\
          "Throw",\
          "Scope",\
          "Ret_multi",\    
          "Class_decl",\    
          "Fn_decl_multiret",\    
          "PM_switch",\    
          "If",\    
          "While",\   
          "Enum_decl",\    
          "Type_cast",\
          "Ternary",\
          "New",\    
          "Tuple",\ 
          "Event_decl",\
          "Fn_call", \ 
          "Array_init"
      ctx.first_stage_walk root, ctx

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
      ctx.walk root.a, ctx
      
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
    
    else
      ### !pragma coverage-skip-block ###
      perr root
      throw new Error "ti phase 2 unknown node '#{root.constructor.name}'"
