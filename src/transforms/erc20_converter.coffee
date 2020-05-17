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
              when "send"
                call = new ast.Fn_call
                call.name = root.name
                perr "CRITICAL WARNING we don't check balance in send function. So runtime error will be ignored and no boolean return"
                # TODO check balance
                op_code = "transaction(unit, #{arg_list[0]} * 1mutez, (get_contract(#{t}) : contract(unit)))"
              
              when "transfer"
                tx = new ast.Fn_call
                tx.fn = new ast.Var
                tx.fn.left_unpack = true
                tx.fn.name = "transaction"
                tx.fn.type = new Type "function2"
                tx.fn.type.nest_list[ast.INPUT_ARGS] = new Type "function<uint256, uint256, contract>"
                tx.fn.type.nest_list[ast.RETURN_VALUES] = new Type "function<built_in_op_list>"

                tx.arg_list.push first = new ast.Const
                first.type = new Type "Unit"

                tx.arg_list.push second = new ast.Bin_op
                second.op = "MUL"
                second.a = root.arg_list[0]

                second.b = new ast.Const
                second.b.type = new Type "mutez"
                second.b.val = "1"

                tx.arg_list.push third = new ast.Type_cast
                third.target_type = new Type "contract"
                third.target_type.val = "unit"   
                
                third.t = new ast.Fn_call

                third.t.fn = new ast.Var
                third.t.fn.left_unpack = true
                third.t.fn.name = "get_contract"

                perr "WARNING we don't check balance in send function. So runtime error will be ignored and no throw"
                
                return tx
              when "call"
                perr "CRITICAL WARNING call function willl be conveerted into transaction, it doesn't return any value so your code may be wrong."
                perr "CRITICAL WARNING we don't check balance in call function. So runtime error will be ignored and no throw"
                if root.arg_list[0]
                  ret_type = translate_type root.arg_list[0].type, ctx
                  ret = arg_list[0]
                else
                  ret_type = "Unit"
                  ret = "unit"
                op_code = "transaction(#{ret}, 0mutez, (get_contract(#{t}) : contract(#{ret_type})))"    


              when "delegatecall"
                perr "CRITICAL WARNING we don't check balance in send function. So runtime error will be ignored and no throw"
                op_code = "transaction(#{arg_list[1]}, 1mutez, (get_contract(#{t}) : contract(#{arg_list[0]})))"
              
              when "built_in_pure_callback"
                # TODO check balance
                ret_type = translate_type root.arg_list[0].type, ctx
                ret = arg_list[0]
                op_code = "transaction(#{ret}, 0mutez, (get_contract(#{t}) : contract(#{ret_type})))"
              
              else
                throw new Error "unknown address field #{root.fn.name}"
            return "var #{config.op_list} : list(operation) := list #{op_code} end"


      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx

@erc20_converter = (root, ctx)-> 
  walk root, ctx = obj_merge({walk, next_gen: default_walk}, ctx)