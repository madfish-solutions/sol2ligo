Type = require 'type'
ast = require './ast'

bin_op_map =
  '+'   : 'ADD'
  '-'   : 'SUB'
  '*'   : 'MUL'
  '/'   : 'DIV'
  '%'   : 'MOD'
  '**'  : 'POW'
  '>>'  : 'SHR'
  '<<'  : 'SHL'
  
  '&' : 'BIT_AND'
  '|' : 'BIT_OR'
  '^' : 'BIT_XOR'
  
  '&&' : 'BOOL_AND'
  '||' : 'BOOL_OR'
  
  '==' : 'EQ'
  '!=' : 'NE'
  '>'  : 'GT'
  '<'  : 'LT'
  '>=' : 'GTE'
  '<=' : 'LTE'
  
  '='  : 'ASSIGN'
  '+=' : 'ASS_ADD'
  '-=' : 'ASS_SUB'
  '*=' : 'ASS_MUL'
  '/=' : 'ASS_DIV'
  
  '>>=': 'ASS_SHR'
  '<<=': 'ASS_SHL'
  
  '&=' : 'ASS_BIT_AND'
  '|=' : 'ASS_BIT_OR'
  '^=' : 'ASS_BIT_XOR'

is_complex_assign_op =
  'ASS_ADD' : true
  'ASS_SUB' : true
  'ASS_MUL' : true
  'ASS_DIV' : true

un_op_map =
  '-' : 'MINUS'
  '+' : 'PLUS'
  '~' : 'BIT_NOT'
  '!' : 'BOOL_NOT'
  'delete' : 'CUSTOM_DELETE'

un_op_pre_map =
  '++': 'INC_RET'
  '--': 'DEC_RET'

un_op_post_map =
  '++': 'RET_INC'
  '--': 'RET_DEC'

walk_type = (root, ctx)->
  switch root.nodeType
    when 'ElementaryTypeName'
      new Type root.typeDescriptions.typeIdentifier
    
    when 'UserDefinedTypeName'
      puts "NOTE bad UserDefinedTypeName #{root.name}"
      new Type root.name
    
    when 'ArrayTypeName'
      ret = new Type 'array'
      ret.nest_list.push walk_type root.baseType, ctx
      ret
    
    when 'Mapping'
      ret = new Type "map"
      ret.nest_list.push walk_type root.keyType, ctx
      ret.nest_list.push walk_type root.valueType, ctx
      ret
    
    else
      puts root
      throw new Error("walk_type unknown nodeType '#{root.nodeType}'")

walk_param = (root, ctx)->
  switch root.nodeType
    when 'ParameterList'
      ret = []
      for v in root.parameters
        ret.append walk_param v, ctx
      ret
    
    when 'VariableDeclaration'
      if root.value
        throw new Error("root.value not implemented")
      ret = []
      t = new Type root.typeDescriptions.typeIdentifier
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
    when 'SourceUnit', 'ContractDefinition'
      ret = new ast.Scope
      ret.original_node_type = root.nodeType
      for node in root.nodes
        ret.list.push walk node, ctx
      ret
    
    # ###################################################################################################
    #    Unsupported stuff
    # ###################################################################################################
    when 'PragmaDirective'
      # JUST PASS
      ret = new ast.Comment
      ret.text = "PragmaDirective #{root.literals.join ' '}"
      ret
    
    when 'UsingForDirective'
      puts "NOTE bad UsingForDirective"
      ret = new ast.Comment
      ret.text = "UsingForDirective"
      ret
    
    when 'StructDefinition'
      puts "NOTE bad StructDefinition"
      ret = new ast.Comment
      ret.text = "StructDefinition #{root.canonicalName}"
      ret
    
    when 'InlineAssembly'
      puts "NOTE bad InlineAssembly"
      ret = new ast.Comment
      ret.text = "InlineAssembly #{root.operations}"
      ret
    
    when 'EventDefinition'
      puts "NOTE bad EventDefinition"
      ret = new ast.Comment
      ret.text = "EventDefinition #{root.name}"
      ret
    
    when 'EmitStatement'
      puts "NOTE bad EmitStatement"
      ret = new ast.Comment
      ret.text = "EmitStatement"
      ret
    
    when 'ModifierDefinition'
      puts "WARNING skip ModifierDefinition #{root.name}"
      puts "WARNING this can lead to security issue. DON'T deploy it or you will be fired!"
      ctx.need_prevent_deploy = true
      walk root.body, ctx
    
    when 'PlaceholderStatement'
      ret = new ast.Comment
      ret.text = "PlaceholderStatement"
      ret
    
    # ###################################################################################################
    #    expr
    # ###################################################################################################
    when 'Identifier'
      ret = new ast.Var
      ret.name = root.name
      ret.type = new Type root.typeDescriptions.typeIdentifier
      ret
    
    when 'Literal'
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
    
    when 'Assignment'
      ret = new ast.Bin_op
      ret.op = bin_op_map[root.operator]
      if !ret.op
        throw new Error("unknown bin_op #{root.operator}")
      ret.a = walk root.leftHandSide, ctx
      ret.b = walk root.rightHandSide, ctx
      ret
    
    when 'BinaryOperation'
      ret = new ast.Bin_op
      ret.op = bin_op_map[root.operator]
      if !ret.op
        throw new Error("unknown bin_op #{root.operator}")
      ret.a = walk root.leftExpression, ctx
      ret.b = walk root.rightExpression, ctx
      ret
    
    when 'MemberAccess'
      ret = new ast.Field_access
      ret.t = walk root.expression, ctx
      ret.name = root.memberName
      ret
    
    when 'IndexAccess'
      ret = new ast.Bin_op
      ret.op = 'INDEX_ACCESS'
      ret.a = walk root.baseExpression, ctx
      ret.b = walk root.indexExpression, ctx
      ret
    
    when 'UnaryOperation'
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
    
    when 'FunctionCall'
      ret = new ast.Fn_call
      ret.fn = new ast.Var
      ret.fn.name = root.expression.name
      
      for v in root.arguments
        ret.arg_list.push walk v, ctx
      ret
    
    when 'TupleExpression'
      ret = new ast.Tuple
      for v in root.components
        if v?
          ret.list.push walk v, ctx
        else
          ret.list.push null
      ret
    
    when 'Conditional'
      ret = new ast.Ternary
      ret.cond  = walk root.condition       , ctx
      ret.t     = walk root.trueExpression  , ctx
      ret.f     = walk root.falseExpression , ctx
      ret
    # ###################################################################################################
    #    stmt
    # ###################################################################################################
    when 'ExpressionStatement'
      walk root.expression, ctx
    
    when 'VariableDeclarationStatement'
      if root.declarations.length != 1
        ret = new ast.Var_decl_multi
        for decl in root.declarations
          if !decl?
            ret.list.push {
              skip: true
            }
            continue
          p "NOTE bad type #{decl.typeDescriptions.typeIdentifier}"
          ret.list.push {
            name : decl.name
            # type : walk_type ast_tree.typeName, ctx # он почему-то null
            # TODO неправильный тип
            type : new Type decl.typeDescriptions.typeIdentifier
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
        ret.type = new Type decl.typeDescriptions.typeIdentifier
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
    
    when 'WhileStatement'
      ret = new ast.While
      ret.cond = walk root.condition, ctx
      ret.scope= walk root.body, ctx
      ret
    
    when 'ForStatement'
      ret = new ast.Scope
      ret._phantom = true # HACK
      if root.initializationExpression
        ret.list.push walk root.initializationExpression, ctx
      ret.list.push inner = new ast.While
      inner.cond = walk root.condition, ctx
      
      loc = walk root.body, ctx
      if loc.constructor.name == 'Scope'
        inner.scope = loc
      else
        inner.scope.list.push loc
      
      # т.к. у нас нет continue, то можно
      inner.scope.list.push walk root.loopExpression, ctx
      ret
    
    # ###################################################################################################
    #    control flow
    # ###################################################################################################
    when 'Return'
      ret = new ast.Ret_multi
      if root.expression
        ret.t_list.push walk root.expression, ctx
      ret
    
    when 'Break'
      ret = new ast.Break
      ret
    
    when 'Continue'
      ret = new ast.Continue
      ret
    
    when 'Throw'
      ret = new ast.Throw
      ret
    
    # ###################################################################################################
    #    Func
    # ###################################################################################################
    when "FunctionDefinition"
      fn = ctx.current_function = new ast.Fn_decl_multiret
      fn.name = root.name or 'constructor'
      
      fn.type_i =  new Type 'function'
      fn.type_o =  new Type 'function'
      
      fn.type_i.nest_list = walk_param root.parameters, ctx
      fn.type_o.nest_list = walk_param root.returnParameters, ctx
      
      for v in fn.type_i.nest_list
        fn.arg_name_list.push v._name
      # ctx.stateMutability
      if root.modifiers.length
        puts "WARNING root.modifiers not implemented and will be ignored"
        puts root.modifiers
        puts "WARNING this can lead to security issue. DON'T deploy it or you will be fired!"
        ctx.need_prevent_deploy = true
        # throw new "root.modifiers not implemented"
      
      if root.body
        fn.scope = walk root.body, ctx
      else
        fn.scope = new ast.Scope
      fn
    
    
    else
      puts root
      throw new Error("walk unknown nodeType '#{root.nodeType}'")
  
  if ctx.need_prevent_deploy
    result.need_prevent_deploy = true
  result


module.exports = (root)->
  walk root, new Context