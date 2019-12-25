module = @
Type  = require 'type'
config= require './config'
ast   = require './ast'

do ()=>
  walk = (root, ctx)->
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
        for v,idx in root.arg_list
          root.arg_list[idx] = walk v, ctx
        root
      
      # ###################################################################################################
      #    stmt
      # ###################################################################################################
      when "Var_decl", "Comment"
        root
      
      when "Ret_multi"
        for v,idx in root.t_list
          root.t_list[idx] = walk v, ctx
        root
      
      when "If"
        root.cond = walk root.cond, ctx
        root.t    = walk root.t,    ctx
        root.f    = walk root.f,    ctx
        root
      
      when "Class_decl"
        root.scope = walk root.scope, ctx
        root
      
      when "Fn_decl_multiret"
        root.scope = walk root.scope, ctx
        root
      
      else
        puts root
        throw new Error "unknown root.constructor.name #{root.constructor.name}"
    
  module.default_walk = walk


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
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      # ###################################################################################################
      #    stmt
      # ###################################################################################################
      when "Ret_multi"
        for v,idx in root.t_list
          root.t_list[idx] = walk v, ctx
        root.t_list.unshift inject = new ast.Var
        inject.name = config.contract_storage
        root
      
      when "Fn_decl_multiret"
        root.scope = walk root.scope, ctx
        root.arg_name_list.unshift config.contract_storage
        root.type_i.nest_list.unshift new Type config.storage
        root.type_o.nest_list.unshift new Type config.storage
        
        last = root.scope.list.last()
        if last.constructor.name != "Ret_multi"
          last = new ast.Ret_multi
          last = walk last, ctx
          root.scope.list.push last
        
        root
      
      else
        ctx.next_gen root, ctx
  
  @contract_storage_fn_decl_fn_call_ret_inject = (root)->
    walk root, {walk, next_gen: module.default_walk}
    


@ligo_pack = (root)->
  root = module.ass_op_unpack root
  root = module.contract_storage_fn_decl_fn_call_ret_inject root