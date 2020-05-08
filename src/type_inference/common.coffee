module = @

{translate_var_name} = require "../translate_var_name"
config = require "../config"
Type = require "type"

# NOTE. Type system. Each language should define its own
@default_var_map_gen = ()->
  {
    msg : (()->
      ret = new Type "struct"
      ret.field_map.sender = new Type "address"
      ret.field_map.value  = new Type "uint256"
      ret.field_map.data   = new Type "bytes"
      ret.field_map.gas    = new Type "uint256"
      ret.field_map.sig    = new Type "bytes4"
      ret
    )()
    tx : (()->
      ret = new Type "struct"
      ret.field_map["origin"]  = new Type "address"
      ret.field_map["gasprice"]= new Type "uint256"
      ret
    )()
    block : (()->
      ret = new Type "struct"
      ret.field_map["timestamp"] = new Type "uint256"
      ret.field_map["coinbase"]  = new Type "address"
      ret.field_map["difficulty"]= new Type "uint256"
      ret.field_map["gaslimit"]  = new Type "uint256"
      ret.field_map["number"]    = new Type "uint256"
      ret
    )()
    abi : (()->
      ret = new Type "struct"
      ret.field_map["encodePacked"] = new Type "function2<function<bytes>,function<bytes>>"
      ret
    )()
    now           : new Type "uint256"
    require       : new Type "function2<function<bool>,function<>>"
    require2      : new Type "function2<function<bool, string>,function<>>"
    assert        : new Type "function2<function<bool>,function<>>"
    revert        : new Type "function2<function<string>,function<>>"
    sha256        : new Type "function2<function<bytes>,function<bytes32>>"
    sha3          : new Type "function2<function<bytes>,function<bytes32>>"
    selfdestruct  : new Type "function2<function<address>,function<>>"
    blockmap      : new Type "function2<function<address>,function<bytes32>>"
    keccak256     : new Type "function2<function<bytes>,function<bytes32>>"
    ripemd160     : new Type "function2<function<bytes>,function<bytes20>>"
    ecrecover     : new Type "function2<function<bytes, uint8, bytes32, bytes32>,function<address>>"
    "@respond"    : new Type "function2<function<>,function<>>"
  }

@array_field_map =
  "length": new Type "uint256"
  "push"  : (type)->
    ret = new Type "function2<function<>,function<>>"
    ret.nest_list[0].nest_list.push type.nest_list[0]
    ret

@bytes_field_map =
  "length": new Type "uint256"

@address_field_map =
  "send"    : new Type "function2<function2<uint256>,function2<bool>>"
  "transfer": new Type "function2<function2<uint256>,function2<>>" # throws on false

@is_not_defined_type = (type)->
  !type or type.main in ["number", "unsigned_number", "signed_number"]

@is_number_type = (type)->
  return false if !type
  type.main in ["number", "unsigned_number", "signed_number"]

is_composite_type = (type)->
  type.main in ["array", "tuple", "map", "struct"]

is_defined_number_or_byte_type = (type)->
  config.any_int_type_map[type.main] or config.bytes_type_map[type.main]

type_resolve = (type, ctx)->
  if type and type.main != "struct"
    if ctx.type_map[type.main]
      type = ctx.check_id type.main
  type

@default_type_map_gen = ()->
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

@bin_op_ret_type_map_list = {
  BOOL_AND: [["bool", "bool", "bool"]]
  BOOL_OR : [["bool", "bool", "bool"]]
  BOOL_GT : [["bool", "bool", "bool"]]
  BOOL_LT : [["bool", "bool", "bool"]]
  BOOL_GTE : [["bool", "bool", "bool"]]
  BOOL_LTE : [["bool", "bool", "bool"]]
  ASSIGN  : [] # only cases a != b
}
@un_op_ret_type_map_list = {
  BOOL_NOT: [
    ["bool", "bool"]
  ]
  BIT_NOT : []
  MINUS   : []
}

for v in "ADD SUB MUL DIV MOD POW".split  /\s+/g
  @bin_op_ret_type_map_list[v] = []

for v in "BIT_AND BIT_OR BIT_XOR".split  /\s+/g
  @bin_op_ret_type_map_list[v] = []

for v in "EQ NE GT LT GTE LTE".split  /\s+/g
  @bin_op_ret_type_map_list[v] = []

for v in "SHL SHR POW".split  /\s+/g
  @bin_op_ret_type_map_list[v] = []

for op in "RET_INC RET_DEC INC_RET DEC_RET".split  /\s+/g
  @un_op_ret_type_map_list[op] = []

# ###################################################################################################
#    numeric operation type table
# ###################################################################################################
do ()=>
  for type in config.any_int_type_list
    @un_op_ret_type_map_list.BIT_NOT.push [type, type]
  
  for type in config.int_type_list
    @un_op_ret_type_map_list.MINUS.push [type, type]
  
  for op in "RET_INC RET_DEC INC_RET DEC_RET".split  /\s+/g
    for type in config.any_int_type_list
      @un_op_ret_type_map_list[op].push [type, type]
    
  for op in "ADD SUB MUL DIV MOD POW".split  /\s+/g
    list = @bin_op_ret_type_map_list[op]
    for type in config.any_int_type_list
      list.push [type, type, type]
  
  # non-equal types
  for op in "ADD SUB MUL DIV MOD POW".split  /\s+/g
    list = @bin_op_ret_type_map_list[op]
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
    list = @bin_op_ret_type_map_list[op]
    for type in config.uint_type_list
      list.push [type, type, type]
    for type in config.int_type_list
      list.push [type, type, type]
    for type in config.bytes_type_list
      list.push [type, type, type]
  
  for op in "EQ NE GT LT GTE LTE".split  /\s+/g
    list = @bin_op_ret_type_map_list[op]
    for type in config.any_int_type_list
      list.push [type, type, "bool"]
  
  # special
  for op in "SHL SHR POW".split  /\s+/g
    list = @bin_op_ret_type_map_list[op]
    for type_main in config.uint_type_list
      for type_index in config.uint_type_list
        list.push [type_main, type_index, type_main]
  
  return
# ###################################################################################################
#    bytes operation type table
# ###################################################################################################
do ()=>
  for type in config.bytes_type_list
    @un_op_ret_type_map_list.BIT_NOT.push [type, type]
  
  for type_byte in config.bytes_type_list
    for type_int in config.any_int_type_list
      @bin_op_ret_type_map_list.ASSIGN.push [type_byte, type_int, type_int]
      @bin_op_ret_type_map_list.ASSIGN.push [type_int, type_byte, type_int]
  
  for op in "EQ NE GT LT GTE LTE".split  /\s+/g
    for type_byte in config.bytes_type_list
      for type_int in config.any_int_type_list
        @bin_op_ret_type_map_list[op].push [type_byte, type_int, "bool"]
        @bin_op_ret_type_map_list[op].push [type_int, type_byte, "bool"]
      @bin_op_ret_type_map_list[op].push [type_byte, type_byte, "bool"]
  
  return

# ###################################################################################################

class @Ti_context
  parent    : null
  parent_fn : null
  current_class : null
  var_map  : {}
  type_map : {}

  # external params
  # we call ctx.walk so we can sometimes make calls to previous stage, but continue using current walk
  walk : null
  first_stage_walk : null
  change_count : 0
  
  constructor:()->
    @var_map = module.default_var_map_gen()
    @type_map= module.default_type_map_gen()
  
  mk_nest : ()->
    ret = new Ti_context
    ret.parent = @
    ret.parent_fn = @parent_fn
    ret.current_class = @current_class
    ret.first_stage_walk = @first_stage_walk
    ret.walk = @walk
    obj_set ret.type_map, @type_map
    ret
  
  type_proxy : (cls)->
    if cls.constructor.name == "Enum_decl"
      ret = new Type "enum"
      for v in cls.value_list
        ret.field_map[v.name] = new Type "int"
      ret
    else
      ret = new Type "struct"
      for k,v of cls._prepared_field2type
        continue unless v.main == "function2"
        ret.field_map[k] = v
      ret
  
  check_id : (id)->
    if id == "this"
      return @type_proxy @current_class
    if @type_map.hasOwnProperty id
      return @type_proxy @type_map[id]
    if @var_map.hasOwnProperty id
      return @var_map[id]
    if state_class = @type_map[config.storage]
      return ret if ret = state_class._prepared_field2type[id]
    
    if @parent
      return @parent.check_id id
    throw new Error "can't find decl for id '#{id}'"
  
  check_type : (_type)->
    if @type_map.hasOwnProperty _type
      return @type_map[_type]
    if @parent
      return @parent.check_type _type
    throw new Error "can't find type '#{_type}'"

@class_prepare = (root, ctx)->
  ctx.type_map[root.name] = root
  if ctx.parent and ctx.current_class
    ctx.parent.type_map["#{ctx.current_class.name}.#{root.name}"] = root
  for v in root.scope.list
    switch v.constructor.name
      when "Var_decl"
        root._prepared_field2type[v.name] = v.type
      
      when "Fn_decl_multiret"
        # BUG this is defined inside scope and it needs type
        type = new Type "function2<function,function>"
        type.nest_list[0] = v.type_i
        type.nest_list[1] = v.type_o
        root._prepared_field2type[v.name] = type
  
  return

@type_resolve = (type, ctx)->
  if type and type.main != "struct"
    if ctx.type_map[type.main]
      type = ctx.check_id type.main
  type

@type_spread_left = (a_type, b_type, ctx)->
  return a_type if !b_type
  if !a_type and b_type
    a_type = b_type.clone()
    ctx.change_count++
  else if a_type.main == "number"
    if b_type.main in ["unsigned_number", "signed_number"]
      a_type = b_type.clone()
      ctx.change_count++
    else if b_type.main == "number"
      "nothing"
    else
      if b_type.main == "address"
        perr "NOTE address to number type cast is not supported in LIGO"
        return a_type
      unless is_defined_number_or_byte_type b_type
        throw new Error "can't spread '#{b_type}' to '#{a_type}'"
      a_type = b_type.clone()
      ctx.change_count++
  else if @is_not_defined_type(a_type) and !@is_not_defined_type(b_type)
    if a_type.main in ["unsigned_number", "signed_number"]
      unless is_defined_number_or_byte_type b_type
        throw new Error "can't spread '#{b_type}' to '#{a_type}'"
    else
      throw new Error "unknown is_not_defined_type spread case"
    a_type = b_type.clone()
    change_count++
  else if !@is_not_defined_type(a_type) and @is_not_defined_type(b_type)
    # will check, but not spread
    if b_type.main in ["number", "unsigned_number", "signed_number"]
      unless is_defined_number_or_byte_type a_type
        if a_type.main == "address"
          perr "CRITICAL WARNING address <-> number operation detected. We can't fix this yet. So generated code will be not compileable by LIGO"
          return a_type
        throw new Error "can't spread '#{b_type}' to '#{a_type}'. Reverse spread collision detected"
    # p "NOTE Reverse spread collision detected", new Error "..."
  else
    return a_type if a_type.cmp b_type
    # not fully correct, but solidity will wipe all incorrect cases for us
    if a_type.main == "bytes" and config.bytes_type_map.hasOwnProperty b_type.main
      return a_type
    if config.bytes_type_map.hasOwnProperty(a_type.main) and b_type.main == "bytes"
      return a_type
      
    if a_type.main == "string" and config.bytes_type_map.hasOwnProperty b_type.main
      return a_type
    if config.bytes_type_map.hasOwnProperty(a_type.main) and b_type.main == "string"
      return a_type
    
    if a_type.main != "struct" and b_type.main == "struct"
      a_type = type_resolve a_type, ctx
    
    if a_type.main == "struct" and b_type.main != "struct"
      b_type = type_resolve b_type, ctx
    
    if is_composite_type a_type
      if !is_composite_type b_type
        perr "can't spread between '#{a_type}' '#{b_type}'. Reason: is_composite_type mismatch"
        return a_type
      
      # composite
      if a_type.main != b_type.main
        throw new Error "spread composite collision '#{a_type}' '#{b_type}'. Reason: composite container mismatch"
      
      if a_type.nest_list.length != b_type.nest_list.length
        throw new Error "spread composite collision '#{a_type}' '#{b_type}'. Reason: nest_list length mismatch"
      
      for idx in [0 ... a_type.nest_list.length]
        inner_a = a_type.nest_list[idx]
        inner_b = b_type.nest_list[idx]
        new_inner_a = @type_spread_left inner_a, inner_b, ctx
        a_type.nest_list[idx] = new_inner_a
      
      # TODO struct? but we don't need it? (field_map)
    else
      if is_composite_type b_type
        perr "can't spread between '#{a_type}' '#{b_type}'. Reason: is_composite_type mismatch"
        return a_type
      # scalar
      if @is_number_type(a_type) and @is_number_type(b_type)
        return a_type
      
      if a_type.main == "address" and config.any_int_type_map.hasOwnProperty(b_type)
        perr "CRITICAL WARNING address <-> defined number operation detected '#{a_type}' '#{b_type}'. We can't fix this yet. So generated code will be not compileable by LIGO"
        return a_type
      
      if b_type.main == "address" and config.any_int_type_map.hasOwnProperty(a_type)
        perr "CRITICAL WARNING address <-> defined number operation detected '#{a_type}' '#{b_type}'. We can't fix this yet. So generated code will be not compileable by LIGO"
        return a_type
      
      if config.bytes_type_map.hasOwnProperty(a_type.main) and config.bytes_type_map.hasOwnProperty(b_type.main)
        perr "WARNING bytes with different sizes are in type collision '#{a_type}' '#{b_type}'. This can lead to runtime error."
        return a_type
      
      # throw new Error "spread scalar collision '#{a_type}' '#{b_type}'. Reason: type mismatch"
  
  return a_type