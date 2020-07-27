(function() {
  var add_router, address_calls_converter, ass_op_unpack, call_storage_and_oplist_inject, decl_storage_and_oplist_inject, deep_check_storage_and_oplist_use, erc20_converter, erc721_converter, ercs_translate, fix_missing_emit, fix_modifier_order, for3_unpack, inheritance_unpack, intrinsics_converter, mark_last, math_funcs_convert, modifier_unpack, module, replace_enums_by_nat, require_distinguish, return_op_list_count, router_collector, split_nested_index_access, translate_type, translate_var_name, var_translate;

  module = this;

  var_translate = require("./transforms/var_translate").var_translate;

  require_distinguish = require("./transforms/require_distinguish").require_distinguish;

  fix_missing_emit = require("./transforms/fix_missing_emit").fix_missing_emit;

  fix_modifier_order = require("./transforms/fix_modifier_order").fix_modifier_order;

  for3_unpack = require("./transforms/for3_unpack").for3_unpack;

  math_funcs_convert = require("./transforms/math_funcs_convert").math_funcs_convert;

  ass_op_unpack = require("./transforms/ass_op_unpack").ass_op_unpack;

  modifier_unpack = require("./transforms/modifier_unpack").modifier_unpack;

  inheritance_unpack = require("./transforms/inheritance_unpack").inheritance_unpack;

  deep_check_storage_and_oplist_use = require("./transforms/deep_check_storage_and_oplist_use").deep_check_storage_and_oplist_use;

  decl_storage_and_oplist_inject = require("./transforms/decl_storage_and_oplist_inject").decl_storage_and_oplist_inject;

  mark_last = require("./transforms/mark_last").mark_last;

  router_collector = require("./transforms/router_collector").router_collector;

  add_router = require("./transforms/add_router").add_router;

  call_storage_and_oplist_inject = require("./transforms/call_storage_and_oplist_inject").call_storage_and_oplist_inject;

  replace_enums_by_nat = require("./transforms/replace_enums_by_nat").replace_enums_by_nat;

  intrinsics_converter = require("./transforms/intrinsics_converter").intrinsics_converter;

  erc20_converter = require("./transforms/erc20_converter").erc20_converter;

  erc721_converter = require("./transforms/erc721_converter").erc721_converter;

  return_op_list_count = require("./transforms/return_op_list_count").return_op_list_count;

  address_calls_converter = require("./transforms/address_calls_converter").address_calls_converter;

  split_nested_index_access = require("./transforms/split_nested_index_access").split_nested_index_access;

  translate_var_name = require("./translate_var_name").translate_var_name;

  translate_type = require("./translate_ligo").translate_type;

  this.pre_ti = function(root, opt) {
    if (opt == null) {
      opt = {};
    }
    if (opt.replace_enums_by_nats == null) {
      opt.replace_enums_by_nats = true;
    }
    root = require_distinguish(root);
    root = fix_missing_emit(root);
    root = fix_modifier_order(root);
    root = for3_unpack(root);
    root = math_funcs_convert(root);
    root = ass_op_unpack(root);
    root = modifier_unpack(root);
    root = inheritance_unpack(root);
    if (opt.replace_enums_by_nats) {
      root = replace_enums_by_nat(root);
    }
    return root;
  };

  this.post_ti = function(root, opt) {
    var router_func_list;
    if (opt == null) {
      opt = {};
    }
    if (opt.router == null) {
      opt.router = true;
    }
    if (opt.prefer_erc721 == null) {
      opt.prefer_erc721 = false;
    }
    root = split_nested_index_access(root);
    root = address_calls_converter(root);
    root = ercs_translate(root, opt);
    root = intrinsics_converter(root);
    root = var_translate(root);
    root = deep_check_storage_and_oplist_use(root);
    root = decl_storage_and_oplist_inject(root, opt);
    root = call_storage_and_oplist_inject(root);
    root = mark_last(root, opt);
    if (opt.router) {
      router_func_list = router_collector(root, opt);
      root = add_router(root, obj_merge({
        router_func_list: router_func_list
      }, opt));
    }
    root = return_op_list_count(root, opt);
    return root;
  };

  ercs_translate = function(root, opt) {
    if (opt.prefer_erc721) {
      root = erc721_converter(root);
      root = erc20_converter(root);
    } else {
      root = erc20_converter(root);
      root = erc721_converter(root);
    }
    return root;
  };

}).call(window.require_register("./ast_transform"));
