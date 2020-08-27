{ default_walk } = require "./default_walk"
{ translate_var_name } = require "../translate_var_name"
ast = require "../ast"
Type = require "type"
config = require "../config"


func2args_struct = (name)->
  name = name+"_args"
  name = translate_var_name name, null
  name

func2struct = (name)->
  name = translate_var_name name, null
  name = name.capitalize()
  if name.length > 31
    new_name = name.substr 0, 31
    perr "WARNING entrypoint names longer than 31 character are not supported in LIGO. We trimmed #{name} to #{new_name}. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#name-length-for-types"
    name = new_name
  name

walk = (root, ctx)->
  {walk} = ctx
  switch root.constructor.name
    when "Class_decl"
      if root.is_contract and root.is_last
        # ###################################################################################################
        #    patch state
        # ###################################################################################################

        
        # ###################################################################################################
        #    add struct for each endpoint
        # ###################################################################################################
        return ctx.next_gen root, ctx if ctx.contract and root.name != ctx.contract

        for func in ctx.router_func_list
          root.scope.list.push record = new ast.Class_decl
          record.name = func2args_struct func.name
          record.namespace_name = false
          start = 0
          start++ if func.uses_storage
          start++ if func.returns_op_list
          
          for value,idx in func.arg_name_list[start..]
            record.scope.list.push arg = new ast.Var_decl
            arg.name = value
            arg.type = func.type_i.nest_list[start+idx]
          
          if func.returns_value
            record.scope.list.push arg = new ast.Var_decl
            arg.name = config.callback_address
            arg.type = new Type "address"
        
        root.scope.list.push _enum = new ast.Enum_decl
        _enum.name = config.router_enum
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
        _main.type_o = new Type "function"
        
        _main.arg_name_list.push "action"
        _main.type_i.nest_list.push new Type config.router_enum
        _main.arg_name_list.push config.contract_storage
        _main.type_i.nest_list.push new Type config.storage
        
        _main.type_o.nest_list.push new Type "built_in_op_list"
        _main.type_o.nest_list.push new Type config.storage
        _main.scope.need_nest = false
        _main.scope.list.push ret = new ast.Tuple
        
        ret.list.push _switch = new ast.PM_switch
        _switch.cond = new ast.Var
        _switch.cond.name = "action"
        _switch.cond.type = new Type "string" # TODO proper type
        
        for func in ctx.router_func_list
          _switch.scope.list.push _case = new ast.PM_case
          _case.struct_name = func2struct func.name
          _case.var_decl.name = "match_action"
          _case.var_decl.type = new Type _case.struct_name
          
          call = new ast.Fn_call
          call.left_unpack = false
          call.fn = new ast.Var
          call.fn.name = func.name
          # NOTE that PM_switch is ignored by type inference
          # BUG. Type inference should resolve this fn properly
          
          # NOTE. will be changed in type inference
          call.fn.type = new Type "function2"
          call.fn.type.nest_list[0] = func.type_i
          call.fn.type.nest_list[1] = func.type_o
          for arg_name,idx in func.arg_name_list
            switch arg_name
              when config.contract_storage
                arg = new ast.Var
                arg.name = arg_name
                arg.type = new Type config.storage
                arg.name_translate = false
                call.arg_list.push arg
              when config.op_list
                arg = new ast.Const
                arg.type = new Type "built_in_op_list"
                call.arg_list.push arg
              else
                arg = new ast.Var
                arg.name = _case.var_decl.name
                arg.type = _case.var_decl.type
                call.arg_list.push match_shoulder = new ast.Field_access
                match_shoulder.name = arg_name
                match_shoulder.t = arg
          
          
          if !func.returns_value and (func.returns_op_list or func.modifies_storage)
            # without block
            # simpliest code is generated
            _case.scope.need_nest = false
            if func.returns_op_list and func.modifies_storage
              _case.scope.list.push call
            else
              _case.scope.list.push ret_tuple = new ast.Tuple
              if !func.returns_op_list
                ret_tuple.list.push _var = new ast.Const
                _var.type = new Type "built_in_op_list"
              ret_tuple.list.push call
              if !func.modifies_storage
                ret_tuple.list.push _var = new ast.Var
                _var.type = new Type config.storage
                _var.name = config.contract_storage
                _var.name_translate = false
          else
            # with block
            _case.scope.need_nest = true
            if !func.returns_value
              _case.scope.list.push comment = new ast.Comment
              comment.text = "This function does nothing, but it's present in router"
              perr "WARNING. Function named #{func.name} does nothing, but we put it in the router nonetheless"
            # tmp var is needed in any case
            _case.scope.list.push tmp = new ast.Var_decl
            tmp.name = "tmp"
            tmp.assign_value = call
            tmp.type = func.type_o.clone() # safe deep clone
            tmp.type.main = "tuple" # rename type function2 -> tuple
            ret_tuple = new ast.Tuple
            
            arg_num = 0
            access_gen = ()->
              tmp_access = new ast.Field_access
              tmp_access.type = tmp.type.nest_list[arg_num]
              tmp_access.name = arg_num.toString()
              arg_num++
              tmp_access.t = var_tmp = new ast.Var
              var_tmp.name = "tmp"
              tmp_access
            # fix tuple size 1
            if +func.returns_op_list + +func.modifies_storage + +func.returns_value == 1
              access_gen = ()->
                var_tmp = new ast.Var
                var_tmp.name = "tmp"
                var_tmp.type = tmp.type.nest_list[0]
                var_tmp
            
            if func.returns_op_list
              ret_tuple.list.push access_gen()
            else
              if func.returns_value
                ret_tuple.list.push _var = new ast.Var
                _var.name = config.op_list
              else
                ret_tuple.list.push _var = new ast.Const
                _var.type = new Type "built_in_op_list"
            
            if func.modifies_storage
              ret_tuple.list.push access_gen()
            else
              ret_tuple.list.push _var = new ast.Var
              _var.type = new Type config.storage
              _var.name = config.contract_storage
              _var.name_translate = false
            
            arg_num = 0
            ret_val = access_gen()
            
            if func.returns_value
              _case.scope.list.push proxy_call = new ast.Fn_call
              proxy_call.fn = new ast.Var
              if func.returns_op_list
                ops_extract = new ast.Field_access
                ops_extract.name = "0"
                ops_extract.t = var_tmp = new ast.Var
                var_tmp.name = "tmp"
                var_tmp.type = tmp.type.clone()
                ops_extract.type = tmp.type.nest_list[0].clone()
                
                proxy_call.fn.name = "@respond_append"
                proxy_call.arg_list = [ops_extract, ret_val]
              else
                proxy_call.fn.name = "@respond"
                proxy_call.arg_list = [ret_val]
            
            _case.scope.list.push ret = new ast.Ret_multi
            ret.t_list.push ret_tuple
        root
      else
        ctx.next_gen root, ctx
    else
      ctx.next_gen root, ctx

@add_router = (root, ctx)->
  walk root, obj_merge({walk, next_gen: default_walk}, ctx)
