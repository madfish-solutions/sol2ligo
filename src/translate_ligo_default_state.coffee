module = @
require "fy/codegen"
config = require "./config"
Type = require "type"
{
  translate_type
  type2default_value
  translate_var_name
} = require "./translate_ligo"
# ###################################################################################################

class @Gen_context
  next_gen : null
  var_hash : {}
  contract_hash : {}
  
  constructor:()->
    @var_hash = {}
    @contract_hash = {}
  
  mk_nest_contract : (name)->
    t = new module.Gen_context
    @contract_hash[name] = t.var_hash
    t

last_bracket_state = false
walk = (root, ctx)->
  last_bracket_state = false
  switch root.constructor.name
    when "Scope"
      switch root.original_node_type
        when "SourceUnit"
          for v in root.list
            walk v, ctx
        
        when "ContractDefinition"
          ctx = ctx.mk_nest_contract(root.name)
          for v in root.list
            walk v, ctx
        
        else
          if !root.original_node_type
            "DO NOT PASS"
          else
            puts root
            throw new Error "Unknown root.original_node_type #{root.original_node_type}"
    # ###################################################################################################
    #    stmt
    # ###################################################################################################
    when "Comment", "Fn_decl_multiret", "Enum_decl"
      "nothing"
    
    when "Var_decl"
      ctx.var_hash[root.name] = {
        type  : translate_type root.type
        value : type2default_value root.type
      }
    
    when "Class_decl"
      walk root.scope, ctx
    
    else
      if ctx.next_gen?
        ctx.next_gen root, ctx
      else
        # TODO gen extentions
        puts root
        throw new Error "Unknown root.constructor.name #{root.constructor.name}"

@gen = (root, opt = {})->
  opt.convert_to_string ?= true
  ctx = new module.Gen_context
  ctx.next_gen = opt.next_gen
  walk root, ctx
  
  for k,v of ctx.contract_hash
    if 0 == h_count v
      type = new Type "uint"
      v[config.empty_state] = {
        type  : translate_type type
        value : type2default_value type
      }
  
  if !opt.convert_to_string
    return ctx.contract_hash
  
  # TODO proper convert
  jl = []
  for k,contract of ctx.contract_hash
    field_jl = []
    for var_name, var_content of contract
      field_jl.push "#{var_name} = #{var_content.value};"
    jl.push """
      record
        #{join_list field_jl, '  '}
      end
      """
  join_list jl, ''
