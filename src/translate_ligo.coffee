module = @
require 'fy/codegen'
config = require './config'
# ###################################################################################################
#    *_op
# ###################################################################################################
walk = null

@bin_op_name_map =
  ADD : '+'
  # SUB : '-'
  MUL : '*'
  DIV : '/'
  MOD : 'mod'
  
  
  EQ : '='
  NE : '=/='
  GT : '>'
  LT : '<'
  GTE: '>='
  LTE: '<='
  
  
  BOOL_AND: 'and'
  BOOL_OR : 'or'

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
    if ast.a.type.main == 'uint' and ast.b.type.main == 'uint'
      "abs(#{a} - #{b})"
    else
      "(#{a} - #{b})"

@un_op_name_cb_map =
  MINUS   : (a)->"-(#{a})"
  PLUS    : (a)->"+(#{a})"
  BIT_NOT : (a)->"not (#{a})"
  
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
    "remove #{bin_op_b} from #{bin_op_a} array"

# ###################################################################################################
#    type trans
# ###################################################################################################

translate_type = (type, ctx)->
  switch type.main
    # ###################################################################################################
    #    scalar
    # ###################################################################################################
    when 'bool'
      'bool'
    when 'uint'
      'nat'
    when 'int'
      'int'
    when 'int8'
      'int'
    when 'uint8'
      'nat'
    when 'string'
      'string'
    when 'address'
      'address'
    # ###################################################################################################
    #    collections
    # ###################################################################################################
    when 'array'
      nest   = translate_type type.nest_list[0], ctx
      # "list(#{nest})"
      "map(nat, #{nest})"
    when 'map'
      key   = translate_type type.nest_list[0], ctx
      value = translate_type type.nest_list[1], ctx
      "map(#{key}, #{value})"
    when config.storage
      config.storage
    
    # when 't_bytes_memory_ptr'
    #   'bytes'
    # when config.storage
    #   config.storage
    else
      if ctx.type_decl_hash[type.main]
        type.main
      else
        ### !pragma coverage-skip-block ###
        puts ctx.type_decl_hash
        throw new Error("unknown solidity type '#{type}'")

type2default_value = (type)->
  switch type.toString()
    # when 't_bool'
      # 'false'
    when 'uint'
      '0n'
    when 'int'
      '0'
    when 'address'
      '0'
    # when 't_string_memory_ptr'
      # '""'
    else
      ### !pragma coverage-skip-block ###
      throw new Error("unknown solidity type '#{type}'")
# ###################################################################################################
#    translate_var_name
# ###################################################################################################
reserved_hash =
  sender : true
  source : true
  amount : true
  now    : true

translate_var_name = (name)->
  if reserved_hash[name]
    "reserved__#{name}"
  else
    name
# ###################################################################################################

class @Gen_context
  next_gen          : null
  
  is_class_decl     : false
  lvalue            : false
  type_decl_hash    : {}
  contract_var_hash : {}
  
  trim_expr         : ''
  sink_list         : []
  tmp_idx           : 0
  
  constructor:()->
    @type_decl_hash   = {}
    @contract_var_hash= {}
    @sink_list        = []
  
  mk_nest : ()->
    t = new module.Gen_context
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
            jl.push walk v, ctx
          join_list jl, ''
        
        when "ContractDefinition"
          ctx = ctx.mk_nest()
          ctx.is_class_decl = true
          field_decl_jl = []
          for v in root.list
            switch v.constructor.name
              when "Var_decl"
                field_decl_jl.push walk v, ctx
              when "Fn_decl_multiret"
                'skip'
              else
                throw new Error "unknown v.constructor.name #{v.constructor.name}"
          
          jl = []
          for v in root.list
            switch v.constructor.name
              when "Var_decl"
                'skip'
              when "Fn_decl_multiret"
                jl.push walk v, ctx
              else
                throw new Error "unknown v.constructor.name #{v.constructor.name}"
          
          aux_decl = ""
          if field_decl_jl.length
            aux_decl = """
            type #{config.storage} is record
              #{join_list field_decl_jl, '  '}
            end;
            
            """
          else
            aux_decl = """
            type #{config.storage} is record
              _empty_state: int;
            end;
            
            """
          
          """
          #{aux_decl}#{join_list jl, ''}
          """
        
        else
          if !root.original_node_type
            jl = []
            for v in root.list
              code = walk v, ctx
              code += ";" if !/;$/.test code
              for loc_code in ctx.sink_list
                loc_code += ";" if !/;$/.test loc_code
                jl.push loc_code
              ctx.sink_list.clear()
              # do not add e.g. tmp_XXX stmt which do nothing
              if ctx.trim_expr == code
                ctx.trim_expr = ''
                continue
              jl.push code
            
            ret = jl.pop() or ""
            if 0 != ret.indexOf 'with'
              jl.push ret
              ret = ""
            
            jl = jl.filter (t)-> t != ""
            if root._phantom
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
      name = translate_var_name root.name
      if ctx.contract_var_hash[name]
        "#{config.contract_storage}.#{name}"
      else
        name
    
    when "Const"
      switch root.type.main
        when "uint"
          "#{root.val}n"
        when 'string'
          JSON.stringify root.val
        else
          root.val
    
    when "Bin_op"
      # TODO lvalue ctx ???
      ctx_lvalue = ctx.mk_nest()
      ctx_lvalue.lvalue = true if 0 == root.op.indexOf 'ASS'
      _a = walk root.a, ctx_lvalue
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
          "#{t}.#{root.name}"
    
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
      
      fn = walk root.fn, ctx
      
      arg_list.unshift config.contract_storage
      
      type_jl = []
      for v in root.fn.type.nest_list[1].nest_list
        type_jl.push translate_type v
      
      if type_jl[0] != config.storage
        "#{fn}(#{arg_list.join ', '})"
      else
        tmp_var = "tmp_#{ctx.tmp_idx++}"
        ctx.sink_list.push "const #{tmp_var} : (#{type_jl.join ' * '}) = #{fn}(#{arg_list.join ', '})"
        ctx.sink_list.push "#{config.contract_storage} := #{tmp_var}.0"
        ctx.trim_expr = "#{tmp_var}.1"
    
    when "Type_cast"
      xxx
    
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
      name = translate_var_name root.name
      type = translate_type root.type, ctx
      if ctx.is_class_decl
        ctx.contract_var_hash[name] = true
        "#{root.name}: #{type};"
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
    
    when "Ret_multi"
      jl = []
      for v in root.t_list
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
    
    when "Fn_decl_multiret"
      ctx = ctx.mk_nest()
      arg_jl = []
      for v,idx in root.arg_name_list
        v = translate_var_name v
        type = translate_type root.type_i.nest_list[idx], ctx
        arg_jl.push "const #{v} : #{type}"
      
      ret_jl = []
      for v in root.type_o.nest_list
        type = translate_type v, ctx
        ret_jl.push "#{type}"
      
      body = walk root.scope, ctx
      """
      
      function #{root.name} (#{arg_jl.join '; '}) : (#{ret_jl.join ' * '}) is
        #{make_tab body, '  '}
      """
    
    when "Class_decl"
      ctx.type_decl_hash[root.name] = true
      ctx = ctx.mk_nest()
      ctx.is_class_decl = true
      walk root.scope, ctx
    
    else
      if ctx.next_gen?
        ctx.next_gen root, ctx
      else
        # TODO gen extentions
        puts root
        throw new Error "Unknown root.constructor.name #{root.constructor.name}"

@gen = (root, opt = {})->
  ctx = new module.Gen_context
  ctx.next_gen = opt.next_gen
  walk root, ctx
