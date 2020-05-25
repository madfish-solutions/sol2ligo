{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"

walk = (root, ctx)->
  {walk} = ctx
  switch root.constructor.name
    when "Fn_call"
      if root.fn.t?.type
        switch root.fn.t.type.main
          when "address"
            switch root.fn.name
              when "transfer"
                insp root, 5
                inject = new ast.Fn_call
                inject.fn = new ast.Var
                inject.fn.name = "@transaction"
                inject.arg_list.push params = new ast.Const
                params.type = new Type "Unit"
                params.val = "unit"

                inject.arg_list.push cost = new ast.Bin_op
                cost.op = "MUL"
                cost.a = root.arg_list[0]
                cost.b = new ast.Const
                cost.b.val = 1
                cost.b.type = new Type "mutez"

                inject.arg_list.push contract_cast = new ast.Type_cast
                
                arg_types = (arg.type for arg in root.arg_list)
                composite_type = arg_types.join ","

                contract_cast.target_type = new Type "contract"
                contract_cast.target_type.val = composite_type
                
                get_contract = new ast.Fn_call
                get_contract.type = "function2<function<uint>, function<address>>"
                get_contract.fn = new ast.Var
                get_contract.fn.name = "get_contract"

                get_contract.arg_list.push root.fn.t

                contract_cast.t = get_contract

                return inject
             
              else
                throw new Error "unknown address field #{root.fn.name}"
            return "var #{config.op_list} : list(operation) := list #{op_code} end"


      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx

@erc20_converter = (root, ctx)-> 
  walk root, ctx = obj_merge({walk, next_gen: default_walk}, ctx)