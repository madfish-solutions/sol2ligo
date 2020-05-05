module = @

{var_translate} = require "./transforms/var_translate"
{require_distinguish} = require "./transforms/require_distinguish"
{fix_missing_emit} = require "./transforms/fix_missing_emit"
{fix_modifier_order} = require "./transforms/fix_modifier_order"
{for3_unpack} = require "./transforms/for3_unpack"
{math_funcs_convert} = require "./transforms/math_funcs_convert"
{ass_op_unpack} = require "./transforms/ass_op_unpack"
{modifier_unpack} = require "./transforms/modifier_unpack"
{inheritance_unpack} = require "./transforms/inheritance_unpack"
{contract_storage_fn_decl_fn_call_ret_inject} = require "./transforms/contract_storage_fn_decl_fn_call_ret_inject"
{router_collector} = require "./transforms/router_collector"
{add_router} = require "./transforms/add_router"

{translate_var_name} = require "./translate_var_name"
{translate_type} = require "./translate_ligo"

@ligo_pack = (root, opt={})->
  opt.router ?= true
  root = var_translate root
  root = require_distinguish root
  root = fix_missing_emit root
  root = fix_modifier_order root
  root = for3_unpack root
  root = math_funcs_convert root
  root = ass_op_unpack root
  root = modifier_unpack root
  root = inheritance_unpack root
  root = contract_storage_fn_decl_fn_call_ret_inject root, opt
  if opt.router
    router_func_list = router_collector root, opt
    root = add_router root, obj_merge {router_func_list}, opt
  root