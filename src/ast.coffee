ast = require 'ast4gen'
for k,v of ast
  @[k] = v

class @Fn_decl_multiret
  is_closure : false
  name    : ''
  type_i  : null
  type_o  : null
  arg_name_list  : []
  scope   : null
  line    : 0
  pos     : 0
  constructor:()->
    @arg_name_list = []
    @scope = new ast.Scope

class @Ret_multi
  t_list : []
  
  constructor:()->
    @t_list = []

class @Comment
  text : ''

class @Tuple
  list : []
  
  constructor:()->
    @list = []

class @Var_decl_multi # used for var (a,b) = fn_call();
  list : []
  assign_value : null
  
  constructor:()->
    @list = []

class @Ternary
  cond: null
  t   : null
  f   : null

class @New
  cls : null
  arg_list: []
  constructor:()->
    @arg_list = []
  

class @Type_cast
  target_type : null
  t : null

class @For3
  init : null
  cond : null
  iter : null
  scope: null
  constructor:()->
    @scope = new ast.Scope
  
