require "fy"
config= require "./config"
Type  = require "type"
ast   = require "./ast"
{type_generalize} = require "./type_generalize"

bin_op_map =
  "+"   : "ADD"
  "-"   : "SUB"
  "*"   : "MUL"
  "/"   : "DIV"
  "%"   : "MOD"
  "**"  : "POW"
  ">>"  : "SHR"
  "<<"  : "SHL"
  
  "&" : "BIT_AND"
  "|" : "BIT_OR"
  "^" : "BIT_XOR"
  
  "&&" : "BOOL_AND"
  "||" : "BOOL_OR"
  
  "==" : "EQ"
  "!=" : "NE"
  ">"  : "GT"
  "<"  : "LT"
  ">=" : "GTE"
  "<=" : "LTE"
  
  "="  : "ASSIGN"
  "+=" : "ASS_ADD"
  "-=" : "ASS_SUB"
  "*=" : "ASS_MUL"
  "/=" : "ASS_DIV"
  "%=" : "ASS_MOD"
  
  ">>=": "ASS_SHR"
  "<<=": "ASS_SHL"
  
  "&=" : "ASS_BIT_AND"
  "|=" : "ASS_BIT_OR"
  "^=" : "ASS_BIT_XOR"

is_complex_assign_op =
  "ASS_ADD" : true
  "ASS_SUB" : true
  "ASS_MUL" : true
  "ASS_DIV" : true

un_op_map =
  "-" : "MINUS"
  "+" : "PLUS"
  "~" : "BIT_NOT"
  "!" : "BOOL_NOT"
  "delete" : "DELETE"

un_op_pre_map =
  "++": "INC_RET"
  "--": "DEC_RET"

un_op_post_map =
  "++": "RET_INC"
  "--": "RET_DEC"

walk_type = (root, ctx)->
  if typeof root == "string" # surprise from ElementaryTypeNameExpression
    return new Type root
  switch root.nodeType
    when "ElementaryTypeName"
      switch root.name
        when "uint"
          new Type "uint256"
        
        when "int"
          new Type "int256"
        
        else
          new Type root.name
    
    when "UserDefinedTypeName"
      new Type root.name
    
    when "ArrayTypeName"
      ret = new Type "array"
      ret.nest_list.push walk_type root.baseType, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      ret
    
    when "Mapping"
      ret = new Type "map"
      ret.nest_list.push walk_type root.keyType, ctx
      ret.nest_list.push walk_type root.valueType, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      ret
    
    else
      perr root
      throw new Error("walk_type unknown nodeType '#{root.nodeType}'")

unpack_id_type = (root, ctx)->
  type_string = root.typeString
  if /\smemory$/.test type_string
    type_string = type_string.replace /\smemory$/, ""
  
  if /\sstorage$/.test type_string
    type_string = type_string.replace /\sstorage$/, ""
  switch type_string
    when "bool"
      new Type "bool"
    
    when "uint"
      new Type "uint256"
    
    when "int"
      new Type "int256"
    
    when "byte"
      new Type "bytes1"
    
    when "bytes"
      new Type "bytes"
    
    when "address"
      new Type "address"
    
    when "string"
      new Type "string"
    
    when "msg"
      null # fields would be replaced in type inference
    
    when "block"
      null # fields would be replaced in type inference
    
    when "tx"
      null # fields would be replaced in type inference
    
    else
      if config.bytes_type_map.hasOwnProperty type_string
        new Type root.typeString
      else if config.uint_type_map.hasOwnProperty type_string
        new Type root.typeString
      else if config.int_type_map.hasOwnProperty type_string
        new Type root.typeString
      else
        throw new Error("unpack_id_type unknown typeString '#{root.typeString}'")

parse_line_pos = (str) ->
  return str.split(":", 2)

walk_param = (root, ctx)->
  switch root.nodeType
    when "ParameterList"
      ret = []
      for v in root.parameters
        ret.append walk_param v, ctx
      ret
    
    when "VariableDeclaration"
      if root.value
        throw new Error("root.value not implemented")
      ret = []
      t = walk_type root.typeName, ctx
      # HACK INJECT
      t._name = root.name
      ret.push t
      ret
    
    else
      perr root
      throw new Error("walk_param unknown nodeType '#{root.nodeType}'")

ensure_scope = (t)->
  return t if t.constructor.name == "Scope"
  ret = new ast.Scope
  ret.list.push t
  ret

class Context
  contract      : null
  contract_name : ""
  contract_type : ""
  file_stack    : []
  need_prevent_deploy : false
  constructor:()->

prev_root = null # DEBUG only
walk = (root, ctx)->
  if !root
    perr prev_root
    throw new Error "!root"
  prev_root = root
  result = switch root.nodeType
    # ###################################################################################################
    #    high level scope
    # ###################################################################################################
    when "SourceUnit"
      ret = new ast.Scope
      ret.original_node_type = root.nodeType
      for node in root.nodes
        ret.list.push walk node, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      ret
    
    when "ContractDefinition"
      # HACK to know in which file following nodes are located in
      if root.name.startsWith "ImportPlaceholderStart"
        ctx.file_stack.push root.nodes[0].value.value 
        # HACK this comment starting with "#include" will be caught at a later stages to be translated to actual include
        ret = new ast.Comment
        ret.text = "#include \"#{ctx.file_stack.last()}\""
        ret.can_skip = true
        ret
      else if root.name.startsWith "ImportPlaceholderEnd"
        ret = new ast.Comment
        ret.text = "end of include #{ctx.file_stack.last()}"
        ret.can_skip = true
        ctx.file_stack.pop()
        ret
      else
        ret = new ast.Class_decl
        
        switch root.contractKind
          when "contract"
            ret.is_contract = true
          
          when "library"
            ret.is_library = true
          
          when "interface"
            ret.is_interface = true
          
          else
            throw new Error "unknown contractKind #{root.contractKind}"
        
        ret.inheritance_list = []
        ret.name          = root.name
        ctx.contract      = ret
        ctx.contract_name = root.name
        ctx.contract_type = root.contractKind
        for v in root.baseContracts
          arg_list = []
          if v.arguments
            for arg in v.arguments
              arg_list.push walk arg, ctx
          
          ret.inheritance_list.push {
            name : v.baseName.name
            arg_list
          }
        for node in root.nodes
          ret.scope.list.push walk node, ctx
          
        [ret.pos, ret.line] = parse_line_pos(root.src)
        ret.file = ctx.file_stack.last()
        
        ret
    
    # ###################################################################################################
    #    Unsupported stuff
    # ###################################################################################################
    when "PragmaDirective"
      # JUST PASS
      ret = new ast.Comment
      ret.text = "PragmaDirective #{root.literals.join ' '}"
      ret.can_skip = true

      ret
    
    when "UsingForDirective"
      ret = new ast.Comment
      ret.text = "UsingForDirective"
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      
      if root.typeName == null
        type = "*"
      else
        type = type_generalize root.typeName.name
      
      ctx.contract.using_map[type] ?= []
      ctx.contract.using_map[type].push root.libraryName.name

      ret
    
    when "StructDefinition"
      ret = new ast.Class_decl
      ret.name = root.name
      ret.is_struct = true
      for v in root.members
        ret.scope.list.push walk v, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      ret
    
    when "InlineAssembly"
      perr "WARNING (AST gen). InlineAssembly is not supported. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#inline-assembler"
      failwith_msg = new ast.Const
      failwith_msg.val = "Unsupported InlineAssembly"
      failwith_msg.type = new Type "string"
      failwith = new ast.Throw
      failwith.t = failwith_msg
      comment = new ast.Comment
      comment.text = "InlineAssembly #{root.operations}"
      ret = new ast.Scope
      ret.need_nest = false
      ret.list.push failwith
      ret.list.push comment
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    when "EventDefinition"
      perr "WARNING (AST gen). EventDefinition is not supported. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#solidity-events"
      ret = new ast.Event_decl
      ret.name = root.name
      ret.arg_list = walk_param root.parameters, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    when "EmitStatement"
      perr "WARNING (AST gen). EmitStatement is not supported. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#solidity-events"
      ret = new ast.Comment
      args = []
      name = root.fn?.name || root.eventCall.name || root.eventCall.expression.name
      args = root.arg_list || root.eventCall.arguments
      arg_names = args.map (arg) -> arg.name
      ret.text = "EmitStatement #{name}(#{arg_names.join(", ")})"
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    when "PlaceholderStatement"
      ret = new ast.Comment
      ret.text = "COMPILER MSG PlaceholderStatement"
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    # ###################################################################################################
    #    expr
    # ###################################################################################################
    when "Identifier"
      ret = new ast.Var
      ret.name = root.name
      try
        ret.type = unpack_id_type root.typeDescriptions, ctx
      catch err
        perr "WARNING (AST gen). Can't resolve type #{err}"
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      
      ret
    
    when "Literal"
      ret = new ast.Const
      ret.type  = new Type root.kind
      ret.val   = root.value
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      switch root.subdenomination
        when "seconds"
          ret
        when "minutes"
          mult = new ast.Const
          mult.type  = new Type root.kind
          mult.val = 60
          exp = new ast.Bin_op
          exp.op = bin_op_map["*"]
          exp.a = ret
          exp.b = mult
          exp
        when "hours"
          mult = new ast.Const
          mult.type  = new Type root.kind
          mult.val = 3600
          exp = new ast.Bin_op
          exp.op = bin_op_map["*"]
          exp.a = ret
          exp.b = mult
          exp
        when "days"
          mult = new ast.Const
          mult.type  = new Type root.kind
          mult.val = 86400
          exp = new ast.Bin_op
          exp.op = bin_op_map["*"]
          exp.a = ret
          exp.b = mult
          exp
        when "weeks"
          mult = new ast.Const
          mult.type  = new Type root.kind
          mult.val = 604800
          exp = new ast.Bin_op
          exp.op = bin_op_map["*"]
          exp.a = ret
          exp.b = mult
          exp
        when "szabo"
          ret
        when "finney"
          mult = new ast.Const
          mult.type  = new Type root.kind
          mult.val = 1000
          exp = new ast.Bin_op
          exp.op = bin_op_map["*"]
          exp.a = ret
          exp.b = mult
          exp
        when "ether"
          mult = new ast.Const
          mult.type  = new Type root.kind
          mult.val = 1000000
          exp = new ast.Bin_op
          exp.op = bin_op_map["*"]
          exp.a = ret
          exp.b = mult
          exp
        else
          ret
    
    when "VariableDeclaration"
      ret = new ast.Var_decl
      ret.is_const = root.constant
      ret.name = root.name
      ret.contract_name = ctx.contract_name
      ret.contract_type = ctx.contract_type
      ret.type = walk_type root.typeName, ctx
      # ret.type = new Type root.typeDescriptions.typeIdentifier
      if root.value
        ret.assign_value = walk root.value, ctx
      # root.typeName
      # storage : root.storageLocation
      # state   : root.stateVariable
      # visibility   : root.visibility
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    when "Assignment"
      ret = new ast.Bin_op
      ret.op = bin_op_map[root.operator]
      if !ret.op
        throw new Error("unknown bin_op #{root.operator}")
      ret.a = walk root.leftHandSide, ctx
      ret.b = walk root.rightHandSide, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    when "BinaryOperation"
      ret = new ast.Bin_op
      ret.op = bin_op_map[root.operator]
      if !ret.op
        throw new Error("unknown bin_op #{root.operator}")
      ret.a = walk root.leftExpression, ctx
      ret.b = walk root.rightExpression, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    when "MemberAccess"
      ret = new ast.Field_access
      ret.t = walk root.expression, ctx
      ret.name = root.memberName
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    when "IndexAccess"
      ret = new ast.Bin_op
      ret.op = "INDEX_ACCESS"
      ret.a = walk root.baseExpression, ctx
      ret.b = walk root.indexExpression, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    when "UnaryOperation"
      ret = new ast.Un_op
      ret.op = un_op_map[root.operator]
      if !ret.op
        if root.prefix
          ret.op = un_op_pre_map[root.operator]
        else
          ret.op = un_op_post_map[root.operator]
      if !ret.op
        perr root
        throw new Error("unknown un_op #{root.operator}")
      ret.a = walk root.subExpression, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    when "FunctionCall"
      fn = walk root.expression, ctx
      arg_list = []
      for v in root.arguments
        arg_list.push walk v, ctx
      
      switch fn.constructor.name
        when "New"
          ret = fn
          ret.arg_list = arg_list
        
        when "Type_cast"
          if arg_list.length != 1
            perr arg_list
            throw new Error "arg_list.length != 1"
          ret = fn
          ret.t = arg_list[0]
        
        else
          if root.kind == "structConstructorCall"
            ret = new ast.Struct_init
            ret.fn = fn
            ret.val_list = arg_list
            if root.names
              ret.arg_names = root.names
          else
            ret = new ast.Fn_call
            ret.fn = fn
            ret.arg_list = arg_list

      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    when "TupleExpression"
      if root.isInlineArray
        ret = new ast.Array_init
      else
        ret = new ast.Tuple
      
      for v in root.components
        if v?
          ret.list.push walk v, ctx
        else
          ret.list.push null
      
      if ret.constructor.name == "Tuple"
        if ret.list.length == 1
          ret = ret.list[0]

      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    when "NewExpression"
      ret = new ast.New
      ret.cls = walk_type root.typeName, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    when "ElementaryTypeNameExpression"
      ret = new ast.Type_cast
      ret.target_type = walk_type root.typeName, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    
    when "Conditional"
      ret = new ast.Ternary
      ret.cond  = walk root.condition       , ctx
      ret.t     = walk root.trueExpression  , ctx
      ret.f     = walk root.falseExpression , ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()

      ret
    # ###################################################################################################
    #    stmt
    # ###################################################################################################
    when "ExpressionStatement"
      walk root.expression, ctx
    
    when "VariableDeclarationStatement"
      if root.declarations.length != 1
        ret = new ast.Var_decl_multi
        for decl in root.declarations
          if !decl?
            ret.list.push {
              skip: true
            }
            continue
          if decl.typeName
            ret.list.push {
              name : decl.name
              type : walk_type decl.typeName, ctx
            }
          else
            try
              type = unpack_id_type decl.typeDescriptions, ctx
            catch err
              perr "WARNING (AST gen). Can't resolve type #{err}"
            
            ret.list.push {
              name : decl.name
              type
            }
        if root.initialValue
          ret.assign_value = walk root.initialValue, ctx
        
        type_list = []
        for v in ret.list
          type_list.push v.type
        
        ret.type = new Type "tuple<>"
        ret.type.nest_list = type_list
        
        [ret.pos, ret.line] = parse_line_pos(root.src)
        ret.file = ctx.file_stack.last()

        ret
      else
        decl = root.declarations[0]
        if decl.value
          throw new Error("decl.value not implemented")
        
        ret = new ast.Var_decl
        ret.name = decl.name
        if decl.typeName
          ret.type = walk_type decl.typeName, ctx
        else
          ret.type = unpack_id_type decl.typeDescriptions, ctx
        if root.initialValue
          ret.assign_value = walk root.initialValue, ctx
        [ret.pos, ret.line] = parse_line_pos(root.src)
        ret.file = ctx.file_stack.last()
        
        ret
    
    when "Block"
      ret = new ast.Scope
      for node in root.statements
        ret.list.push walk node, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      
      ret
    
    when "IfStatement"
      ret = new ast.If
      ret.cond = walk root.condition, ctx
      ret.t    = ensure_scope walk root.trueBody,  ctx
      if root.falseBody
        ret.f    = ensure_scope walk root.falseBody, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      
      ret
    
    when "WhileStatement"
      ret = new ast.While
      ret.cond = walk root.condition, ctx
      ret.scope= ensure_scope walk root.body, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      ret
    
    when "ForStatement"
      ret = new ast.For3
      if root.initializationExpression
        ret.init = walk root.initializationExpression, ctx
      if root.condition
        ret.cond = walk root.condition, ctx
      if root.loopExpression
        ret.iter = walk root.loopExpression, ctx
      ret.scope= ensure_scope walk root.body, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      ret
    
    # ###################################################################################################
    #    control flow
    # ###################################################################################################
    when "Return"
      ret = new ast.Ret_multi
      if root.expression # and ctx.current_function.should_ret_args
        ret.t_list.push walk root.expression, ctx
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      ret
    
    when "Continue"
      perr "WARNING (AST gen). 'continue' is not supported by LIGO. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#continue--break"
      ctx.need_prevent_deploy = true
      ret = new ast.Continue
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      ret
    
    when "Break"
      perr "WARNING (AST gen). 'break' is not supported by LIGO. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#continue--break"
      ctx.need_prevent_deploy = true
      ret = new ast.Break
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      ret
    
    when "Throw"
      ret = new ast.Throw
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      ret
    
    # ###################################################################################################
    #    Func
    # ###################################################################################################
    when "FunctionDefinition", "ModifierDefinition"
      ret = ctx.current_function = new ast.Fn_decl_multiret
      ret.is_modifier = root.nodeType == "ModifierDefinition"
      ret.is_constructor = root.isConstructor or root.kind == "constructor"
      ret.name = root.name or "fallback"
      ret.name = "constructor" if ret.is_constructor
      ret.contract_name = ctx.contract_name
      ret.contract_type = ctx.contract_type

      ret.type_i =  new Type "function"
      ret.type_o =  new Type "function"
      ret.visibility = root.visibility
      ret.state_mutability = root.stateMutability
      
      ret.type_i.nest_list = walk_param root.parameters, ctx
      unless ret.is_modifier
        list = walk_param root.returnParameters, ctx
        if list.length <= 1
          ret.type_o.nest_list = list
        else
          tuple = new Type "tuple<>"
          tuple.nest_list = list
          ret.type_o.nest_list.push tuple
      
      scope_prepend_list = []
      if root.returnParameters
        for parameter in root.returnParameters.parameters
          continue if !parameter.name
          scope_prepend_list.push var_decl = new ast.Var_decl
          var_decl.name = parameter.name
          var_decl.type = walk_type parameter.typeName, ctx
      
      for v in ret.type_i.nest_list
        ret.arg_name_list.push v._name
      

      if !ret.is_modifier
        for modifier in root.modifiers
          ast_mod = new ast.Fn_call
          ast_mod.fn = walk modifier.modifierName, ctx
          if modifier.arguments
            for v in modifier.arguments
              ast_mod.arg_list.push walk v, ctx
          ret.modifier_list.push ast_mod
      
      if root.body
        ret.scope = walk root.body, ctx
      else
        ret.scope = new ast.Scope
      
      if scope_prepend_list.length
        ret.scope.list = arr_merge scope_prepend_list, ret.scope.list
        if ret.scope.list.last().constructor.name != "Ret_multi"
          ret.scope.list.push ret_multi = new ast.Ret_multi
          switch scope_prepend_list.length
            when 0
              "nothing"
            
            when 1
              v = scope_prepend_list[0]
              ret_multi.t_list.push _var = new ast.Var
              _var.name = v.name
            
            else
              tuple = new ast.Tuple
              for v in scope_prepend_list
                tuple.list.push _var = new ast.Var
                _var.name = v.name
              
              ret_multi.t_list.push tuple
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      ret
    
    when "EnumDefinition"
      ret = new ast.Enum_decl
      ret.name = root.name
      for member in root.members
        ret.value_list.push decl = new ast.Var_decl
        decl.name = member.name
        # decl.type = new Type ret.name
        # skip type declaration since solidity enums aren't typed
      [ret.pos, ret.line] = parse_line_pos(root.src)
      ret.file = ctx.file_stack.last()
      ret
    
    else
      perr root
      throw new Error("walk unknown nodeType '#{root.nodeType}'")
  
  if ctx.need_prevent_deploy
    result.need_prevent_deploy = true
  result


@gen = (root)->
  walk root, new Context