module = @
ast = require "ast4gen"
for k,v of ast
  @[k] = v

# constants for function arguments
@INPUT_ARGS = 0
@RETURN_VALUES = 1

# ###################################################################################################
#    redefine
# ###################################################################################################
class @Class_decl
  name  : ""
  namespace_name : true
  is_contract : false
  is_library  : false
  is_interface: false
  is_struct: false
  need_skip   : false # if class was used for inheritance
  scope : null
  _prepared_field2type : {}
  inheritance_list : []
  using_map : {} # type -> list of library
  line  : 0
  pos   : 0
  file  : ""
  constructor:()->
    @scope = new module.Scope
    @_prepared_field2type = {}
    @inheritance_list = []
    @using_map = {}
  
  # skip validate
  
  clone : ()->
    ret = new module.Class_decl
    ret.name  = @name
    ret.namespace_name = @namespace_name
    ret.is_contract = @is_contract
    ret.is_library  = @is_library
    ret.is_interface= @is_interface
    ret.is_struct= @is_struct
    ret.need_skip   = @need_skip
    ret.scope = @scope.clone()
    for k,v of @_prepared_field2type
      ret._prepared_field2type[k] = v.clone()
    
    for v in @inheritance_list
      arg_list = []
      for arg in v.arg_list
        arg_list.push arg.clone()
      
      ret.inheritance_list.push {
        name : v.name
        arg_list
      }
    
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret

class @Var
  name  : ""
  name_translate: true
  type  : null
  line  : 0
  pos   : 0
  file  : ""
  
  clone : ()->
    ret = new module.Var
    ret.name  = @name
    ret.type  = @type.clone() if @type
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret

class @Var_decl
  name  : ""
  name_translate: true
  contract_name : ""
  contract_type : ""
  type  : null
  size  : null
  assign_value      : null
  assign_value_list : null
  is_enum_decl      : false
  is_const          : false
  line  : 0
  pos   : 0
  file  : ""
  
  clone : ()->
    ret = new module.Var_decl
    ret.name  = @name
    ret.name_translate = @name_translate
    ret.contract_name = @contract_name
    ret.contract_type = @contract_type
    ret.type  = @type.clone() if @type
    ret.size  = @size
    ret.assign_value  = @assign_value.clone() if @assign_value
    if @assign_value_list
      ret.assign_value_list = []
      for v in @assign_value_list
        ret.assign_value_list.push v.clone()
    ret.is_enum_decl  = @is_enum_decl
    ret.is_const      = @is_const
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret


class @Fn_call
  fn        : null
  arg_list  : []
  splat_fin : false
  type      : null
  left_unpack  : true
  fn_decl   : null
  
  is_fn_decl_from_using: false
  fn_name_using : null
  
  line  : 0
  pos   : 0
  file  : ""
  constructor:()->
    @arg_list = []
  
  validate : (ctx = new module.Validation_context)->
    if !@fn
      throw new Error "Fn_call validation error line=#{@line} pos=#{@pos}. fn missing"
    @fn.validate(ctx)
    if @fn.type.main != "function"
      throw new Error "Fn_call validation error line=#{@line} pos=#{@pos}. Can't call type '@fn.type'. You can call only function"
    
    if !@type.cmp void_type
      type_validate @type, ctx
    
    if !@type.cmp @fn.type.nest_list[0]
      throw new Error "Fn_call validation error line=#{@line} pos=#{@pos}. Return type and function decl return type doesn't match #{@fn.type.nest_list[0]} != #{@type}"
    
    if @fn.type.nest_list.length-1 != @arg_list.length
      throw new Error "Fn_call validation error line=#{@line} pos=#{@pos}. Expected arg count=#{@fn.type.nest_list.length-1} found=#{@arg_list.length}"
    
    for arg,k in @arg_list
      arg.validate(ctx)
      if !@fn.type.nest_list[k+1].cmp arg.type
        throw new Error "Fn_call validation error line=#{@line} pos=#{@pos}. arg[#{k}] type mismatch. Expected=#{@fn.type.nest_list[k+1]} found=#{arg.type}"
    return
  
  clone : ()->
    ret = new module.Fn_call
    ret.fn    = @fn.clone()
    for v in @arg_list
      ret.arg_list.push v.clone()
    ret.splat_fin = @splat_fin
    ret.type  = @type.clone() if @type
    ret.left_unpack  = @left_unpack
    ret.fn_decl      = @fn_decl
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret
# ###################################################################################################
#    New nodes
# ###################################################################################################
class @Fn_decl_multiret
  is_closure : false
  name    : ""
  type_i  : null
  type_o  : null
  arg_name_list  : [] # array<string>
  scope   : null
  line    : 0
  pos     : 0
  file    : ""
  visibility : ""
  state_mutability : ""
  contract_name : ""
  contract_type : ""
  
  is_modifier: false
  is_constructor: false
  modifier_list : [] # array<Fn_call>
  
  returns_op_list : false
  uses_storage    : false
  modifies_storage: false
  returns_value   : false
  
  constructor:()->
    @arg_name_list = []
    @scope = new ast.Scope
    @modifier_list = []
    @contract_name = ""
    @contract_type = ""
  
  clone : ()->
    ret = new module.Fn_decl_multiret
    ret.is_closure  = @is_closure
    ret.name  = @name
    ret.type_i  = @type_i.clone()
    ret.type_o  = @type_o.clone()
    ret.arg_name_list = @arg_name_list.clone()
    ret.scope = @scope.clone()
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret.visibility      = @visibility
    ret.state_mutability= @state_mutability

    ret.contract_name = @contract_name
    ret.contract_type = @contract_type
    ret.is_modifier   = @is_modifier
    ret.is_constructor= @is_constructor
    for v in @modifier_list
      ret.modifier_list.push v.clone()
    
    ret.returns_op_list = @returns_op_list
    ret.uses_storage    = @uses_storage
    ret.modifies_storage= @modifies_storage
    ret.returns_value   = @returns_value
    ret

class @Ret_multi
  t_list : []
  line    : 0
  pos     : 0
  file    : 0
  
  constructor:()->
    @t_list = []
  
  clone : ()->
    ret = new module.Ret_multi
    for v in @t_list
      ret.t_list.push v.clone()
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret

class @Comment
  text  : ""
  line  : 0
  pos   : 0
  can_skip : false
  file  : ""
  
  clone : ()->
    ret = new module.Comment
    ret.text  = @text
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret.can_skip = @can_skip
    ret

class @Tuple
  list : []
  type : null
  line : 0
  pos  : 0
  
  constructor:()->
    @list = []
  
  clone : ()->
    ret = new module.Tuple
    for v in @list
      ret.list.push v.clone()
    ret.type  = @type.clone() if @type
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret

class @Var_decl_multi # used for var (a,b) = fn_call();
  list  : []
  assign_value : null
  type  : null
  line  : 0
  pos   : 0
  file  : ""
  
  constructor:()->
    @list = []
  
  clone : ()->
    ret = new module.Var_decl_multi
    for v in @list
      if v.skip
        ret.list.push {
          name : v.name
          skip : v.skip
        }
      else
        ret.list.push {
          name : v.name
          type : v.type.clone()
        }
    ret.assign_value  = @assign_value.clone()
    ret.type  = @type.clone() if @type
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret

class @Ternary
  cond  : null
  t     : null
  f     : null
  line  : 0
  pos   : 0
  file  : ""
  
  clone : ()->
    ret = new module.Ternary
    ret.cond  = @cond.clone()
    ret.t     = @t.clone()
    ret.f     = @f.clone()
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret

class @New
  cls     : null
  arg_list: []
  line    : 0
  pos     : 0
  constructor:()->
    @arg_list = []
  
  clone : ()->
    ret = new module.New
    ret.cls   = @cls
    for v in @arg_list
      ret.arg_list.push v.clone()
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret
  

class @Type_cast
  target_type : null
  t     : null
  line  : 0
  pos   : 0
  file  : ""
  
  clone : ()->
    ret = new module.Type_cast
    ret.target_type = @target_type.clone()
    ret.t     = @t.clone()
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret

class @For3
  init  : null
  cond  : null
  iter  : null
  scope : null
  line  : 0
  pos   : 0
  file  : ""
  constructor:()->
    @scope = new ast.Scope
  
  clone : ()->
    ret = new module.For3
    ret.init  = @init.clone() if @init
    ret.cond  = @cond.clone() if @cond
    ret.iter  = @iter.clone() if @init
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret
  
# PM = Pattern matching
class @PM_switch
  cond  : null
  scope : null
  # default : null
  line  : 0
  pos   : 0
  file  : ""
  constructor: ()->
    @scope   = new ast.Scope
    # @default = new ast.Scope
  
  clone : ()->
    ret = new module.PM_switch
    ret.cond  = @cond.clone()
    ret.scope = @scope.clone()
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret
  
# note only 1 level allowed yet
class @PM_case
  struct_name : ""
  var_decl    : null
  scope       : null
  line        : 0
  pos         : 0
  
  constructor:()->
    @var_decl = new ast.Var_decl
    @scope    = new ast.Scope
  
  clone : ()->
    ret = new module.PM_case
    ret.struct_name = @struct_name
    ret.var_decl = @var_decl.clone()
    ret.scope = @scope.clone()
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret
  
class @Enum_decl
  name  : ""
  value_list: [] # array<Var_decl>
  int_type: true
  line  : 0
  pos   : 0
  file  : ""
  
  constructor:()->
    @value_list = []
  
  clone : ()->
    ret = new module.Enum_decl
    ret.name = @name
    for v in @value_list
      ret.value_list.push v.clone()
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret

class @Event_decl
  name  : ""
  arg_list: []
  line  : 0
  pos   : 0
  file  : ""
  
  clone : ()->
    ret = new module.Event_decl
    ret.name  = @name
    ret.arg_list  = @arg_list
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret

class @Struct_init
  fn      : null
  arg_names : []
  val_list  : []
  line  : 0
  pos   : 0
  file  : ""
  constructor:()->
    @val_list = []
    @arg_names = []
  
  clone : ()->
    ret = new module.Struct_init
    ret.fn    = @fn
    for v,idx in @val_list
      ret.val_list[idx] = v.clone()
    for v,idx in @arg_names
      ret.arg_names[idx] = v
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret

class @Include
  path : ""
  line  : 0
  pos   : 0
  file  : ""
  
  clone : ()->
    path = ""
    ret.line  = @line
    ret.pos   = @pos
    ret.file  = @file
    ret