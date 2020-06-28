module = @

{var_translate}                   = require "./transforms/var_translate"
{require_distinguish}             = require "./transforms/require_distinguish"
{fix_missing_emit}                = require "./transforms/fix_missing_emit"
{fix_modifier_order}              = require "./transforms/fix_modifier_order"
{for3_unpack}                     = require "./transforms/for3_unpack"
{math_funcs_convert}              = require "./transforms/math_funcs_convert"
{ass_op_unpack}                   = require "./transforms/ass_op_unpack"
{modifier_unpack}                 = require "./transforms/modifier_unpack"
{inheritance_unpack}              = require "./transforms/inheritance_unpack"
{decl_storage_and_oplist_inject}  = require "./transforms/decl_storage_and_oplist_inject"
{router_collector}                = require "./transforms/router_collector"
{add_router}                      = require "./transforms/add_router"
{collect_fn_decl}                 = require "./transforms/collect_fn_decl"
{call_storage_and_oplist_inject}  = require "./transforms/call_storage_and_oplist_inject"
{replace_enums_by_nat}            = require "./transforms/replace_enums_by_nat"
{intrinsics_converter}            = require "./transforms/intrinsics_converter"
{erc20_converter}                 = require "./transforms/erc20_converter"
{erc721_converter}                = require "./transforms/erc721_converter"
{return_op_list_count}            = require "./transforms/return_op_list_count"
{address_calls_converter}         = require "./transforms/address_calls_converter"

{translate_var_name} = require "./translate_var_name"
{translate_type} = require "./translate_ligo"

@pre_ti = (root, opt={})->
  opt.replace_enums_by_nats ?= true
  root = require_distinguish root
  root = fix_missing_emit root
  root = fix_modifier_order root
  root = for3_unpack root
  root = math_funcs_convert root
  root = ass_op_unpack root
  root = modifier_unpack root
  root = inheritance_unpack root
  if opt.replace_enums_by_nats
    root = replace_enums_by_nat root
  root

@post_ti = (root, opt={}) ->
  opt.router ?= true
  opt.prefer_erc721 ?= false

  root = address_calls_converter root
  root = ercs_translate root, opt
  root = intrinsics_converter root
  root = var_translate root
  root = decl_storage_and_oplist_inject root, opt
  func_decls = collect_fn_decl root
  root = call_storage_and_oplist_inject root, {func_decls}

  if opt.router
    router_func_list = router_collector root, opt
    root = add_router root, obj_merge {router_func_list}, opt

  root = return_op_list_count root, opt
  root

# add this weird multiplexer until we figure out better interface detection
ercs_translate = (root, opt) ->
  if opt.prefer_erc721
    root = erc721_converter root
    root = erc20_converter root
  else
    root = erc20_converter root
    root = erc721_converter root

  root