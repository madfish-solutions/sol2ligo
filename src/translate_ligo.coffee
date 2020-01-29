module = @
require "fy/codegen"
config = require "./config"
# ###################################################################################################
#    *_op
# ###################################################################################################
walk = null

@bin_op_name_map =
  ADD : "+"
  # SUB : "-"
  MUL : "*"
  DIV : "/"
  MOD : "mod"
  
  EQ  : "="
  NE  : "=/="
  GT  : ">"
  LT  : "<"
  GTE : ">="
  LTE : "<="
  
  BOOL_AND: "and"
  BOOL_OR : "or"

@bin_op_name_cb_map =
  ASSIGN  : (a, b)-> "#{a} := #{b}"
  BIT_AND : (a, b)-> "bitwise_and(#{a}, #{b})"
  BIT_OR  : (a, b)-> "bitwise_or(#{a}, #{b})"
  BIT_XOR : (a, b)-> "bitwise_xor(#{a}, #{b})"
  
  # disabled until requested
  INDEX_ACCESS : (a, b, ctx, ast)->
    ret = if ctx.lvalue
      "#{a}[#{b}]"
    else
      val = type2default_value ast.type
      "(case #{a}[#{b}] of | None -> #{val} | Some(x) -> x end)"
      # "get_force(#{b}, #{a})"
  # nat - nat edge case
  SUB : (a, b, ctx, ast)->
    if ast.a.type.main == "uint" and ast.b.type.main == "uint"
      "abs(#{a} - #{b})"
    else
      "(#{a} - #{b})"

@un_op_name_cb_map =
  MINUS   : (a)->"-(#{a})"
  PLUS    : (a)->"+(#{a})"
  BIT_NOT : (a, ctx, ast)->
    if !ast.type
      perr "WARNING BIT_NOT ( ~#{a} ) translation can be incorrect"
    if ast.type and ast.type.main == "uint"
      "abs(not (#{a}))"
    else
      "not (#{a})"
  BOOL_NOT: (a)->"not (#{a})"
  
  DELETE : (a, ctx, ast)->
    if ast.a.constructor.name != "Bin_op"
      throw new Error "can't compile DELETE operation for non 'delete a[b]' like construction. Reason not Bin_op"
    if ast.a.op != "INDEX_ACCESS"
      throw new Error "can't compile DELETE operation for non 'delete a[b]' like construction. Reason not INDEX_ACCESS"
    # BUG WARNING!!! re-walk can be dangerous (sink_list can be re-emitted)
    # экранируемся от повторгного inject'а в sink_list
    nest_ctx = ctx.mk_nest()
    bin_op_a = walk ast.a.a, nest_ctx
    bin_op_b = walk ast.a.b, nest_ctx
    "remove #{bin_op_b} from map #{bin_op_a}"

# ###################################################################################################
#    type trans
# ###################################################################################################

@translate_type = translate_type = (type, ctx)->
  switch type.main
    # ###################################################################################################
    #    scalar
    # ###################################################################################################
    when "bool"
      "bool"
    
    when "uint"
      "nat"
    
    when "int"
      "int"
    
    when "int8"
      "int"
    
    when "uint8"
      "nat"
    
    when "bytes"
      "bytes"
    
    when "string"
      "string"
    
    when "address"
      "address"
    
    when "built_in_op_list"
      "list(operation)"
    
    # ###################################################################################################
    #    collections
    # ###################################################################################################
    when "array"
      nest   = translate_type type.nest_list[0], ctx
      # "list(#{nest})"
      "map(nat, #{nest})"
    
    when "map"
      key   = translate_type type.nest_list[0], ctx
      value = translate_type type.nest_list[1], ctx
      "map(#{key}, #{value})"
    
    when config.storage
      config.storage
    
    # when "t_bytes_memory_ptr"
    #   "bytes"
    # when config.storage
    #   config.storage
    else
      if ctx.type_decl_hash[type.main]
        type.main
      else
        ### !pragma coverage-skip-block ###
        puts ctx.type_decl_hash
        throw new Error("unknown solidity type '#{type}'")

@type2default_value = type2default_value = (type)->
  switch type.main
    when "bool"
      "False"
    
    when "uint"
      "0n"
    
    when "int"
      "0"
    
    when "address"
      "(#{JSON.stringify config.default_address} : address)"
    
    when "built_in_op_list"
      "(nil: list(operation))"
    
    when "map"
      "map end : #{translate_type type}"
    
    when "string"
      '""'
    
    else
      ### !pragma coverage-skip-block ###
      throw new Error("unknown solidity type '#{type}'")
# ###################################################################################################
#    translate_var_name
# ###################################################################################################
reserved_hash =
  # https://gitlab.com/ligolang/ligo/blob/dev/src/passes/operators/operators.ml
  "get_force"       : true
  "get_chain_id"    : true
  "transaction"     : true
  "get_contract"    : true
  "get_entrypoint"  : true
  "size"            : true
  "int"             : true
  "abs"             : true
  "is_nat"          : true
  "amount"          : true
  "balance"         : true
  "now"             : true
  "unit"            : true
  "source"          : true
  "sender"          : true
  "failwith"        : true
  "bitwise_or"      : true
  "bitwise_and"     : true
  "bitwise_xor"     : true
  "string_concat"   : true
  "string_slice"    : true
  "crypto_check"    : true
  "crypto_hash_key" : true
  "bytes_concat"    : true
  "bytes_slice"     : true
  "bytes_pack"      : true
  "bytes_unpack"    : true
  "set_empty"       : true
  "set_mem"         : true
  "set_add"         : true
  "set_remove"      : true
  "set_iter"        : true
  "set_fold"        : true
  "list_iter"       : true
  "list_fold"       : true
  "list_map"        : true
  "map_iter"        : true
  "map_map"         : true
  "map_fold"        : true
  "map_remove"      : true
  "map_update"      : true
  "map_get"         : true
  "map_mem"         : true
  "sha_256"         : true
  "sha_512"         : true
  "blake2b"         : true
  "cons"            : true
  "EQ"              : true
  "NEQ"             : true
  "NEG"             : true
  "ADD"             : true
  "SUB"             : true
  "TIMES"           : true
  "DIV"             : true
  "MOD"             : true
  "NOT"             : true
  "AND"             : true
  "OR"              : true
  "GT"              : true
  "GE"              : true
  "LT"              : true
  "LE"              : true
  "CONS"            : true
  "address"         : true
  "self_address"    : true
  "implicit_account": true
  "set_delegate"    : true
  "to"              : true
  "args"            : true
  # note not reserved, but we don't want collide with types
  
  "map"             : true

reserved_hash[config.contract_storage] = true
reserved_hash[config.op_list] = true

@translate_var_name = translate_var_name = (name)->
  if reserved_hash[name]
    "#{config.reserved}__#{name}"
  else
    if name[0] == "_"
      "#{config.fix_underscore}_"+name
    else
      # first letter should be lowercase
      name.substr(0,1).toLowerCase() + name.substr 1
# ###################################################################################################
#    special id, field access
# ###################################################################################################
spec_id_trans_hash =
  "now"       : "abs(now - (\"1970-01-01T00:00:00Z\": timestamp))"
  "msg.sender": "sender"
  "msg.value" : "(amount / 1tz)"

# ###################################################################################################

class @Gen_context
  next_gen          : null
  
  use_op_list       : true
  is_class_decl     : false
  lvalue            : false
  type_decl_hash    : {}
  contract_var_hash : {}
  
  trim_expr         : ""
  sink_list         : []
  tmp_idx           : 0
  
  constructor:()->
    @type_decl_hash   = {}
    @contract_var_hash= {}
    @sink_list        = []
  
  mk_nest : ()->
    t = new module.Gen_context
    t.use_op_list = @use_op_list
    obj_set t.contract_var_hash, @contract_var_hash
    obj_set t.type_decl_hash, @type_decl_hash
    t

last_bracket_state = false
walk = (root, ctx)->
  last_bracket_state = false
  switch root.constructor.name
    when "Scope"
      switch root.original_node_type
        when "SourceUnit"
          jl = []
          for v in root.list
            code = walk v, ctx
            jl.push code if code
          join_list jl, ""
        
        else
          if !root.original_node_type
            jl = []
            for v in root.list
              code = walk v, ctx
              for loc_code in ctx.sink_list
                loc_code += ";" if !/;$/.test loc_code
                jl.push loc_code
              ctx.sink_list.clear()
              # do not add e.g. tmp_XXX stmt which do nothing
              if ctx.trim_expr == code
                ctx.trim_expr = ""
                continue
              code += ";" if !/;$/.test code
              jl.push code
            
            ret = jl.pop() or ""
            if 0 != ret.indexOf "with"
              jl.push ret
              ret = ""
            
            jl = jl.filter (t)-> t != ""
            
            if !root.need_nest
              if jl.length
                body = join_list jl, ""
              else
                body = ""
            else
              if jl.length
                body = """
                block {
                  #{join_list jl, '  '}
                }
                """
              else
                body = """
                block {
                  skip
                }
                """
            ret = " #{ret}" if ret
            """
            #{body}#{ret}
            """
          else
            puts root
            throw new Error "Unknown root.original_node_type #{root.original_node_type}"
    # ###################################################################################################
    #    expr
    # ###################################################################################################
    when "Var"
      name = root.name
      return "" if name == "this"
      name = translate_var_name name if root.name_translate
      if ctx.contract_var_hash[name]
        "#{config.contract_storage}.#{name}"
      else
        if {}[root.name]? # constructor and other reserved JS stuff
          name
        else
          spec_id_trans_hash[root.name] or name
    
    when "Const"
      switch root.type.main
        when "bool"
          switch root.val
            when "true"
              "True"
            when "false"
              "False"
            else
              throw new Error "can't translate bool constant '#{root.val}'"
        
        when "uint"
          "#{root.val}n"
        
        when "uint8"
          "#{root.val}n"
        
        when "string"
          JSON.stringify root.val
        
        else
          root.val
    
    when "Bin_op"
      # TODO lvalue ctx ???
      ctx_lvalue = ctx.mk_nest()
      ctx_lvalue.lvalue = true if 0 == root.op.indexOf "ASS"
      _a = walk root.a, ctx_lvalue
      ctx.sink_list.append ctx_lvalue.sink_list
      _b = walk root.b, ctx
      
      ret = if op = module.bin_op_name_map[root.op]
        last_bracket_state = true
        "(#{_a} #{op} #{_b})"
      else if cb = module.bin_op_name_cb_map[root.op]
        cb(_a, _b, ctx, root)
      else
        throw new Error "Unknown/unimplemented bin_op #{root.op}"
    
    when "Un_op"
      a = walk root.a, ctx
      if cb = module.un_op_name_cb_map[root.op]
        cb a, ctx, root
      else
        throw new Error "Unknown/unimplemented un_op #{root.op}"
    
    when "Field_access"
      t = walk root.t, ctx
      switch root.t.type.main
        when "array"
          switch root.name
            when "length"
              "size(#{t})"
            
            else
              throw new Error "unknown array field #{root.name}"
        
        else
          if t == "" # this case
            return translate_var_name root.name, ctx
          chk_ret = "#{t}.#{root.name}"
          spec_id_trans_hash[chk_ret] or "#{t}.#{translate_var_name root.name, ctx}"
    
    when "Fn_call"
      arg_list = []
      for v in root.arg_list
        arg_list.push walk v, ctx
      
      if root.fn.constructor.name == "Field_access"
        t = walk root.fn.t, ctx
        switch root.fn.t.type.main
          when "array"
            switch root.fn.name
              when "push"
                tmp_var = "tmp_#{ctx.tmp_idx++}"
                ctx.sink_list.push "const #{tmp_var} : #{translate_type root.fn.t.type} = #{t};"
                return "#{tmp_var}[size(#{tmp_var})] := #{arg_list[0]}"
              
              else
                throw new Error "unknown array field function #{root.fn.name}"
      
      if root.fn.constructor.name == "Var"
        switch root.fn.name
          when "require", "assert"
            cond= arg_list[0]
            str = arg_list[1] or '"require fail"'
            return "if #{cond} then {skip} else failwith(#{str})"
          else
            name = root.fn.name
            name = translate_var_name name if root.fn.name_translate
            # COPYPASTED (TEMP SOLUTION)
            fn = if {}[root.fn.name]? # constructor and other reserved JS stuff
              name
            else
              spec_id_trans_hash[root.fn.name] or name
      else
        fn = walk root.fn, ctx
      
      arg_list.unshift config.contract_storage
      if ctx.use_op_list
        arg_list.unshift config.op_list
      
      type_jl = []
      for v in root.fn.type.nest_list[1].nest_list
        type_jl.push translate_type v
      
      # temp disabled
      # if type_jl[0] != config.storage
      #   "#{fn}(#{arg_list.join ', '})"
      
      tmp_var = "tmp_#{ctx.tmp_idx++}"
      ctx.sink_list.push "const #{tmp_var} : (#{type_jl.join ' * '}) = #{fn}(#{arg_list.join ', '})"
      
      if ctx.use_op_list
        ctx.sink_list.push "#{config.op_list} := #{tmp_var}.0"
        ctx.sink_list.push "#{config.contract_storage} := #{tmp_var}.1"
        ctx.trim_expr = "#{tmp_var}.2"
      else
        ctx.sink_list.push "#{config.contract_storage} := #{tmp_var}.0"
        ctx.trim_expr = "#{tmp_var}.1"
    
    when "Type_cast"
      # TODO detect 'address(0)' here
      target_type = translate_type root.target_type, ctx
      t = walk root.t, ctx
      if t == "" and target_type == "address"
        return "self_address"
      
      if target_type == "int"
        "int(abs(#{t}))"
      else if target_type == "nat"
        "abs(#{t})"
      else if target_type == "address" and t == "0"
        type2default_value root.target_type
      else
        "(#{t} : #{target_type})"
    
    # ###################################################################################################
    #    stmt
    # ###################################################################################################
    when "Comment"
      # TODO multiline comments
      if root.can_skip
        ""
      else
        "(* #{root.text} *)"
    
    when "Var_decl"
      name = root.name
      name = translate_var_name name if root.name_translate
      type = translate_type root.type, ctx
      if ctx.is_class_decl
        ctx.contract_var_hash[name] = true
        "#{name} : #{type};"
      else
        if root.assign_value
          val = walk root.assign_value, ctx
          """
          const #{name} : #{type} = #{val}
          """
        else
          """
          const #{name} : #{type} = #{type2default_value root.type}
          """
    
    when "Throw"
      if root.t
        t = walk root.t, ctx
        "failwith(#{t})"
      else
        'failwith("throw")'
    
    when "Ret_multi"
      jl = []
      for v,idx in root.t_list
        jl.push walk v, ctx
        
      """
      with (#{jl.join ', '})
      """
    
    when "If"
      cond = walk root.cond,  ctx
      cond = "(#{cond})" if !last_bracket_state
      t    = walk root.t,     ctx
      f    = walk root.f,     ctx
      """
      if #{cond} then #{t} else #{f};
      """
    
    when "While"
      cond = walk root.cond,  ctx
      cond = "(#{cond})" if !last_bracket_state
      scope= walk root.scope, ctx
      """
      while #{cond} #{scope};
      """
      
    when "PM_switch"
      cond = walk root.cond, ctx
      ctx = ctx.mk_nest()
      jl = []
      for _case in root.scope.list
        # register
        ctx.type_decl_hash[_case.var_decl.type.main] = true
        
        case_scope = walk _case.scope, ctx
        
        jl.push "| #{_case.struct_name}(#{_case.var_decl.name}) -> #{case_scope}"
      
      """
      case #{cond} of
      #{join_list jl, ''}
      end
      """
    
    when "Fn_decl_multiret"
      ctx = ctx.mk_nest()
      arg_jl = []
      for v,idx in root.arg_name_list
        if ctx.use_op_list
          v = translate_var_name v unless idx <= 1
        else
          v = translate_var_name v unless idx == 0
        type = translate_type root.type_i.nest_list[idx], ctx
        arg_jl.push "const #{v} : #{type}"
      
      ret_jl = []
      for v in root.type_o.nest_list
        type = translate_type v, ctx
        ret_jl.push "#{type}"
      
      body = walk root.scope, ctx
      """
      function #{translate_var_name root.name} (#{arg_jl.join '; '}) : (#{ret_jl.join ' * '}) is
        #{make_tab body, '  '}
      """
    
    when "Class_decl"
      return "" if root.need_skip
      ctx.type_decl_hash[root.name] = true
      ctx = ctx.mk_nest()
      ctx.is_class_decl = true
      
      # stage 1 collect declarations
      field_decl_jl = []
      for v in root.scope.list
        switch v.constructor.name
          when "Var_decl"
            field_decl_jl.push walk v, ctx
          when "Fn_decl_multiret"
            ctx.contract_var_hash[v.name] = true
          when "Enum_decl"
            "skip"
          when "Class_decl"
            ctx.sink_list.push walk v, ctx
          when "Comment"
            ctx.sink_list.push walk v, ctx
          else
            throw new Error "unknown v.constructor.name #{v.constructor.name}"
      
      jl = []
      jl.append ctx.sink_list
      ctx.sink_list.clear()
      
      # stage 2 collect fn implementations
      for v in root.scope.list
        switch v.constructor.name
          when "Var_decl"
            "skip"
          when "Fn_decl_multiret", "Enum_decl"
            jl.push walk v, ctx
          when "Class_decl", "Comment"
            "skip"
          else
            throw new Error "unknown v.constructor.name #{v.constructor.name}"
      
      if root.is_contract
        name = config.storage
      else
        name = translate_var_name root.name
      
      if field_decl_jl.length
        jl.unshift """
        type #{name} is record
          #{join_list field_decl_jl, '  '}
        end;
        """
      else
        jl.unshift """
        type #{name} is record
          #{config.empty_state} : int;
        end;
        """
      
      jl.join "\n\n"
    
    when "Enum_decl"
      jl = []
      # register global type
      ctx.type_decl_hash[root.name] = true
      for v in root.value_list
        # register global value
        ctx.contract_var_hash[v.name] = true
        
        # not covered by tests yet
        aux = ""
        if v.type
          aux = " of #{translate_type v.type, ctx}"
        
        jl.push "| #{v.name}#{aux}"
        # jl.push "| #{v.name}"
      
      """
      type #{translate_var_name root.name} is
        #{join_list jl, '  '};
      """
    
    when "Ternary"
      cond = walk root.cond,  ctx
      t    = walk root.t,     ctx
      f    = walk root.f,     ctx
      """
      (case #{cond} of | True -> #{t} | False -> #{f} end)
      """
    
    when "New"
      # TODO: should we translate type here?
      arg_list = []
      for v in root.arg_list
        arg_list.push walk v, ctx
      
      args = """#{join_list arg_list, ', '}"""
      translated_type = translate_type root.cls, ctx
      
      if root.cls.main == "array"
        """map end (* args: #{args} *)"""
      else if translated_type == "bytes"
        """bytes_pack(unit) (* args: #{args} *)"""
      else
        """
        #{translated_type}(#{args})
        """


    else
      if ctx.next_gen?
        ctx.next_gen root, ctx
      else
        # TODO gen extentions
        puts root
        throw new Error "Unknown root.constructor.name #{root.constructor.name}"

@gen = (root, opt = {})->
  opt.op_list ?= true
  ctx = new module.Gen_context
  ctx.next_gen = opt.next_gen
  ctx.use_op_list = opt.op_list
  walk root, ctx
