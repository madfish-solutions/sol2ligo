module = @
require "fy/codegen"
config = require "./config"
module.warning_counter = 0
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
  POW : "LIGO_IMPLEMENT_ME_PLEASE_POW"
  
  BOOL_AND: "and"
  BOOL_OR : "or"

string2bytes = (val)->
  ret = ["0x"]
  for ch in val
    ret.push ch.charCodeAt(0).rjust 2, "0"
  
  if ret.length == 1
    return "(\"00\": bytes)"
  ret.join ""

some2nat = (val, type)->
  if type.match /^int\d{0,3}$/
    val = "abs(#{val})"
  if type.match /^byte[s]?\d{0,2}$/
    val = "(case (bytes_unpack (#{val}) : option (nat)) of | Some(a) -> a | None -> 0n end)"
  val

number2bytes = (val, precision = 32)->
  ret = []
  for i in [0 ... precision]
    hex = val & 0xFF
    ret.push hex.toString(16).rjust 2, "0"
    val >>= 8
  ret.push "0x"
  ret.reverse()
  ret.join ""

@bin_op_name_cb_map =
  ASSIGN  : (a, b, ctx, ast)->
    if config.bytes_type_hash.hasOwnProperty(ast.a.type.main) and ast.b.type.main == "string" and ast.b.constructor.name == "Const"
      b = string2bytes ast.b.val
    "#{a} := #{b}"
  BIT_AND : (a, b, ctx, ast) ->
    a = some2nat(a, ast.a.type.main)
    b = some2nat(b, ast.b.type.main)
    "bitwise_and(#{a}, #{b})"
  BIT_OR  : (a, b, ctx, ast) -> 
    a = some2nat(a, ast.a.type.main)
    b = some2nat(b, ast.b.type.main)
    "bitwise_or(#{a}, #{b})"
  BIT_XOR : (a, b, ctx, ast) -> 
    a = some2nat(a, ast.a.type.main)
    b = some2nat(b, ast.b.type.main)
    "bitwise_xor(#{a}, #{b})"
  SHR     : (a, b, ctx, ast) ->
    a = some2nat(a, ast.a.type.main)
    b = some2nat(b, ast.b.type.main)
    "bitwise_lsr(#{a}, #{b})"
  SHL     : (a, b, ctx, ast) -> 
    a = some2nat(a, ast.a.type.main)
    b = some2nat(b, ast.b.type.main)
    "bitwise_lsl(#{a}, #{b})"
  
  # disabled until requested
  INDEX_ACCESS : (a, b, ctx, ast)->
    ret = if ctx.lvalue
      "#{a}[#{b}]"
    else
      val = type2default_value ast.type, ctx
      "(case #{a}[#{b}] of | None -> #{val} | Some(x) -> x end)"
      # "get_force(#{b}, #{a})"
  # nat - nat edge case
  SUB : (a, b, ctx, ast)->
    if config.uint_type_hash.hasOwnProperty(ast.a.type.main) and config.uint_type_hash.hasOwnProperty(ast.b.type.main)
      "abs(#{a} - #{b})"
    else
      "(#{a} - #{b})"

@un_op_name_cb_map =
  MINUS   : (a)->"-(#{a})"
  PLUS    : (a)->"+(#{a})"
  BIT_NOT : (a, ctx, ast)->
    if !ast.type
      perr "WARNING BIT_NOT ( ~#{a} ) translation can be incorrect"
      module.warning_counter++
    if ast.type and config.uint_type_hash.hasOwnProperty ast.type.main
      "abs(not (#{a}))"
    else
      "not (#{a})"
  BOOL_NOT: (a)->"not (#{a})"
  RET_INC : (a, ctx)->
    perr "RET_INC can have not fully correct implementation"
    module.warning_counter++
    ctx.sink_list.push "#{a} := #{a} + 1"
    ctx.trim_expr = "(#{a} - 1)"
  
  RET_DEC : (a, ctx)->
    perr "RET_DEC can have not fully correct implementation"
    module.warning_counter++
    ctx.sink_list.push "#{a} := #{a} - 1"
    ctx.trim_expr = "(#{a} + 1)"
  
  INC_RET : (a, ctx)->
    perr "INC_RET can have not fully correct implementation"
    module.warning_counter++
    ctx.sink_list.push "#{a} := #{a} + 1"
    ctx.trim_expr = "#{a}"
  
  DEC_RET : (a, ctx)->
    perr "DEC_RET can have not fully correct implementation"
    module.warning_counter++
    ctx.sink_list.push "#{a} := #{a} - 1"
    ctx.trim_expr = "#{a}"
  
  DELETE : (a, ctx, ast)->
    if ast.a.constructor.name != "Bin_op"
      throw new Error "can't compile DELETE operation for non 'delete a[b]' like construction. Reason not Bin_op"
    if ast.a.op != "INDEX_ACCESS"
      throw new Error "can't compile DELETE operation for non 'delete a[b]' like construction. Reason not INDEX_ACCESS"
    # BUG WARNING!!! re-walk can be dangerous (sink_list can be re-emitted)
    # protects from reinjection in sink_list
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

    when "Unit"
      "Unit"
        
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
    
    when "tuple"
      list = []
      for v in type.nest_list
        list.push translate_type v, ctx
      "(#{list.join ' * '})"
    
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
      if type.main.match /^contract/
        type.main
      else if ctx.type_decl_hash?.hasOwnProperty type.main
        name = type.main.replace /\./g, "_"
        is_struct = ((ctx.current_class and ctx.type_decl_hash["#{ctx.current_class.name}_#{name}"]) or ctx.type_decl_hash[name]) and ctx.type_decl_hash[name]?.constructor.name == "Class_decl"
        is_enum = ctx.type_decl_hash[name]?.constructor.name == "Enum_decl" 
        if ctx.current_class and is_struct 
          name = "#{ctx.current_class.name}_#{name}"
        if name != "router_enum" and is_enum
          name = "nat"
        name = translate_var_name name, ctx
        name
      else if type.main.match /^byte[s]?\d{0,2}$/
        "bytes"
      else if config.uint_type_hash.hasOwnProperty type.main
        "nat"
      else if config.int_type_hash.hasOwnProperty type.main
        "int"
      # temporary hack for state
      else if type.main.match ///^#{config.storage}_///
        type.main
      else
        perr "CRITICAL WARNING. translate_type unknown solidity type '#{type}'"
        "UNKNOWN_TYPE_#{type}"

@type2default_value = type2default_value = (type, ctx)->
  if config.uint_type_hash.hasOwnProperty type.main
    return "0n"
  
  if config.int_type_hash.hasOwnProperty type.main
    return "0"
  
  if config.bytes_type_hash.hasOwnProperty type.main
    return "(\"00\": bytes)"
  
  switch type.main
    when "bool"
      "False"
    
    when "address"
      "(#{JSON.stringify config.default_address} : address)"
    
    when "built_in_op_list"
      "(nil: list(operation))"

    when "contract"
      "contract(unit)"
    
    when "map", "array"
      "(map end : #{translate_type type, ctx})"
    
    when "string"
      '""'
    
    else
      if ctx.type_decl_hash.hasOwnProperty type.main
        t = ctx.type_decl_hash[type.main]
        # take very first value in enum as default
        if t.constructor.name == "Enum_decl"
          name = t.value_list[0].name
          if ctx.current_class.name and t.name != "router_enum"
            prefix = ""
            if ctx.current_class.name
              prefix = "#{ctx.current_class.name}_"
            return "#{translate_var_name prefix + t.name}_#{name}"
          else
            return "#{name}(unit)"
        if t.constructor.name == "Class_decl"
          name = type.main
          if ctx.current_class.name
            name = "#{ctx.current_class.name}_#{type.main}"
          return "#{translate_var_name name}_default"

      perr "CRITICAL WARNING. type2default_value unknown solidity type '#{type}'"
      "UNKNOWN_TYPE_DEFAULT_VALUE_#{type}"

{translate_var_name} = require "./translate_var_name"
# ###################################################################################################
#    special id, field access
# ###################################################################################################
spec_id_trans_hash =
  "now"             : "abs(now - (\"1970-01-01T00:00:00Z\": timestamp))"
  "msg.sender"      : "sender"
  "tx.origin"       : "source"
  "block.timestamp" : "abs(now - (\"1970-01-01T00:00:00Z\": timestamp))"
  "msg.value"       : "(amount / 1mutez)"
  "abi.encodePacked": ""

bad_spec_id_trans_hash =
  "block.coinbase"  : config.default_address
  "block.difficulty": "0n"
  "block.gaslimit"  : "0n"
  "block.number"    : "0n"
  "msg.data"        : "(\"00\": bytes)"
  "msg.gas"         : "0n"
  "msg.sig"         : "(\"00\": bytes)"
  "tx.gasprice"     : "0n"

warning_once_hash = {}
spec_id_translate = (t, name)->
  if spec_id_trans_hash.hasOwnProperty t
    spec_id_trans_hash[t]
  else if bad_spec_id_trans_hash.hasOwnProperty t
    val = bad_spec_id_trans_hash[t]
    if !warning_once_hash.hasOwnProperty t
      warning_once_hash.hasOwnProperty[t] = true
      perr "CRITICAL WARNING we don't have proper translation for ethereum '#{t}', so it would be translated as '#{val}'. That's incorrect"
    val
  else
    name
# ###################################################################################################

class @Gen_context
  parent            : null
  next_gen          : null
  
  current_class     : null
  is_class_scope    : false
  lvalue            : false
  type_decl_hash    : {}
  contract_var_hash : {}
  
  contract          : false
  trim_expr         : ""
  storage_sink_list : {}
  sink_list         : []
  type_decl_sink_list: []
  structs_default_list: []
  enum_list: []
  tmp_idx           : 0
  
  constructor:()->
    @type_decl_hash   = {}
    @contract_var_hash= {}
    @storage_sink_list= {}
    @sink_list        = []
    @type_decl_sink_list= []
    @structs_default_list= []
    @enum_list= []
    @contract = false
  
  mk_nest : ()->
    t = new module.Gen_context
    t.parent = @
    t.current_class = @current_class
    obj_set t.contract_var_hash, @contract_var_hash
    obj_set t.type_decl_hash, @type_decl_hash
    t.type_decl_sink_list = @type_decl_sink_list # Common. All will go to top
    t.structs_default_list = @structs_default_list
    t.enum_list = @enum_list
    t.contract = @contract
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
          
          if ctx.structs_default_list.length
            jl.unshift """
              #{join_list ctx.structs_default_list}
              """
          name = config.storage
          jl.unshift ""
          if Object.keys(ctx.storage_sink_list).length == 0
            jl.unshift """
              type #{name} is unit;
              """
          else
            for k,v of ctx.storage_sink_list
              if v.length == 0
                jl.unshift """
                  type #{k} is unit;
                  """
              else
                jl.unshift """
                  type #{k} is record
                    #{join_list v, '  '}
                  end;
                  """
          ctx.storage_sink_list = {} 

          if ctx.type_decl_sink_list.length
            type_decl_jl = []
            for type_decl in ctx.type_decl_sink_list
              {name, field_decl_jl} = type_decl
              if field_decl_jl.length == 0
                type_decl_jl.push """
                  type #{name} is unit;
                  """
              else
                type_decl_jl.push """
                  type #{name} is record
                    #{join_list field_decl_jl, '  '}
                  end;

                  """
            
            jl.unshift """
              #{join_list type_decl_jl}
              """
            if ctx.enum_list.length 
              jl.unshift ""
              jl.unshift """
                #{join_list ctx.enum_list}
                """
              ctx.enum_list = []
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
              if code
                if v.constructor.name not in ["Comment", "Scope"]
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
              ret = ""
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
      name = translate_var_name name, ctx if root.name_translate
      if ctx.contract_var_hash.hasOwnProperty name
        "#{config.contract_storage}.#{name}"
      else
        spec_id_translate root.name, name
    
    when "Const"
      if !root.type
        puts root
        throw new Error "Can't type inference"
      
      if config.uint_type_hash.hasOwnProperty root.type.main
        return "#{root.val}n"
      
      switch root.type.main
        when "bool"
          switch root.val
            when "true"
              "True"
            when "false"
              "False"
            else
              throw new Error "can't translate bool constant '#{root.val}'"
        when "Unit"
          "unit"
        
        when "number"
          perr "WARNING number constant passed to translation stage. That's type inference mistake"
          module.warning_counter++
          root.val
        
        when "unsigned_number"
          "#{root.val}n"
        
        when "string"
          JSON.stringify root.val
        when "built_in_op_list"
          if root.val
            "#{root.val}"
          else
            "(nil: list(operation))"
        else
          if config.bytes_type_hash.hasOwnProperty root.type.main
            number2bytes root.val, +root.type.main.replace(/bytes/, '')
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
        if ((root.a.type && root.a.type.main == 'bool') || ( root.b.type &&root.b.type.main == 'bool')) and op in ['>=', '=/=', '<=','>','<','=']
          switch op
            when "="
              "bitwise_not(bitwise_xor(#{_a}, #{_b}))"
            when "=/="
              "bitwise_xor(#{_a}, #{_b})"
            when ">"
              "(#{_a} and not #{_b})"
            when "<" 
              "((not #{_a}) and #{_b})"
            when ">="
              "(#{_a} or not #{_b})"
            when "<="
              "((not #{_a}) or #{_b})"
            else
              "(#{_a} #{op} #{_b})"
        else
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
      if !root.t.type
        perr "CRITICAL WARNING some of types in Field_access aren't resolved. This can cause invalid code generated"
      else
        switch root.t.type.main
          when "array"
            switch root.name
              when "length"
                return "size(#{t})"
              
              else
                throw new Error "unknown array field #{root.name}"
          
          when "bytes"
            switch root.name
              when "length"
                return "size(#{t})"
              
              else
                throw new Error "unknown array field #{root.name}"
          
          when "enum"
            name = translate_var_name root.name, ctx
            if root.t?.name != "router_enum"
              prefix = ""
              if ctx.current_class.name
                prefix = "#{ctx.current_class.name}_"
              return "#{translate_var_name prefix + root.t.name}_#{root.name}"
            else
              name = "#{ctx.current_class.name.toUpperCase()}_#{name}"
              return "#{name}(unit)"
      
      # else
      if t == "" # this case
        return translate_var_name root.name, ctx
      
      chk_ret = "#{t}.#{root.name}"
      ret = "#{t}.#{translate_var_name root.name, ctx}"
      if root.t.constructor.name == "Var"
        if ctx.type_decl_hash[root.t.name]?.is_library
          ret = translate_var_name "#{t}_#{root.name}", ctx
      
      spec_id_translate chk_ret, ret
    
    when "Fn_call"
      arg_list = []
      for v in root.arg_list
        arg_list.push walk v, ctx
      
      if root.fn.constructor.name == "Field_access"
        t = walk root.fn.t, ctx
        if root.fn.t.type
          switch root.fn.t.type.main
            when "array"
              switch root.fn.name
                when "push"
                  tmp_var = "tmp_#{ctx.tmp_idx++}"
                  ctx.sink_list.push "const #{tmp_var} : #{translate_type root.fn.t.type, ctx} = #{t};"
                  return "#{tmp_var}[size(#{tmp_var})] := #{arg_list[0]}"
                
                else
                  throw new Error "unknown array field function #{root.fn.name}"
            
            when "address"
              switch root.fn.name
                when "send"
                  perr "CRITICAL WARNING we don't check balance in send function. So runtime error will be ignored and no boolean return"
                  # TODO check balance
                  op_code = "transaction(unit, #{arg_list[0]} * 1mutez, (get_contract(#{t}) : contract(unit)))"
                
                when "transfer"
                  perr "CRITICAL WARNING we don't check balance in send function. So runtime error will be ignored and no throw"
                  op_code = "transaction(unit, #{arg_list[0]} * 1mutez, (get_contract(#{t}) : contract(unit)))"
                
                when "call"
                  perr "CRITICAL WARNING call function willl be conveerted into transaction, it doesn't return any value so your code may be wrong."
                  perr "CRITICAL WARNING we don't check balance in call function. So runtime error will be ignored and no throw"
                  if root.arg_list[0]
                    ret_type = translate_type root.arg_list[0].type, ctx
                    ret = arg_list[0]
                  else
                    ret_type = "Unit"
                    ret = "unit"
                  op_code = "transaction(#{ret}, 0mutez, (get_contract(#{t}) : contract(#{ret_type})))"    


                when "delegatecall"
                  perr "CRITICAL WARNING we don't check balance in send function. So runtime error will be ignored and no throw"
                  op_code = "transaction(#{arg_list[1]}, 1mutez, (get_contract(#{t}) : contract(#{arg_list[0]})))"
                
                when "built_in_pure_callback"
                  # TODO check balance
                  ret_type = translate_type root.arg_list[0].type, ctx
                  ret = arg_list[0]
                  op_code = "transaction(#{ret}, 0mutez, (get_contract(#{t}) : contract(#{ret_type})))"
                
                else
                  throw new Error "unknown address field #{root.fn.name}"
              return "var #{config.op_list} : list(operation) := list #{op_code} end"

      if root.fn.constructor.name == "Var"
        switch root.fn.name
          when "require", "assert", "require2"
            cond= arg_list[0]
            str = arg_list[1]
            if str
              return "assert(#{cond}) (* #{str} *)"
            else 
              return "assert(#{cond})"
          
          when "revert"
            str = arg_list[0] or '"revert"'
            return "failwith(#{str})"
          
          when "sha256"
            msg = arg_list[0]
            return "sha_256(#{msg})"
          
          when "sha3", "keccak256"
            perr "CRITICAL WARNING #{root.fn.name} hash function would be translated as sha_256. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#hash-functions"
            msg = arg_list[0]
            return "sha_256(#{msg})"

          when "selfdestruct"
            perr "CRITICAL WARNING #{root.fn.name} is not implemented in ligo"
            msg = arg_list[0]
            return "selfdestruct(#{msg})"

          when "blockhash"
            msg = arg_list[0]
            perr "CRITICAL WARNING #{root.fn.name} is not implemented in ligo. Replaced with (\"#{msg}\" : bytes)."
            return "(\"00\" : bytes) (* Should be blockhash of #{msg} *)"
          
          when "ripemd160"
            perr "CRITICAL WARNING #{root.fn.name} hash function would be translated as blake2b. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#hash-functions"
            msg = arg_list[0]
            return "blake2b(#{msg})"
          
          when "ecrecover"
            perr "WARNING ecrecover function is not present in LIGO. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#hash-functions"
            # do not mangle, because it can be user-defined function
            fn = "ecrecover"
          
          when "@respond"
            perr "CRITICAL WARNING we don't check balance in send function. So runtime error will be ignored and no throw"
            # p root
            return "var #{config.op_list} : list(operation) := list transaction((#{arg_list.join ' * '}), 0mutez, #{config.receiver_name}) end"
          else
            name = root.fn.name
            if ctx.current_class?.is_library and ctx.current_class._prepared_field2type[name]
              name = "#{ctx.current_class.name}_#{name}"
              name = translate_var_name name, ctx
            else
              name = translate_var_name name, ctx if root.fn.name_translate
            # COPYPASTED (TEMP SOLUTION)
            fn = spec_id_translate root.fn.name, name
      else
        fn = walk root.fn, ctx
      
      if root.fn.type?.main == "struct"
        # this is contract(address) case
        msg = "address contract to type_cast is not supported yet (we need enum action type for each contract)"	
        perr "CRITICAL WARNING #{msg}"
        fn = "(* LIGO unsupported *)" + fn
      
      is_pure = root.fn.type?.main == "function2_pure"
      if !is_pure
        arg_list.unshift config.contract_storage
      
      if arg_list.length == 0
        arg_list.push "unit"
      
      type_jl = []
      # type can be null
      # type can be contract name, so no nest_list
      for v in root.fn.type?.nest_list[1]?.nest_list or []
        type_jl.push translate_type v, ctx
      
      tmp_var = "tmp_#{ctx.tmp_idx++}"
      call_expr = "#{fn}(#{arg_list.join ', '})";

      if is_pure and type_jl.length == 0
        perr "Bad call of pure function that returns nothing"
        type_jl.push "unit"
      if not root.left_unpack
        "#{call_expr}"
      else
        if type_jl.length == 1
          ctx.sink_list.push "const #{tmp_var} : #{type_jl[0]} = #{call_expr}"
        else
          ctx.sink_list.push "const #{tmp_var} : (#{type_jl.join ' * '}) = #{call_expr}"
    
    when "Struct_init"
      arg_list = []
      for i in [0..root.val_list.length-1]
        arg_list.push "#{root.arg_names[i]} = #{walk root.val_list[i], ctx}"
      "record [ #{arg_list.join ";\n\t"} ]"

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
        type2default_value root.target_type, ctx
      else if target_type == "bytes" and root.t.type?.main == "string"
        "bytes_pack(#{t})"
      else if target_type == "address" and (t == "0x0" or  t == "0")
        "(#{JSON.stringify config.default_address} : #{target_type})"
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
    
    when "Continue"
      "(* CRITICAL WARNING continue is not supported *)"
    
    when "Break"
      "(* CRITICAL WARNING break is not supported *)"
    
    when "Var_decl"
      name = root.name
      name = translate_var_name name, ctx if root.name_translate
      type = translate_type root.type, ctx
      prefix = ""
      if ctx.is_class_scope
        if root.special_type
          type = "#{ctx.current_class.name}_#{root.type.main}"
        type = translate_var_name type, ctx
        ctx.contract_var_hash[name] = root
        "#{name} : #{type};"
      else
        if root.assign_value
          if root.assign_value?.constructor.name == "Struct_init"
            type = "#{ctx.current_class.name}_#{root.type.main}"
            type = translate_var_name type, ctx
          val = walk root.assign_value, ctx
          if config.bytes_type_hash.hasOwnProperty(root.type.main) and root.assign_value.type.main == "string" and root.assign_value.constructor.name == "Const"
            val = string2bytes root.assign_value.val
          if config.bytes_type_hash.hasOwnProperty(root.type.main) and root.assign_value.type.main == "number" and root.assign_value.constructor.name == "Const"
            val = number2bytes root.assign_value.val
          """
          const #{name} : #{type} = #{val}
          """
        else
          """
          const #{name} : #{type} = #{type2default_value root.type, ctx}
          """
    
    when "Var_decl_multi"
      if root.assign_value
        val = walk root.assign_value, ctx
        tmp_var = "tmp_#{ctx.tmp_idx++}"
        
        jl = []
        type_list = []
        for _var, idx in root.list
          {name} = _var
          name = translate_var_name name, ctx
          type_list.push type = translate_type _var.type, ctx
          jl.push """
          const #{name} : #{type} = #{tmp_var}.#{idx};
          """
        
        """
        const #{tmp_var} : (#{type_list.join ' * '}) = #{val};
        #{join_list jl}
        """
      else
        perr "CRITICAL WARNING Var_decl_multi with no assign value should be unreachable, but something goes wrong"
        perr "CRITICAL WARNING We can't guarantee that smart contract would work at all"
        module.warning_counter++
        jl = []
        for _var in root.list
          {name} = _var
          name = translate_var_name name, ctx
          type = translate_type root.type, ctx
          jl.push """
          const #{name} : #{type} = #{type2default_value _var.type, ctx}
          """
        jl.join "\n"
    
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
        case_scope = walk _case.scope, ctx
        case_scope = case_scope[0..-2] if /;$/.test case_scope
        
        jl.push "| #{_case.struct_name}(#{_case.var_decl.name}) -> #{case_scope}"
      
      """
      case #{cond} of
      #{join_list jl, ''}
      end
      """
    
    when "Fn_decl_multiret"
      orig_ctx = ctx
      ctx = ctx.mk_nest()
      arg_jl = []
      for v,idx in root.arg_name_list
        is_state_in_main = root.name == "@main" and idx == 1
        if root.visibility != 'pure' and idx > 0 and !is_state_in_main
          v = translate_var_name v, ctx
        type = translate_type root.type_i.nest_list[idx], ctx
        arg_jl.push "const #{v} : #{type}"
      
      if arg_jl.length == 0
        arg_jl.push "const #{config.reserved}__unit : unit"
      
      ret_jl = []
      for v in root.type_o.nest_list
        type = translate_type v, ctx
        ret_jl.push "#{type}"
      
      name = root.name
      # current_class is missing for router
      if orig_ctx.current_class?.is_library
        name = "#{orig_ctx.current_class.name}_#{name}"
      
      name = translate_var_name name, ctx
      body = walk root.scope, ctx
      """
      function #{name} (#{arg_jl.join '; '}) : (#{ret_jl.join ' * '}) is
        #{make_tab body, '  '}
      """
    
    when "Class_decl"
      return "" if root.need_skip
      return "" if root.is_interface # skip for now
      orig_ctx = ctx
      prefix = ""
      if ctx.parent and ctx.current_class and root.namespace_name
        ctx.parent.type_decl_hash["#{ctx.current_class.name}.#{root.name}"] = root
        prefix = ctx.current_class.name
      
      ctx = ctx.mk_nest()
      ctx.current_class = root
      ctx.is_class_scope = true
      
      # stage 0 collect types
      for v in root.scope.list
        switch v.constructor.name
          when "Enum_decl", "Class_decl"
            ctx.type_decl_hash[v.name] = v
          when "PM_switch"
            for _case in root.scope.list
              ctx.type_decl_hash[_case.var_decl.type.main] = _case.var_decl
      
          else
            "skip"
      # stage 1 collect declarations
      field_decl_jl = []
      for v in root.scope.list
        switch v.constructor.name
          when "Var_decl"
              field_decl_jl.push walk v, ctx
          
          when "Fn_decl_multiret"
            ctx.contract_var_hash[v.name] = v
          
          when "Enum_decl"
            "skip"
          
          when "Class_decl"
            code = walk v, ctx
            ctx.sink_list.push code if code
          
          when "Comment"
            ctx.sink_list.push walk v, ctx
          
          when "Event_decl"
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
          
          when "Enum_decl"
            if v.name != "router_enum"
              ctx.enum_list.push walk v, ctx
            else
              jl.unshift walk v, ctx

          when "Fn_decl_multiret"
            jl.push walk v, ctx
          
          when "Class_decl", "Comment", "Event_decl"
            "skip"
          
          else
            throw new Error "unknown v.constructor.name #{v.constructor.name}"
      
      if root.is_contract or root.is_library
        state_name = config.storage
        if ctx.contract and ctx.contract != root.name
          state_name = "#{state_name}_#{root.name}"
        orig_ctx.storage_sink_list[state_name] ?= []
        orig_ctx.storage_sink_list[state_name].append field_decl_jl
      else
        name = root.name
        if prefix
          name = "#{prefix}_#{name}"
        name = translate_var_name name, ctx
        if root.is_struct 
          arg_list = []
          for v in root.scope.list
            arg_list.push "#{v.name} = #{type2default_value v.type, ctx}"
          ctx.structs_default_list.push "const #{name}_default : #{name} = record [ #{arg_list.join ";\n\t"} ];\n"
        ctx.type_decl_sink_list.push {
          name
          field_decl_jl
        }
      
      jl.join "\n\n"
    
    when "Enum_decl"
      jl = []
      # register global type
      prefix = ""
      if ctx.current_class.name and root.int_type
        prefix = "#{ctx.current_class.name}_"
      for v, idx in root.value_list
        # register global value
        ctx.contract_var_hash[v.name] = v
        
        # not covered by tests yet
        aux = ""
        if root.int_type
          if v.type
            type = translate_type v.type, ctx
            aux = "#{translate_var_name type, ctx}"
          jl.push "const #{translate_var_name prefix + root.name}_#{v.name}#{aux} : nat = #{idx}n;"
        else
          if v.type
            aux = " of #{translate_var_name v.type.main.replace /\./g, "_", ctx}"
          jl.push "| #{prefix.toUpperCase()}#{v.name}#{aux}"
        # jl.push "| #{v.name}"
      if root.int_type
        """
        #{join_list jl}
        """
      else
        """
        type #{translate_var_name prefix + root.name, ctx} is
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
        """(\"00\": bytes) (* args: #{args} *)"""
      else
        """
        #{translated_type}(#{args})
        """
    
    when "Tuple"
      #TODO does this even work?
      arg_list = []
      for v in root.list
        arg_list.push walk v, ctx
      "(#{arg_list.join ', '})"
    
    when "Array_init"
      arg_list = []
      for v in root.list
        arg_list.push walk v, ctx
      
      decls = []
      for arg, i in arg_list
        decls.push("#{i}n -> #{arg};")
      """
      map
        #{join_list decls, '  '}
      end
      """
    
    when "Event_decl"
      args = []
      for arg in root.arg_list
        name = translate_var_name arg._name, ctx
        type = translate_type arg, ctx
        args.push "#{name} : #{type}"
      """
      (* EventDefinition #{root.name}(#{args.join('; ')}) *)
      """
    
    else
      if ctx.next_gen?
        ctx.next_gen root, ctx
      else
        # TODO gen extentions
        perr root
        throw new Error "Unknown root.constructor.name #{root.constructor.name}"

@gen = (root, opt = {})->
  ctx = new module.Gen_context
  ctx.next_gen = opt.next_gen
  ctx.contract = opt.contract if opt.contract
  walk root, ctx
