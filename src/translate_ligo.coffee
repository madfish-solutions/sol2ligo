module = @
require 'fy/codegen'
config = require './config'
# ###################################################################################################
#    *_op
# ###################################################################################################

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
  
  ASS_ADD : (a, b)-> "#{a} := #{a} + #{b}"
  ASS_SUB : (a, b)-> "#{a} := #{a} - #{b}"
  ASS_MUL : (a, b)-> "#{a} := #{a} * #{b}"
  ASS_DIV : (a, b)-> "#{a} := #{a} / #{b}"
  # disabled until requested
  INDEX_ACCESS : (a, b, ctx, ast)->
    "#{a}[#{b}]"
  # INDEX_ACCESS : (a, b, ctx, ast)->
  #   ret = if ctx.lvalue
  #     "#{a}[#{b}]"
  #   else
  #     val = type2default_value ast.type
  #     "(case #{a}[#{b}] of | None -> #{val} | Some(x) -> x end)"
  #     # "get_force(#{b}, #{a})"
  # nat - nat edge case
  # SUB : (a, b, ctx, ast)->
  #   if ast.a.type.main == 't_uint256' and ast.b.type.main == 't_uint256'
  #     "abs(#{a} - #{b})"
  #   else
  #     "(#{a} - #{b})"

# ###################################################################################################
#    type trans
# ###################################################################################################

translate_type = (type, ctx)->
  switch type.main
    # ###################################################################################################
    #    scalar
    # ###################################################################################################
    when 'uint'
      'nat'
    when 'address'
      'address'
    # ###################################################################################################
    #    collections
    # ###################################################################################################
    when 'array'
      nest   = translate_type type.nest_list[0], ctx
      "list(#{nest})"
    when 'map'
      key   = translate_type type.nest_list[0], ctx
      value = translate_type type.nest_list[1], ctx
      "map(#{key}, #{value})"
    when config.storage
      config.storage
    
    # when 't_bool'
    #   'bool'
    # when 't_uint256'
    #   'nat'
    # when 't_int256'
    #   'int'
    # when 't_string_memory_ptr'
    #   'string'
    # when 't_bytes_memory_ptr'
    #   'bytes'
    # when config.storage
    #   config.storage
    else
      if ctx.type_decl_hash[type.main]
        type.main
      else
        p ctx.type_decl_hash
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
  next_gen : null
  
  is_class_decl : false
  type_decl_hash: {}
  contract_var_hash      : {}
  
  constructor:()->
    @type_decl_hash = {}
    @contract_var_hash       = {}
  
  mk_nest : ()->
    t = new module.Gen_context
    obj_set t.contract_var_hash, @contract_var_hash
    obj_set t.type_decl_hash, @type_decl_hash
    t

walk = (root, ctx)->
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
          
          """
          #{aux_decl}#{join_list jl, ''}
          """
        
        else
          if !root.original_node_type
            jl = []
            for v in root.list
              code = walk v, ctx
              code += ";" if !/;$/.test code
              jl.push code
            
            ret = jl.pop() or ''
            if 0 != ret.indexOf 'with'
              jl.push ret
              ret = ''
            
            jl = jl.filter (t)-> t != ''
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
    
    when "Bin_op"
      # TODO lvalue ctx ???
      _a = walk root.a, ctx
      _b = walk root.b, ctx
      
      ret = if op = module.bin_op_name_map[root.op]
        "(#{_a} #{op} #{_b})"
      else if cb = module.bin_op_name_cb_map[root.op]
        cb(_a, _b, ctx, root)
      else
        throw new Error "Unknown/unimplemented bin_op #{root.op}"
    
    when "Const"
      switch root.type.main
        when "uint"
          "#{root.val}n"
        when 'string'
          JSON.stringify root.val
        else
          root.val
    
    when "Field_access"
      t = walk root.t, ctx
      "#{t}.#{root.name}"
    
    when "Fn_call"
      fn = walk root.fn, ctx
      arg_list = []
      for v in root.arg_list
        arg_list.push walk v, ctx
      
      "#{fn}(#{arg_list.join ', '})"
    
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
      if ctx.is_class_decl
        ctx.contract_var_hash[name] = true
        "#{root.name}: #{translate_type root.type, ctx};"
      else
        if ast.assign_value
          val = walk ast.assign_value, ctx
          """
          const #{name} : #{type} = #{val}
          """
        else
          """
          const #{name} : #{type} = #{type2default_value ast.type}
          """
    
    when "Ret_multi"
      jl = []
      for v in root.t_list
        jl.push walk v, ctx
      """
      with (#{jl.join ', '})
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
