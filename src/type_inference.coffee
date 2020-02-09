config = require "./config"
Type = require "type"
require "./type_safe"
module = @

# Прим. Это система типов eth
# каждый язык, который хочет транслироваться должен сам решать как он будет преобразовывать эти типы в свои
@default_var_hash_gen = ()->
  {
    msg : (()->
      ret = new Type "struct"
      ret.field_hash.sender = new Type "address"
      ret.field_hash.value  = new Type "uint256"
      ret.field_hash.data   = new Type "bytes"
      ret
    )()
    tx : (()->
      ret = new Type "struct"
      ret.field_hash["origin"] = new Type "address"
      ret
    )()
    block : (()->
      ret = new Type "struct"
      ret.field_hash["timestamp"] = new Type "uint256"
      ret
    )()
    abi : (()->
      ret = new Type "struct"
      ret.field_hash["encodePacked"] = new Type "function2_pure<function<bytes>,function<bytes>>"
      ret
    )()
    now       : new Type "uint256"
    require   : new Type "function2_pure<function<bool>,function<>>"
    require2  : new Type "function2_pure<function<bool, string>,function<>>"
    assert    : new Type "function2_pure<function<bool>,function<>>"
    revert    : new Type "function2_pure<function<string>,function<>>"
    sha256    : new Type "function2_pure<function<bytes>,function<bytes32>>"
    sha3      : new Type "function2_pure<function<bytes>,function<bytes32>>"
    keccak256 : new Type "function2_pure<function<bytes>,function<bytes32>>"
    ripemd160 : new Type "function2_pure<function<bytes>,function<bytes20>>"
  }

array_field_hash =
  "length": new Type "uint256"
  "push"  : (type)->
    ret = new Type "function2_pure<function<>,function<>>"
    ret.nest_list[0].nest_list.push type.nest_list[0]
    ret

bytes_field_hash =
  "length": new Type "uint256"

address_field_hash =
  "send"    : new Type "function2_pure<function2<uint256>,function2<bool>>"
  "transfer": new Type "function2_pure<function2<uint256>,function2<>>" # throws on false

@default_type_hash_gen = ()->
  ret = {
    bool    : true
    array   : true
    string  : true
    address : true
  }
  
  for type in config.any_int_type_list
    ret[type] = true
  
  for type in config.bytes_type_list
    ret[type] = true
  
  ret

@bin_op_ret_type_hash_list = {
  BOOL_AND: [["bool", "bool", "bool"]]
  BOOL_OR : [["bool", "bool", "bool"]]
  ASSIGN  : [] # only cases a != b
}
@un_op_ret_type_hash_list = {
  BOOL_NOT: [
    ["bool", "bool"]
  ]
  BIT_NOT : []
  MINUS   : []
  RET_INC : []
}

for v in "ADD SUB MUL DIV MOD POW".split  /\s+/g
  @bin_op_ret_type_hash_list[v] = []

for v in "BIT_AND BIT_OR BIT_XOR".split  /\s+/g
  @bin_op_ret_type_hash_list[v] = []

for v in "EQ NE GT LT GTE LTE".split  /\s+/g
  @bin_op_ret_type_hash_list[v] = []

for v in "SHL SHR POW".split  /\s+/g
  @bin_op_ret_type_hash_list[v] = []


# ###################################################################################################
#    numeric operation type table
# ###################################################################################################
do ()=>
  for type in config.any_int_type_list
    @un_op_ret_type_hash_list.BIT_NOT.push [type, type]
  
  for type in config.int_type_list
    @un_op_ret_type_hash_list.MINUS.push [type, type]
  
  for type in config.any_int_type_list
    @un_op_ret_type_hash_list.RET_INC.push [type, type]
    
  for op in "ADD SUB MUL DIV MOD POW".split  /\s+/g
    list = @bin_op_ret_type_hash_list[op]
    for type in config.any_int_type_list
      list.push [type, type, type]
  
  # non-equal types
  for op in "ADD SUB MUL DIV MOD POW".split  /\s+/g
    list = @bin_op_ret_type_hash_list[op]
    for type1, idx1 in config.int_type_list
      for type2, idx2 in config.int_type_list
        continue if idx1 >= idx2
        list.push [type1, type2, type2]
        list.push [type2, type1, type2]
    
    for type1, idx1 in config.uint_type_list
      for type2, idx2 in config.uint_type_list
        continue if idx1 >= idx2
        list.push [type1, type2, type2]
        list.push [type2, type1, type2]
  
  for op in "BIT_AND BIT_OR BIT_XOR".split  /\s+/g
    list = @bin_op_ret_type_hash_list[op]
    for type in config.uint_type_list
      list.push [type, type, type]
  
  for op in "EQ NE GT LT GTE LTE".split  /\s+/g
    list = @bin_op_ret_type_hash_list[op]
    for type in config.any_int_type_list
      list.push [type, type, "bool"]
  
  # special
  for op in "SHL SHR POW".split  /\s+/g
    list = @bin_op_ret_type_hash_list[op]
    for type_main in config.uint_type_list
      for type_index in config.uint_type_list
        list.push [type_main, type_index, type_main]
  
  return
# ###################################################################################################
#    bytes operation type table
# ###################################################################################################
do ()=>
  for type in config.bytes_type_list
    @un_op_ret_type_hash_list.BIT_NOT.push [type, type]
  
  for type_byte in config.bytes_type_list
    for type_int in config.any_int_type_list
      @bin_op_ret_type_hash_list.ASSIGN.push [type_byte, type_int, type_int]
      @bin_op_ret_type_hash_list.ASSIGN.push [type_int, type_byte, type_int]
  
  for op in "EQ NE GT LT GTE LTE".split  /\s+/g
    for type_byte in config.bytes_type_list
      for type_int in config.any_int_type_list
        @bin_op_ret_type_hash_list[op].push [type_byte, type_int, "bool"]
        @bin_op_ret_type_hash_list[op].push [type_int, type_byte, "bool"]
      @bin_op_ret_type_hash_list[op].push [type_byte, type_byte, "bool"]
  
  return

# ###################################################################################################

class Ti_context
  parent    : null
  parent_fn : null
  current_class : null
  var_hash  : {}
  type_hash : {}
  
  constructor:()->
    @var_hash = module.default_var_hash_gen()
    @type_hash= module.default_type_hash_gen()
  
  mk_nest : ()->
    ret = new Ti_context
    ret.parent = @
    ret.parent_fn = @parent_fn
    ret.current_class = @current_class
    obj_set ret.type_hash, @type_hash
    ret
  
  type_proxy : (cls)->
    ret = new Type "struct"
    for k,v of cls._prepared_field2type
      continue unless v.main in ["function2", "function2_pure"]
      ret.field_hash[k] = v
    ret
  
  check_id : (id)->
    if id == "this"
      return @type_proxy @current_class
    if type_decl = @type_hash[id]
      return @type_proxy type_decl
    return ret if ret = @var_hash[id]
    if state_class = @type_hash[config.storage]
      return ret if ret = state_class._prepared_field2type[id]
    
    if @parent
      return @parent.check_id id
    throw new Error "can't find decl for id '#{id}'"
  
  check_type : (_type)->
    return ret if ret = @type_hash[_type]
    if @parent
      return @parent.check_type _type
    throw new Error "can't find type '#{_type}'"

class_prepare = (root, ctx)->
  ctx.type_hash[root.name] = root
  for v in root.scope.list
    switch v.constructor.name
      when "Var_decl"
        root._prepared_field2type[v.name] = v.type
      
      when "Fn_decl_multiret"
        # BUG внутри scope уже есть this и ему нужен тип...
        if v.state_mutability == "pure"
          type = new Type "function2_pure<function,function>"
        else
          type = new Type "function2<function,function>"
        type.nest_list[0] = v.type_i
        type.nest_list[1] = v.type_o
        root._prepared_field2type[v.name] = type
  
  return

is_not_defined_type = (type)->
  !type or type.main in ["number", "unsigned_number", "signed_number"]

is_number_type = (type)->
  return false if !type
  type.main in ["number", "unsigned_number", "signed_number"]

is_composite_type = (type)->
  type.main in ["array", "tuple", "map", "struct"]

is_defined_number_or_byte_type = (type)->
  config.any_int_type_hash[type.main] or config.bytes_type_hash[type.main]

get_list_sign = (list)->
  has_signed   = false
  has_unsigned = false
  has_wtf      = false
  for v in list
    if config.int_type_hash[v] or v == "signed_number"
      has_signed = true
    else if config.uint_type_hash[v] or v == "unsigned_number"
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

@gen = (ast_tree, opt)->
  change_count = 0
  type_spread_left = (a_type, b_type, touch_counter=true)->
    return a_type if !b_type
    if !a_type and b_type
      a_type = b_type.clone()
      change_count++ if touch_counter
    else if a_type.main == "number"
      if b_type.main in ["unsigned_number", "signed_number"]
        a_type = b_type.clone()
        change_count++ if touch_counter
      else if b_type.main == "number"
        "nothing"
      else
        unless is_defined_number_or_byte_type b_type
          throw new Error "can't spread '#{b_type}' to '#{a_type}'"
        a_type = b_type.clone()
        change_count++ if touch_counter
    else if is_not_defined_type(a_type) and !is_not_defined_type(b_type)
      if a_type.main in ["unsigned_number", "signed_number"]
        unless is_defined_number_or_byte_type b_type
          throw new Error "can't spread '#{b_type}' to '#{a_type}'"
      else
        throw new Error "unknown is_not_defined_type spread case"
      a_type = b_type.clone()
      change_count++ if touch_counter
    else if !is_not_defined_type(a_type) and is_not_defined_type(b_type)
      # will check, but not spread
      if b_type.main in ["number", "unsigned_number", "signed_number"]
        unless is_defined_number_or_byte_type a_type
          throw new Error "can't spread '#{b_type}' to '#{a_type}'. Reverse spread collision detected"
      # p "NOTE Reverse spread collision detected", new Error "..."
    else
      return a_type if a_type.cmp b_type
      # not fully correct, but solidity will wipe all incorrect cases for us
      if a_type.main == "bytes" and config.bytes_type_hash[b_type.main]
        return a_type
      if config.bytes_type_hash[a_type.main] and b_type.main == "bytes"
        return a_type
        
      if a_type.main == "string" and config.bytes_type_hash[b_type.main]
        return a_type
      if config.bytes_type_hash[a_type.main] and b_type.main == "string"
        return a_type
      
      if is_composite_type a_type
        if !is_composite_type b_type
          throw new Error "can't spread between '#{a_type}' '#{b_type}'. Reason: is_composite_type mismatch"
        # composite
        if a_type.main != b_type.main
          throw new Error "spread composite collision '#{a_type}' '#{b_type}'. Reason: composite container mismatch"
        
        if a_type.nest_list.length != b_type.nest_list.length
          throw new Error "spread composite collision '#{a_type}' '#{b_type}'. Reason: nest_list length mismatch"
        
        for idx in [0 ... a_type.nest_list.length]
          inner_a = a_type.nest_list[idx]
          inner_b = b_type.nest_list[idx]
          new_inner_a = type_spread_left inner_a, inner_b, touch_counter
          a_type.nest_list[idx] = new_inner_a
        
        # TODO struct? but we don't need it? (field_hash)
      else
        if is_composite_type b_type
          throw new Error "can't spread between '#{a_type}' '#{b_type}'. Reason: is_composite_type mismatch"
        # scalar
        throw new Error "spread scalar collision '#{a_type}' '#{b_type}'. Reason: type mismatch"
    
    return a_type
  
  # phase 1 bottom-to-top walk + type reference
  walk = (root, ctx)->
    switch root.constructor.name
      # ###################################################################################################
      #    expr
      # ###################################################################################################
      when "Var"
        root.type = type_spread_left root.type, ctx.check_id root.name
      
      when "Const"
        root.type
      
      when "Bin_op"
        walk root.a, ctx
        walk root.b, ctx
        
        switch root.op
          when "ASSIGN"
            root.a.type = type_spread_left root.a.type, root.b.type
            root.b.type = type_spread_left root.b.type, root.a.type
            
            root.type = type_spread_left root.type, root.a.type
            root.a.type = type_spread_left root.a.type, root.type
            root.b.type = type_spread_left root.b.type, root.type
          
          when "EQ", "NE"
            root.type = type_spread_left root.type, new Type "bool"
            root.a.type = type_spread_left root.a.type, root.b.type
            root.b.type = type_spread_left root.b.type, root.a.type
          
          when "INDEX_ACCESS"
            switch root.a.type?.main
              when "string"
                root.b.type = type_spread_left root.b.type, new Type "uint256"
                root.type = type_spread_left root.type, new Type "string"
              
              when "map"
                root.b.type = type_spread_left root.b.type, root.a.type.nest_list[0]
                root.type   = type_spread_left root.type, root.a.type.nest_list[1]
              
              when "array"
                root.b.type = type_spread_left root.b.type, new Type "uint256"
                root.type   = type_spread_left root.type, root.a.type.nest_list[0]
              
              else
                if config.bytes_type_hash[root.a.type?.main]
                  root.b.type = type_spread_left root.b.type, new Type "uint256"
                  root.type = type_spread_left root.type, new Type "bytes1"
        
        # bruteforce only at stage 2
        
        root.type
      
      when "Un_op"
        a = walk root.a, ctx
        
        if root.op == "DELETE"
          if root.a.constructor.name == "Bin_op"
            if root.a.op == "INDEX_ACCESS"
              if root.a.a.type?.main == "array"
                return root.type
              if root.a.a.type?.main == "map"
                return root.type
        
        root.type
      
      when "Field_access"
        root_type = walk(root.t, ctx)
        
        switch root_type.main
          when "array"
            field_hash = array_field_hash
          
          when "address"
            field_hash = address_field_hash
          
          when "struct"
            field_hash = root_type.field_hash
          
          else
            if config.bytes_type_hash[root_type.main]
              field_hash = bytes_field_hash
            else
              class_decl = ctx.check_type root_type.main
              field_hash = class_decl._prepared_field2type
        
        if !field_type = field_hash[root.name]
          perr root.t
          perr field_hash
          throw new Error "unknown field. '#{root.name}' at type '#{root_type}'. Allowed fields [#{Object.keys(field_hash).join ', '}]"
        
        # Я не понял зачем это
        # field_type = ast.type_actualize field_type, root.t.type
        if typeof field_type == "function"
          field_type = field_type root.t.type
        
        root.type = type_spread_left root.type, field_type
        root.type
      
      when "Fn_call"
        root_type = walk root.fn, ctx
        
        if root_type.main == "function2_pure"
          offset = 0
        else
          offset = 2
        
        for arg in root.arg_list
          walk arg, ctx
        root.type = type_spread_left root.type, root_type.nest_list[1].nest_list[offset]
      
      # ###################################################################################################
      #    stmt
      # ###################################################################################################
      when "Comment"
        null
      
      when "Var_decl"
        if root.assign_value
          root.assign_value.type = type_spread_left root.assign_value.type, root.type
          walk root.assign_value, ctx
        ctx.var_hash[root.name] = root.type
        null
      
      when "Var_decl_multi"
        if root.assign_value
          root.assign_value.type = type_spread_left root.assign_value.type, root.type
          walk root.assign_value, ctx
        
        null
      
      when "Throw"
        if root.t
          walk root.t, ctx
        null
      
      when "Scope"
        ctx_nest = ctx.mk_nest()
        for v in root.list
          if v.constructor.name == "Class_decl"
            class_prepare v, ctx
        for v in root.list
          walk v, ctx_nest
        
        null
      
      when "Ret_multi"
        for v,idx in root.t_list
          v.type = type_spread_left v.type, ctx.parent_fn.type_o.nest_list[idx]
          expected = ctx.parent_fn.type_o.nest_list[idx]
          real = v.type
          if !expected.cmp real
            perr root
            perr "fn_type=#{ctx.parent_fn.type_o}"
            perr v
            throw new Error "Ret_multi type mismatch [#{idx}] expected=#{expected} real=#{real} @fn=#{ctx.parent_fn.name}"
          
          walk v, ctx
        null
      
      when "Class_decl"
        class_prepare root, ctx
        
        ctx_nest = ctx.mk_nest()
        ctx_nest.current_class = root
        
        for k,v of root._prepared_field2type
          ctx_nest.var_hash[k] = v
        
        # ctx_nest.var_hash["this"] = new Type root.name
        walk root.scope, ctx_nest
        root.type
      
      when "Fn_decl_multiret"
        if root.state_mutability == "pure"
          complex_type = new Type "function2_pure"
        else
          complex_type = new Type "function2"
        complex_type.nest_list.push root.type_i
        complex_type.nest_list.push root.type_o
        ctx.var_hash[root.name] = complex_type
        ctx_nest = ctx.mk_nest()
        ctx_nest.parent_fn = root
        for name,k in root.arg_name_list
          type = root.type_i.nest_list[k]
          ctx_nest.var_hash[name] = type
        walk root.scope, ctx_nest
        root.type
      
      when "PM_switch"
        null
      
      # ###################################################################################################
      #    control flow
      # ###################################################################################################
      when "If"
        walk(root.cond, ctx)
        walk(root.t, ctx.mk_nest())
        walk(root.f, ctx.mk_nest())
        null
      
      when "While"
        walk root.cond, ctx.mk_nest()
        walk root.scope, ctx.mk_nest()
        null
      
      when "Enum_decl"
        null
      
      when "Type_cast"
        root.type
      
      when "Ternary"
        root.type
      
      when "New"
        root.type
      
      when "Tuple"
        for v in root.list
          walk v, ctx
        
        # -> ret
        nest_list = []
        for v in root.list
          nest_list.push v.type
        
        type = new Type "tuple<>"
        type.nest_list = nest_list
        root.type = type_spread_left root.type, type
        
        # <- ret
        
        for v,idx in root.type.nest_list
          tuple_value = root.list[idx]
          tuple_value.type = type_spread_left tuple_value.type, v
        
        root.type
      
      when "Array_init"
        for v in root.list
          walk v, ctx
        
        nest_type = null
        if root.type
          if root.type.main != "array"
            throw new Error "Array_init can have only array type"
          nest_type = root.type.nest_list[0]
        
        for v in root.list
          nest_type = type_spread_left nest_type, v.type
        
        for v in root.list
          v.type = type_spread_left v.type, nest_type
        
        type = new Type "array<>"
        type.nest_list[0] = nest_type
        root.type = type_spread_left root.type, type
        root.type
      
      else
        ### !pragma coverage-skip-block ###
        perr root
        throw new Error "ti phase 1 unknown node '#{root.constructor.name}'"
  walk ast_tree, new Ti_context
  
  # phase 2
  # iterable
  
  # TODO refactor. Stage 2 should reuse code from stage 1 but override some branches
  # Прим. спорно. В этом случае надо будет как-то информировать что это phase 2 иначе будет непонятно что привело к этому
  # возможно копипастить меньшее зло, чем потом дебажить непонятно как (т.к. сейчас p можно поставить на stage 1 и stage 2 раздельно)
  walk = (root, ctx)->
    switch root.constructor.name
      # ###################################################################################################
      #    expr
      # ###################################################################################################
      when "Var"
        root.type = type_spread_left root.type, ctx.check_id root.name
      
      when "Const"
        root.type
      
      when "Bin_op"
        walk root.a, ctx
        walk root.b, ctx
        
        switch root.op
          when "ASSIGN"
            root.a.type = type_spread_left root.a.type, root.b.type
            root.b.type = type_spread_left root.b.type, root.a.type
            
            root.type = type_spread_left root.type, root.a.type
            root.a.type = type_spread_left root.a.type, root.type
            root.b.type = type_spread_left root.b.type, root.type
            return root.type
          
          when "EQ", "NE"
            root.type = type_spread_left root.type, new Type "bool"
            root.a.type = type_spread_left root.a.type, root.b.type
            root.b.type = type_spread_left root.b.type, root.a.type
            return root.type
          
          when "INDEX_ACCESS"
            switch root.a.type?.main
              when "string"
                root.b.type = type_spread_left root.b.type, new Type "uint256"
                root.type = type_spread_left root.type, new Type "string"
                return root.type
              
              when "map"
                root.b.type = type_spread_left root.b.type, root.a.type.nest_list[0]
                root.type   = type_spread_left root.type, root.a.type.nest_list[1]
                return root.type
              
              when "array"
                root.b.type = type_spread_left root.b.type, new Type "uint256"
                root.type   = type_spread_left root.type, root.a.type.nest_list[0]
                return root.type
              
              else
                if config.bytes_type_hash[root.a.type?.main]
                  root.b.type = type_spread_left root.b.type, new Type "uint256"
                  root.type = type_spread_left root.type, new Type "bytes1"
                  return root.type
        
        bruteforce_a  = is_not_defined_type root.a.type
        bruteforce_b  = is_not_defined_type root.b.type
        bruteforce_ret= is_not_defined_type root.type
        a   = (root.a.type or "").toString()
        b   = (root.b.type or "").toString()
        ret = (root.type   or "").toString()
        
        if !list = module.bin_op_ret_type_hash_list[root.op]
          throw new Error "unknown bin_op #{root.op}"
          
        # filter for fully defined types
        found_list = []
        for tuple in list
          continue if tuple[0] != a   and !bruteforce_a
          continue if tuple[1] != b   and !bruteforce_b
          continue if tuple[2] != ret and !bruteforce_ret
          found_list.push tuple
        
        # filter for partially defined types
        if is_number_type root.a.type
          filter_found_list = []
          for tuple in found_list
            continue if !config.any_int_type_hash[tuple[0]]
            filter_found_list.push tuple
          
          found_list = filter_found_list
        
        if is_number_type root.b.type
          filter_found_list = []
          for tuple in found_list
            continue if !config.any_int_type_hash[tuple[1]]
            filter_found_list.push tuple
          
          found_list = filter_found_list
        
        if is_number_type root.type
          filter_found_list = []
          for tuple in found_list
            continue if !config.any_int_type_hash[tuple[2]]
            filter_found_list.push tuple
          
          found_list = filter_found_list
        
        # ###################################################################################################
        
        if found_list.length == 0
          throw new Error "type inference stuck bin_op #{root.op} invalid a=#{a} b=#{b} ret=#{ret}"
        else if found_list.length == 1
          [a, b, ret] = found_list[0]
          root.a.type = type_spread_left root.a.type, new Type a
          root.b.type = type_spread_left root.b.type, new Type b
          root.type   = type_spread_left root.type,   new Type ret
        else
          if bruteforce_a
            a_type_list = []
            for tuple in found_list
              a_type_list.upush tuple[0]
            if a_type_list.length == 0
              perr "bruteforce stuck bin_op #{root.op} caused a can't be any type"
            else if a_type_list.length == 1
              root.a.type = type_spread_left root.a.type, new Type a_type_list[0]
            else
              if new_type = get_list_sign a_type_list
                root.a.type = type_spread_left root.a.type, new Type new_type
          
          if bruteforce_b
            b_type_list = []
            for tuple in found_list
              b_type_list.upush tuple[1]
            if b_type_list.length == 0
              perr "bruteforce stuck bin_op #{root.op} caused b can't be any type"
            else if b_type_list.length == 1
              root.b.type = type_spread_left root.b.type, new Type b_type_list[0]
            else
              if new_type = get_list_sign b_type_list
                root.b.type = type_spread_left root.b.type, new Type new_type
          
          if bruteforce_ret
            ret_type_list = []
            for tuple in found_list
              ret_type_list.upush tuple[2]
            if ret_type_list.length == 0
              perr "bruteforce stuck bin_op #{root.op} caused ret can't be any type"
            else if ret_type_list.length == 1
              root.type = type_spread_left root.type, new Type ret_type_list[0]
            else
              if new_type = get_list_sign ret_type_list
                root.type = type_spread_left root.type, new Type new_type
        
        root.type
      
      when "Un_op"
        walk root.a, ctx
        
        if root.op == "DELETE"
          if root.a.constructor.name == "Bin_op"
            if root.a.op == "INDEX_ACCESS"
              if root.a.a.type?.main == "array"
                return root.type
              if root.a.a.type?.main == "map"
                return root.type
        
        bruteforce_a  = is_not_defined_type root.a.type
        bruteforce_ret= is_not_defined_type root.type
        a   = (root.a.type or "").toString()
        ret = (root.type   or "").toString()
        
        if !list = module.un_op_ret_type_hash_list[root.op]
          throw new Error "unknown un_op #{root.op}"
        # filter for fully defined types
        found_list = []
        for tuple in list
          continue if tuple[0] != a   and !bruteforce_a
          continue if tuple[1] != ret and !bruteforce_ret
          found_list.push tuple
        
        # filter for partially defined types
        if is_number_type root.a.type
          filter_found_list = []
          for tuple in found_list
            continue if !config.any_int_type_hash[tuple[0]]
            filter_found_list.push tuple
          
          found_list = filter_found_list
        
        if is_number_type root.type
          filter_found_list = []
          for tuple in found_list
            continue if !config.any_int_type_hash[tuple[1]]
            filter_found_list.push tuple
          
          found_list = filter_found_list
        
        # ###################################################################################################
        
        if found_list.length == 0
          throw new Error "type inference stuck un_op #{root.op} invalid a=#{a} ret=#{ret}"
        else if found_list.length == 1
          [a, ret] = found_list[0]
          root.a.type = type_spread_left root.a.type, new Type a
          root.type   = type_spread_left root.type,   new Type ret
        else
          if bruteforce_a
            a_type_list = []
            for tuple in found_list
              a_type_list.upush tuple[0]
            if a_type_list.length == 0
              throw new Error "type inference bruteforce stuck un_op #{root.op} caused a can't be any type"
            else if a_type_list.length == 1
              root.a.type = type_spread_left root.a.type, new Type a_type_list[0]
            else
              if new_type = get_list_sign a_type_list
                root.a.type = type_spread_left root.a.type, new Type new_type
          
          if bruteforce_ret
            ret_type_list = []
            for tuple in found_list
              ret_type_list.upush tuple[1]
            if ret_type_list.length == 0
              throw new Error "type inference bruteforce stuck un_op #{root.op} caused ret can't be any type"
            else if ret_type_list.length == 1
              root.type = type_spread_left root.type, new Type ret_type_list[0]
            else
              if new_type = get_list_sign ret_type_list
                root.type = type_spread_left root.type, new Type new_type
        
        root.type
      
      when "Field_access"
        root_type = walk(root.t, ctx)
        
        switch root_type.main
          when "array"
            field_hash = array_field_hash
          
          when "bytes"
            field_hash = bytes_field_hash
          
          when "address"
            field_hash = address_field_hash
          
          when "struct"
            field_hash = root_type.field_hash
          
          else
            class_decl = ctx.check_type root_type.main
            field_hash = class_decl._prepared_field2type
        
        if !field_type = field_hash[root.name]
          throw new Error "unknown field. '#{root.name}' at type '#{root_type}'. Allowed fields [#{Object.keys(field_hash).join ', '}]"
        
        # Я не понял зачем это
        # field_type = ast.type_actualize field_type, root.t.type
        if typeof field_type == "function"
          field_type = field_type root.t.type
        root.type = type_spread_left root.type, field_type
        root.type
      
      when "Fn_call"
        root_type = walk root.fn, ctx
        
        if root_type.main == "function2_pure"
          offset = 0
        else
          offset = 2
        
        for arg,i in root.arg_list
          walk arg, ctx
          expected_type = root_type.nest_list[0].nest_list[i+offset]
          arg.type = type_spread_left arg.type, expected_type
        root.type = type_spread_left root.type, root_type.nest_list[1].nest_list[offset]
      
      # ###################################################################################################
      #    stmt
      # ###################################################################################################
      when "Comment"
        null
      
      when "Var_decl"
        if root.assign_value
          root.assign_value.type = type_spread_left root.assign_value.type, root.type
          walk root.assign_value, ctx
        ctx.var_hash[root.name] = root.type
        null
      
      when "Var_decl_multi"
        if root.assign_value
          root.assign_value.type = type_spread_left root.assign_value.type, root.type
          walk root.assign_value, ctx
        
        null
      
      when "Throw"
        if root.t
          walk root.t, ctx
        null
      
      when "Scope"
        ctx_nest = ctx.mk_nest()
        for v in root.list
          walk v, ctx_nest
        
        null
      
      when "Ret_multi"
        for v,idx in root.t_list
          v.type = type_spread_left v.type, ctx.parent_fn.type_o.nest_list[idx]
          expected = ctx.parent_fn.type_o.nest_list[idx]
          real = v.type
          if !expected.cmp real
            perr root
            perr "fn_type=#{ctx.parent_fn.type_o}"
            perr v
            throw new Error "Ret_multi type mismatch [#{idx}] expected=#{expected} real=#{real} @fn=#{ctx.parent_fn.name}"
          
          walk v, ctx
        null
      
      when "Class_decl"
        class_prepare root, ctx
        
        ctx_nest = ctx.mk_nest()
        ctx_nest.current_class = root
        
        for k,v of root._prepared_field2type
          ctx_nest.var_hash[k] = v
        
        # ctx_nest.var_hash["this"] = new Type root.name
        walk root.scope, ctx_nest
        root.type
      
      when "Fn_decl_multiret"
        if root.state_mutability == "pure"
          complex_type = new Type "function2_pure"
        else
          complex_type = new Type "function2"
        complex_type.nest_list.push root.type_i
        complex_type.nest_list.push root.type_o
        ctx.var_hash[root.name] = complex_type
        ctx_nest = ctx.mk_nest()
        ctx_nest.parent_fn = root
        for name,k in root.arg_name_list
          type = root.type_i.nest_list[k]
          ctx_nest.var_hash[name] = type
        walk root.scope, ctx_nest
        root.type
      
      when "PM_switch"
        null
      
      # ###################################################################################################
      #    control flow
      # ###################################################################################################
      when "If"
        walk(root.cond, ctx)
        walk(root.t, ctx.mk_nest())
        walk(root.f, ctx.mk_nest())
        null
      
      when "While"
        walk root.cond, ctx.mk_nest()
        walk root.scope, ctx.mk_nest()
        null
      
      when "Enum_decl"
        null
      
      when "Type_cast"
        root.type
      
      when "Ternary"
        root.type
      
      when "New"
        root.type
      
      when "Tuple"
        for v in root.list
          walk v, ctx
        
        # -> ret
        nest_list = []
        for v in root.list
          nest_list.push v.type
        
        type = new Type "tuple<>"
        type.nest_list = nest_list
        root.type = type_spread_left root.type, type
        
        # <- ret
        
        for v,idx in root.type.nest_list
          tuple_value = root.list[idx]
          tuple_value.type = type_spread_left tuple_value.type, v
        
        root.type
      
      when "Array_init"
        for v in root.list
          walk v, ctx
        
        nest_type = null
        if root.type
          if root.type.main != "array"
            throw new Error "Array_init can have only array type"
          nest_type = root.type.nest_list[0]
        
        for v in root.list
          nest_type = type_spread_left nest_type, v.type
        
        for v in root.list
          v.type = type_spread_left v.type, nest_type
        
        type = new Type "array<#{nest_type}>"
        root.type = type_spread_left root.type, type
        root.type
      
      else
        ### !pragma coverage-skip-block ###
        perr root
        throw new Error "ti phase 2 unknown node '#{root.constructor.name}'"
  
  change_count = 0
  for i in [0 ... 100] # prevent infinite
    walk ast_tree, new Ti_context
    # p "phase 2 ti change_count=#{change_count}" # DEBUG
    break if change_count == 0
    change_count = 0
  
  ast_tree
