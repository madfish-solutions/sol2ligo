module = @
require "fy/codegen"
config = require "./config"
Type = require "type"
{
  translate_type
  type2default_value
} = require "./translate_smartpy"
{translate_var_name} = require "./translate_var_name_smartpy"
# ###################################################################################################

# this module generates initial storage for the contract which is needed for contract origination
# default state is later compiled to Michelson before being passed to a Tezos node

class @Gen_context
  next_gen : null
  var_map : {}
  last_contract_name : ""
  contract_map : {}
  type_decl_map: {}
  
  constructor:()->
    @var_map = {}
    @contract_map  = {}
    @type_decl_map = {}
  
  mk_nest_contract : (name)->
    t = new module.Gen_context
    @contract_map[name] = t.var_map
    obj_set t.type_decl_map, @type_decl_map
    t

last_bracket_state = false
walk = (root, ctx)->
  last_bracket_state = false
  switch root.constructor.name
    when "Scope"
      for v in root.list
        walk v, ctx
      "nothing"
    # ###################################################################################################
    #    stmt
    # ###################################################################################################
    when "Comment", \
         "Fn_decl_multiret", \
         "Enum_decl", \
         "Event_decl", \
         "Include"
      "nothing"
    
    when "Var_decl"
      ctx.var_map[root.name] = {
        type  : translate_type root.type, ctx
        value : type2default_value root.type, ctx
      }
      "nothing"
    
    when "Class_decl"
      return if root.need_skip
      ctx.type_decl_map[root.name] = root
      if root.is_contract
        if root.is_last
          ctx.last_contract_name = root.name
        ctx = ctx.mk_nest_contract(root.name)
      walk root.scope, ctx
    
    when "Enum_decl"
      ctx.type_decl_map[root.name] = root
      "nothing"
    
    else
      if ctx.next_gen?
        ctx.next_gen root, ctx
      else
        # TODO gen extentions
        perr root
        throw new Error "Unknown root.constructor.name #{root.constructor.name}"

@gen = (root, opt = {})->
  opt.convert_to_string ?= true
  ctx = new module.Gen_context
  ctx.next_gen = opt.next_gen
  walk root, ctx
  
  # for k,v of ctx.contract_map
  #   if 0 == h_count v
  #     type = new Type "uint"
  #     v[config.empty_state] = {
  #       type  : translate_type type, ctx
  #       value : type2default_value type, ctx
  #     }
  
  if !opt.convert_to_string
    return ctx.contract_map
  
  # TODO proper convert
  jl = []
  for k,contract of ctx.contract_map
    continue if k != ctx.last_contract_name
    name = translate_var_name k, ctx
    field_jl = []
    for var_name, var_content of contract
      field_jl.push "#{var_name}=#{var_content.value}"
    jl.push """
      #{name}(#{field_jl.join ', '})
      """
  join_list jl, ''
