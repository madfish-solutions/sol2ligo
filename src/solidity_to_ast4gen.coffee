Type = require "type"
ast = require "./ast"

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
      new Type root.name
    
    when "UserDefinedTypeName"
      new Type root.name
    
    when "ArrayTypeName"
      ret = new Type "array"
      ret.nest_list.push walk_type root.baseType, ctx
      ret
    
    when "Mapping"
      ret = new Type "map"
      ret.nest_list.push walk_type root.keyType, ctx
      ret.nest_list.push walk_type root.valueType, ctx
      ret
    
    else
      puts root
      throw new Error("walk_type unknown nodeType '#{root.nodeType}'")

unpack_id_type = (root, ctx)->
  switch root.typeString
    when "bool"
      new Type "bool"
    
    when "int8"
      new Type "int8"
    
    when "uint8"
      new Type "uint8"
    
    when "uint256"
      new Type "uint"
    
    when "int256"
      new Type "int"
    
    when "address"
      new Type "address"
    
    when "string"
      new Type "string"
    
    when "msg"
      new Type "struct" # fields would be replaced in type inference
    
    when "bytes", "bytes32"
      new Type "bytes"

    else
      # puts root # temp disable
      throw new Error("unpack_id_type unknown typeString '#{root.typeString}'")

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
      puts root
      throw new Error("walk_param unknown nodeType '#{root.nodeType}'")

class Context
  need_prevent_deploy : false
  constructor:()->

prev_root = null # DEBUG only
walk = (root, ctx)->
  if !root
    puts prev_root
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
      ret
    
    when "ContractDefinition"
      ret = new ast.Class_decl
      
      switch root.contractKind
        when "contract"
          ret.is_contract = true
        
        when "library"
          ret.is_library = true
        
        else
          throw new Error "unknown contractKind #{root.contractKind}"
      
      ret.inheritance_list = []
      for v in root.baseContracts
        if v.arguments
          throw new Error "arguments not supported for inheritance for now"
        ret.inheritance_list.push {
          name : v.baseName.name
          # TODO arg_list
        }
      ret.name = root.name
      for node in root.nodes
        ret.scope.list.push walk node, ctx
      
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
      puts "NOTE bad UsingForDirective"
      ret = new ast.Comment
      ret.text = "UsingForDirective"
      ret
    
    when "StructDefinition"
      ret = new ast.Class_decl
      ret.name = root.name
      for v in root.members
        ret.scope.list.push walk v, ctx
      ret
    
    when "InlineAssembly"
      puts "NOTE bad InlineAssembly"
      ret = new ast.Comment
      ret.text = "InlineAssembly #{root.operations}"
      ret
    
    when "EventDefinition"
      puts "NOTE bad EventDefinition"
      ret = new ast.Comment
      ret.text = "EventDefinition #{root.name}"
      ret
    
    when "EmitStatement"
      puts "NOTE bad EmitStatement"
      ret = new ast.Comment
      ret.text = "EmitStatement"
      ret
    
    when "PlaceholderStatement"
      ret = new ast.Comment
      ret.text = "COMPILER MSG PlaceholderStatement"
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
        perr "NOTE can't resolve type #{err}"
      ret
    
    when "Literal"
      ret = new ast.Const
      ret.type  = new Type root.kind
      ret.val   = root.value
      ret
    
    when "VariableDeclaration"
      ret = new ast.Var_decl
      ret._const = root.constant
      ret.name = root.name
      ret.type = walk_type root.typeName, ctx
      # ret.type = new Type root.typeDescriptions.typeIdentifier
      if root.value
        ret.assign_value = walk root.value, ctx
      # root.typeName
      # storage : root.storageLocation
      # state   : root.stateVariable
      # visibility   : root.visibility
      ret
    
    when "Assignment"
      ret = new ast.Bin_op
      ret.op = bin_op_map[root.operator]
      if !ret.op
        throw new Error("unknown bin_op #{root.operator}")
      ret.a = walk root.leftHandSide, ctx
      ret.b = walk root.rightHandSide, ctx
      ret
    
    when "BinaryOperation"
      ret = new ast.Bin_op
      ret.op = bin_op_map[root.operator]
      if !ret.op
        throw new Error("unknown bin_op #{root.operator}")
      ret.a = walk root.leftExpression, ctx
      ret.b = walk root.rightExpression, ctx
      ret
    
    when "MemberAccess"
      ret = new ast.Field_access
      ret.t = walk root.expression, ctx
      ret.name = root.memberName
      ret
    
    when "IndexAccess"
      ret = new ast.Bin_op
      ret.op = "INDEX_ACCESS"
      ret.a = walk root.baseExpression, ctx
      ret.b = walk root.indexExpression, ctx
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
        puts root
        throw new Error("unknown un_op #{root.operator}")
      ret.a = walk root.subExpression, ctx
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
            puts arg_list
            throw new Error "arg_list.length != 1"
          ret = fn
          ret.t = arg_list[0]
        
        else
          ret = new ast.Fn_call
          ret.fn = fn
          ret.arg_list = arg_list
      
      ret
    
    when "TupleExpression"
      ret = new ast.Tuple
      for v in root.components
        if v?
          ret.list.push walk v, ctx
        else
          ret.list.push null
      ret
    
    when "NewExpression"
      ret = new ast.New
      ret.cls = walk_type root.typeName, ctx
      ret
    
    when "ElementaryTypeNameExpression"
      ret = new ast.Type_cast
      ret.target_type = walk_type root.typeName, ctx
      ret
    
    when "Conditional"
      ret = new ast.Ternary
      ret.cond  = walk root.condition       , ctx
      ret.t     = walk root.trueExpression  , ctx
      ret.f     = walk root.falseExpression , ctx
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
              perr "NOTE can't resolve type #{err}"
            
            ret.list.push {
              name : decl.name
              type
            }
        if root.initialValue
          ret.assign_value = walk root.initialValue, ctx
        
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
        ret
    
    when "Block"
      ret = new ast.Scope
      for node in root.statements
        ret.list.push walk node, ctx
      ret
    
    when "IfStatement"
      ret = new ast.If
      ret.cond = walk root.condition, ctx
      ret.t    = walk root.trueBody,  ctx
      if root.falseBody
        ret.f    = walk root.falseBody, ctx
      ret
    
    when "WhileStatement"
      ret = new ast.While
      ret.cond = walk root.condition, ctx
      ret.scope= walk root.body, ctx
      ret
    
    when "ForStatement"
      ret = new ast.For3
      if root.initializationExpression
        ret.init = walk root.initializationExpression, ctx
      if root.condition
        ret.cond = walk root.condition, ctx
      if root.loopExpression
        ret.iter = walk root.loopExpression, ctx
      ret.scope= walk root.body, ctx
      ret
    
    # ###################################################################################################
    #    control flow
    # ###################################################################################################
    when "Return"
      ret = new ast.Ret_multi
      if root.expression
        ret.t_list.push walk root.expression, ctx
      ret
    
    when "Break"
      ret = new ast.Break
      ret
    
    when "Continue"
      ret = new ast.Continue
      ret
    
    when "Throw"
      ret = new ast.Throw
      ret
    
    # ###################################################################################################
    #    Func
    # ###################################################################################################
    when "FunctionDefinition", "ModifierDefinition"
      ret = ctx.current_function = new ast.Fn_decl_multiret
      ret.is_modifier = root.nodeType == "ModifierDefinition"
      ret.name = root.name or "constructor"
      
      ret.type_i =  new Type "function"
      ret.type_o =  new Type "function"
      
      ret.type_i.nest_list = walk_param root.parameters, ctx
      unless ret.is_modifier
        ret.type_o.nest_list = walk_param root.returnParameters, ctx
      
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
          for v in scope_prepend_list
            ret_multi.t_list.push _var = new ast.Var
            _var.name = v.name
      
      ret.visibility = root.visibility
      ret.state_mutability = root.stateMutability
      ret
    
    when "EnumDefinition"
      ret = new ast.Enum_decl
      ret.name = root.name
      for member in root.members
        ret.value_list.push decl = new ast.Var_decl
        decl.name = member.name
        # decl.type = new Type ret.name
        # skip type declaration since solidity enums aren't typed
      ret
    
    else
      puts root
      throw new Error("walk unknown nodeType '#{root.nodeType}'")
  
  if ctx.need_prevent_deploy
    result.need_prevent_deploy = true
  result


@gen = (root)->
  walk root, new Context