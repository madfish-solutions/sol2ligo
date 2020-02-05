module = @
ast = require "ast4gen"
for k,v of ast
  @[k] = v

# ###################################################################################################
#    redefine
# ###################################################################################################
class @Class_decl
  name  : ""
  is_contract : false
  is_library  : false
  need_skip   : false # if class was used for inheritance
  scope : null
  _prepared_field2type : {}
  inheritance_list : []
  line  : 0
  pos   : 0
  constructor:()->
    @scope = new module.Scope
    @_prepared_field2type = {}
  
  # skip validate
  
  clone : ()->
    ret = new module.Class_decl
    ret.name  = @name
    ret.is_contract = @is_contract
    ret.is_library  = @is_library
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
    ret

class @Var
  name  : ""
  name_translate: true
  type  : null
  line  : 0
  pos   : 0
  
  clone : ()->
    ret = new module.Var
    ret.name  = @name
    ret.type  = @type.clone() if @type
    ret.line  = @line
    ret.pos   = @pos
    ret

class @Var_decl
  name  : ""
  name_translate: true
  type  : null
  size  : null
  assign_value      : null
  assign_value_list : null
  line  : 0
  pos   : 0
  
  clone : ()->
    ret = new module.Var_decl
    ret.name  = @name
    ret.name_translate = @name_translate
    ret.type  = @type.clone() if @type
    ret.size  = @size
    ret.assign_value  = @assign_value.clone() if @assign_value
    if @assign_value_list
      ret.assign_value_list = []
      for v in @assign_value_list
        ret.assign_value_list.push v.clone()
    ret.line  = @line
    ret.pos   = @pos
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
  visibility : ""
  state_mutability : ""
  is_modifier: false
  modifier_list : [] # array<Fn_call>
  
  constructor:()->
    @arg_name_list = []
    @scope = new ast.Scope
    @modifier_list = []
  
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
    ret.visibility      = @visibility
    ret.state_mutability= @state_mutability
    for v in @modifier_list
      ret.modifier_list.push v.clone()
    ret

class @Ret_multi
  t_list : []
  line    : 0
  pos     : 0
  
  constructor:()->
    @t_list = []
  
  clone : ()->
    ret = new module.Ret_multi
    for v in @t_list
      ret.t_list.push v.clone()
    ret.line  = @line
    ret.pos   = @pos
    ret

class @Comment
  text  : ""
  line  : 0
  pos   : 0
  
  clone : ()->
    ret = new module.Comment
    ret.text  = @text
    ret.line  = @line
    ret.pos   = @pos
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
    ret.type  = @type.clone()
    ret.line  = @line
    ret.pos   = @pos
    ret

class @Var_decl_multi # used for var (a,b) = fn_call();
  list  : []
  assign_value : null
  line  : 0
  pos   : 0
  
  constructor:()->
    @list = []
  
  clone : ()->
    ret = new module.Var_decl_multi
    for v in @list
      ret.list.push v.clone()
    ret.assign_value  = @assign_value.clone()
    ret.line  = @line
    ret.pos   = @pos
    ret

class @Ternary
  cond  : null
  t     : null
  f     : null
  line  : 0
  pos   : 0
  
  clone : ()->
    ret = new module.Ternary
    ret.cond  = @cond.clone()
    ret.t     = @t.clone()
    ret.f     = @f.clone()
    ret.line  = @line
    ret.pos   = @pos
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
    ret
  

class @Type_cast
  target_type : null
  t     : null
  line  : 0
  pos   : 0
  
  clone : ()->
    ret = new module.Type_cast
    ret.target_type = @target_type.clone()
    ret.t     = @t.clone()
    ret.line  = @line
    ret.pos   = @pos
    ret

class @For3
  init  : null
  cond  : null
  iter  : null
  scope : null
  line  : 0
  pos   : 0
  constructor:()->
    @scope = new ast.Scope
  
  clone : ()->
    ret = new module.For3
    ret.init  = @init.clone() if @init
    ret.cond  = @cond.clone() if @cond
    ret.iter  = @iter.clone() if @init
    ret.line  = @line
    ret.pos   = @pos
    ret
  
# PM = Pattern matching
class @PM_switch
  cond  : null
  scope : null
  # default : null
  line  : 0
  pos   : 0
  constructor: ()->
    @scope   = new ast.Scope
    # @default = new ast.Scope
  
  clone : ()->
    ret = new module.PM_switch
    ret.cond  = @cond.clone()
    ret.scope = @scope.clone()
    ret.line  = @line
    ret.pos   = @pos
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
    ret
  
class @Enum_decl
  name  : ""
  value_list: [] # array<Var_decl>
  line  : 0
  pos   : 0
  
  constructor:()->
    @value_list = []
  
  clone : ()->
    ret = new module.Enum_decl
    ret.name = @name
    for v in @value_list
      ret.value_list.push v.clone()
    ret.line  = @line
    ret.pos   = @pos
    ret
