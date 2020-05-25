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
                inject.arg_list.push params = new ast.Tuple
                params.list = root.arg_list

                inject.arg_list.push tx_cost = new ast.Const
                tx_cost.val = 0
                tx_cost.type = new Type "mutez"

                inject.arg_list.push contract_cast = new ast.Type_cast
                
                arg_types = (arg.type for arg in root.arg_list)

                contract_cast.target_type = new Type "contract"
                contract_cast.target_type.nest_list = arg_types
                
                get_contract = new ast.Fn_call
                get_contract.type = "function2<function<uint>, function<address>>"
                get_contract.fn = new ast.Var
                get_contract.fn.name = "get_contract"

                get_contract.arg_list.push root.fn.t

                contract_cast.t = get_contract

                return inject
             
            # return "var #{config.op_list} : list(operation) := list #{op_code} end"

      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx

@erc20_converter = (root, ctx)-> 
  walk root, ctx = obj_merge({walk, next_gen: default_walk}, ctx)