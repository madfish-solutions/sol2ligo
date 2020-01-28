module = @
Type  = require "type"
config= require "./config"
ast   = require "./ast"

do ()=>
  out_walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Scope"
        for v, idx in root.list
          root.list[idx] = walk v, ctx
        root
      # ###################################################################################################
      #    expr
      # ###################################################################################################
      when "Var", "Const"
        root
      
      when "Un_op"
        root.a = walk root.a, ctx
        root
      
      when "Bin_op"
        root.a = walk root.a, ctx
        root.b = walk root.b, ctx
        root
      
      when "Field_access"
        root.t = walk root.t, ctx
        root
      
      when "Fn_call"
        root.fn = walk root.fn, ctx
        for v,idx in root.arg_list
          root.arg_list[idx] = walk v, ctx
        root
      
      # ###################################################################################################
      #    stmt
      # ###################################################################################################
      when "Var_decl", "Comment"
        root
      
      when "Throw"
        if root.t
          walk root.t, ctx
        root
      
      when "Enum_decl", "Type_cast", "Tuple"
        root
      
      when "Ret_multi"
        for v,idx in root.t_list
          root.t_list[idx] = walk v, ctx
        root
      
      when "If", "Ternary"
        root.cond = walk root.cond, ctx
        root.t    = walk root.t,    ctx
        root.f    = walk root.f,    ctx
        root
      
      when "While"
        root.cond = walk root.cond, ctx
        root.scope= walk root.scope,ctx
        root
      
      # when "For3"
      #   ### !pragma coverage-skip-block ###
      #   # NOTE will be wiped in first ligo_pack preprocessor. So will be not covered
      #   if root.init
      #     root.init = walk root.init, ctx
      #   if root.cond
      #     root.cond = walk root.cond, ctx
      #   if root.iter
      #     root.iter = walk root.iter, ctx
      #   root.scope= walk root.scope, ctx
      #   root
      
      when "Class_decl"
        root.scope = walk root.scope, ctx
        root
      
      when "Fn_decl_multiret"
        root.scope = walk root.scope, ctx
        root
      
      when "Tuple"
        root
      
      else
        ### !pragma coverage-skip-block ###
        puts root
        throw new Error "unknown root.constructor.name #{root.constructor.name}"
    
  module.default_walk = out_walk

do ()=>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "For3"
        ret = new ast.Scope
        ret.need_nest = false
        
        if root.init
          ret.list.push root.init
        
        while_inside = new ast.While
        if root.cond
          while_inside.cond = root.cond
        else
          while_inside.cond = new ast.Const
          while_inside.cond.val = "true"
          while_inside.cond.type = new Type "bool"
        # clone scope
        while_inside.scope.list.append root.scope.list
        if root.iter
          while_inside.scope.list.push root.iter
        ret.list.push while_inside
        
        ret
      else
        ctx.next_gen root, ctx
    
  
  @for3_unpack = (root)->
    walk root, {walk, next_gen: module.default_walk}

do ()=>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Bin_op"
        if reg_ret = /^ASS_(.*)/.exec root.op
          ext = new ast.Bin_op
          ext.op = "ASSIGN"
          ext.a = root.a
          ext.b = root
          root.op = reg_ret[1]
          ext
        else
          root.a = walk root.a, ctx
          root.b = walk root.b, ctx
          root
      else
        ctx.next_gen root, ctx
    
  
  @ass_op_unpack = (root)->
    walk root, {walk, next_gen: module.default_walk}

do ()=>
  # TODO remove ctx.op_list and make it mandatory and fix all tests
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      # ###################################################################################################
      #    stmt
      # ###################################################################################################
      when "Ret_multi"
        for v,idx in root.t_list
          root.t_list[idx] = walk v, ctx
        if ctx.stateMutability != 'pure'
          root.t_list.unshift inject = new ast.Var
          inject.name = config.contract_storage

        if ctx.op_list
          root.t_list.unshift inject = new ast.Var
          inject.name = config.op_list
        root
      
      when "Fn_decl_multiret"
        ctx.stateMutability = root.stateMutability 
        root.scope = walk root.scope, ctx
        if root.stateMutability != 'pure'
          root.arg_name_list.unshift config.contract_storage
          root.type_i.nest_list.unshift new Type config.storage
          root.type_o.nest_list.unshift new Type config.storage

        if ctx.op_list
          root.arg_name_list.unshift config.op_list
          root.type_i.nest_list.unshift new Type "built_in_op_list"
          root.type_o.nest_list.unshift new Type "built_in_op_list"

        last = root.scope.list.last()
        if !last or last.constructor.name != "Ret_multi"
          last = new ast.Ret_multi
          last = walk last, ctx
          root.scope.list.push last
        
        root
      
      else
        ctx.next_gen root, ctx
  
  @contract_storage_fn_decl_fn_call_ret_inject = (root, ctx)->
    walk root, obj_merge({walk, next_gen: module.default_walk}, ctx)
    

do ()=>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Class_decl"
        return root if root.need_skip
        ctx.next_gen root, ctx
      
      when "Fn_decl_multiret"
        unless root.visibility in ["private", "internal"]
          ctx.router_func_list.push root
        root
      
      else
        ctx.next_gen root, ctx
  
  @router_collector = (root)->
    walk root, ctx = {walk, next_gen: module.default_walk, router_func_list: []}
    ctx.router_func_list


do ()=>
  func2args_struct = (name)->
    name = "#{config.fix_underscore}_#{name}" if name[0] == "_"
    name = name+"_args"
    name
  
  func2struct = (name)->
    name = "#{config.fix_underscore}_#{name}" if name[0] == "_"
    name = name.capitalize()
    if name.length > 31
      new_name = name.substr 0, 31
      perr "WARNING ligo doesn't understand id for enum longer than 31 char so we trim #{name} to #{new_name}"
      name = new_name
    name
  
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Class_decl"
        if root.is_contract
          # ###################################################################################################
          #    patch state
          # ###################################################################################################
          root.scope.list.push initialized = new ast.Var_decl
          initialized.name = config.initialized
          initialized.type = new Type "bool"
          
          # ###################################################################################################
          #    add struct for each endpoint
          # ###################################################################################################
          for func in ctx.router_func_list
            root.scope.list.push record = new ast.Class_decl
            record.name = func2args_struct func.name
            for value,idx in func.arg_name_list
              continue if idx == 0 # skip contract_storage
              if ctx.op_list
                continue if idx == 1 # skip op_list
              record.scope.list.push arg = new ast.Var_decl
              arg.name = value
              arg.type = func.type_i.nest_list[idx]
            if record.scope.list.length == 0
              record.scope.list.push arg = new ast.Var_decl
              arg.name = config.empty_state
              arg.type = new Type "int"
          
          root.scope.list.push _enum = new ast.Enum_decl
          _enum.name = "router_enum"
          for func in ctx.router_func_list
            _enum.value_list.push decl = new ast.Var_decl
            decl.name = func2struct func.name
            decl.type = new Type func2args_struct(func.name)
          
          # ###################################################################################################
          #    add router
          # ###################################################################################################
          # TODO _main -> main_fn
          root.scope.list.push _main = new ast.Fn_decl_multiret
          _main.name = "main"
          
          _main.type_i = new Type "function"
          _main.type_o =  new Type "function"
          
          _main.arg_name_list.push "action"
          _main.type_i.nest_list.push new Type "router_enum"
          _main.arg_name_list.push config.contract_storage
          _main.type_i.nest_list.push new Type config.storage
          
          if ctx.op_list
            _main.type_o.nest_list.push new Type "built_in_op_list"
          _main.type_o.nest_list.push new Type config.storage
          
          if ctx.op_list
            _main.scope.list.push op_list_decl = new ast.Var_decl
            op_list_decl.name = config.op_list
            op_list_decl.type = new Type "built_in_op_list"
          
          _main.scope.list.push _if = new ast.If
          _if.cond = new ast.Var
          _if.cond.name = config.initialized
          
          _if.f.list.push assign = new ast.Bin_op
          assign.op = "ASSIGN"
          assign.a = new ast.Var
          assign.a.name = config.initialized
          assign.b = new ast.Const
          assign.b.val = "true"
          assign.b.type = new Type "bool"
          
          _if.t.list.push _switch = new ast.PM_switch
          _switch.cond = new ast.Var
          _switch.cond.name = "action"
          _switch.cond.type = new Type "string" # TODO proper type
          
          for func in ctx.router_func_list
            _switch.scope.list.push _case = new ast.PM_case
            _case.struct_name = func2struct func.name
            _case.var_decl.name = "match_action"
            _case.var_decl.type = new Type _case.struct_name
            _case.scope.list.push call = new ast.Fn_call
            call.fn = new ast.Var
            call.fn.name = func.name # TODO word "constructor" gets corruped here
            # BUG. Type inference should resolve this fn properly
            call.fn.type = new Type "function2"
            call.fn.type.nest_list[0] = func.type_i
            call.fn.type.nest_list[1] = func.type_o
            call.fn.stateMutability = func.stateMutability
            for arg_name,idx in func.arg_name_list
              continue if idx == 0 # skip contract_storage
              if ctx.op_list
                continue if idx == 1 # skip op_list
              call.arg_list.push arg = new ast.Field_access
              arg.t = new ast.Var
              arg.t.name = _case.var_decl.name
              arg.t.type = _case.var_decl.type
              arg.name = arg_name
          _main.scope.list.push ret = new ast.Ret_multi
          if ctx.op_list
            ret.t_list.push _var = new ast.Var
            _var.name = config.op_list
          ret.t_list.push _var = new ast.Var
          _var.name = config.contract_storage
          
          root
        else
          ctx.next_gen root, ctx
      else
        ctx.next_gen root, ctx
  
  @add_router = (root, ctx)->
    walk root, obj_merge({walk, next_gen: module.default_walk}, ctx)

do ()=>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Comment"
        return root if root.text != "COMPILER MSG PlaceholderStatement"
        ctx.target_ast.clone()
      else
        ctx.next_gen root, ctx
  
  @placeholder_replace = (root, target_ast)->
    walk root, {walk, next_gen: module.default_walk, target_ast}
  
do ()=>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Var"
        return root if root.name != ctx.var_name
        ctx.target_ast.clone()
      else
        ctx.next_gen root, ctx
  
  @var_replace = (root, var_name, target_ast)->
    walk root, {walk, next_gen: module.default_walk, var_name, target_ast}
  
do ()=>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Class_decl"
        root = ctx.next_gen root, ctx
        ctx.class_hash[root.name] = root # store unmodified
        return root if !root.inheritance_list.length # for coverage purposes
        
        # reverse order
        # near first
        # https://habr.com/ru/company/dsec/blog/347110/
        inheritance_apply_list = []
        inheritance_list = root.inheritance_list
        while inheritance_list.length
          need_lookup_list = []
          for i in [inheritance_list.length-1 .. 0] by -1
            v = inheritance_list[i]
            if !class_decl = ctx.class_hash[v.name]
              throw new Error "can't find parent class #{parent.name}"
            
            class_decl.need_skip = true
            inheritance_apply_list.push v
            
            need_lookup_list.append class_decl.inheritance_list
          
          inheritance_list = need_lookup_list
        
        # keep unmodified stored in ctx.class_decl
        root = root.clone()
        
        for parent in inheritance_apply_list
          if !class_decl = ctx.class_hash[parent.name]
            throw new Error "can't find parent class #{parent.name}"
          look_list = class_decl.scope.list
          
          need_constuctor = null
          # import all fn except constructor (rename constructor)
          for v in look_list
            continue if v.constructor.name != "Fn_decl_multiret"
            v = v.clone()
            if v.name == "constructor"
              v.name = "#{parent.name}_constructor"
              v.visibility = "internal"
              need_constuctor = v
            
            root.scope.list.unshift v
          
          # import all vars (on top of fn)
          for v in look_list
            continue if v.constructor.name != "Var_decl"
            root.scope.list.unshift v.clone()
          
          # inject constructor call on top of my constructor (create my constructor if not exists)
          continue if !need_constuctor
          
          found_constructor = null
          for v in root.scope.list
            continue if v.constructor.name != "Fn_decl_multiret"
            continue if v.name != "constructor"
            found_constructor = v
            break
          
          # inject constructor call on top of my constructor (create my constructor if not exists)
          
          if !found_constructor
            root.list.push found_constructor = new ast.Fn_decl_multiret
            found_constructor.name = "constructor"
            found_constructor.type_i = new Type "function"
            found_constructor.type_o = new Type "function"
          
          found_constructor.scope.list.unshift fn_call = new ast.Fn_call
          fn_call.fn = new ast.Var
          fn_call.fn.name = need_constuctor.name
          # TODO LATER use arg_list for calling parent constructor
          
        root
      else
        ctx.next_gen root, ctx
    
  
  @inheritance_unpack = (root)->
    walk root, {walk, next_gen: module.default_walk, class_hash: {}}
  
do ()=>
  fn_apply_modifier = (fn, mod, ctx)->
    ###
    Possible intersections
      1. Var_decl
      2. Var_decl in arg_list
      3. Multiple placeholders = multiple cloned Var_decl
    ###
    if mod.fn.constructor.name != "Var"
      throw new Error "unimplemented"
    if !mod_decl = ctx.modifier_hash[mod.fn.name]
      throw new Error "unknown modifier #{mod.fn.name}"
    ret = mod_decl.scope.clone()
    prepend_list = []
    for arg, idx in mod.arg_list
      prepend_list.push var_decl = new ast.Var_decl
      # TODO search **fn** for this_var name and replace in **ret** with tmp
      var_decl.name = mod_decl.arg_name_list[idx]
      var_decl.assign_value = arg.clone()
      var_decl.type = mod_decl.type_i.nest_list[idx]
    
    ret = module.placeholder_replace ret, fn
    ret.list = arr_merge prepend_list, ret.list
    ret
  
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Fn_decl_multiret"
        if root.is_modifier
          ctx.modifier_hash[root.name] = root
          
          # remove node
          ret = new ast.Comment
          ret.text = "modifier #{root.name} removed"
          ret
        else
          return root if root.modifier_list.length == 0
          inner = root.scope.clone()
          inner.need_nest = false
          # TODO уточнить порядок применения modifier'ов
          for mod in root.modifier_list
            inner = fn_apply_modifier inner, mod, ctx
          
          ret = root.clone()
          ret.modifier_list.clear()
          ret.scope = inner
          ret
      else
        ctx.next_gen root, ctx
    
  
  @modifier_unpack = (root)->
    walk root, {walk, next_gen: module.default_walk, modifier_hash: {}}

@ligo_pack = (root, opt={})->
  opt.router ?= true
  opt.op_list ?= true
  root = module.for3_unpack root
  root = module.ass_op_unpack root
  root = module.modifier_unpack root
  root = module.inheritance_unpack root
  root = module.contract_storage_fn_decl_fn_call_ret_inject root, opt
  if opt.router
    router_func_list = module.router_collector root
    root = module.add_router root, obj_merge {router_func_list}, opt
  root