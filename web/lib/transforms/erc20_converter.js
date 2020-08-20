(function() {
  var Type, ast, astBuilder, callback_tx_node, config, default_walk, tx_node, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  astBuilder = require("../ast_builder");

  tx_node = function(address_expr, arg_list, name, ctx) {
    var entrypoint, enum_val, tx;
    address_expr = astBuilder.contract_addr_transform(address_expr);
    entrypoint = astBuilder.foreign_entrypoint(address_expr, "fa12_action");
    enum_val = astBuilder.enum_val("@" + name, arg_list);
    tx = astBuilder.transaction([enum_val], entrypoint);
    return tx;
  };

  callback_tx_node = function(name, root, ctx) {
    var arg_list, cb_decl, cb_name, contract_type, return_callback, return_type;
    cb_name = name.substr(0, 1).toLowerCase() + name.substr(1) + "Callback";
    contract_type = new Type("contract");
    contract_type.val = "nat";
    return_callback = astBuilder.self_entrypoint("%" + cb_name, contract_type);
    if (!ctx.callbacks_to_declare_map.has(cb_name)) {
      return_type = root.fn.type.nest_list[ast.RETURN_VALUES].nest_list[ast.INPUT_ARGS];
      cb_decl = astBuilder.callback_declaration(name, return_type);
      ctx.callbacks_to_declare_map.set(cb_name, cb_decl);
    }
    arg_list = root.arg_list;
    arg_list.push(return_callback);
    return tx_node(root.fn.t, arg_list, name, ctx);
  };

  walk = function(root, ctx) {
    var arg_list, entry, ret, sender, _i, _len, _ref, _ref1;
    switch (root.constructor.name) {
      case "Class_decl":
        _ref = root.scope.list;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          if (entry.constructor.name === "Fn_decl_multiret") {
            switch (entry.name) {
              case "approve":
              case "totalSupply":
              case "balanceOf":
              case "allowance":
              case "transfer":
              case "transferFrom":
                ret = new ast.Include;
                ret.path = "interfaces/fa1.2.ligo";
                return ret;
            }
          }
        }
        ctx.callbacks_to_declare_map = new Map;
        root = ctx.next_gen(root, ctx);
        ctx.callbacks_to_declare_map.forEach(function(decl) {
          return root.scope.list.unshift(decl);
        });
        return root;
      case "Fn_decl_multiret":
        ctx.current_scope_ops_count = 0;
        return ctx.next_gen(root, ctx);
      case "Fn_call":
        if ((_ref1 = root.fn.t) != null ? _ref1.type : void 0) {
          switch (root.fn.t.type.main) {
            case "struct":
              switch (root.fn.name) {
                case "transfer":
                  sender = astBuilder.tezos_var("sender");
                  arg_list = root.arg_list;
                  arg_list.unshift(sender);
                  return tx_node(root.fn.t, arg_list, "Transfer", ctx);
                case "approve":
                  arg_list = root.arg_list;
                  arg_list[0] = astBuilder.cast_to_address(arg_list[0]);
                  return tx_node(root.fn.t, arg_list, "Approve", ctx);
                case "transferFrom":
                  arg_list = root.arg_list;
                  arg_list[1] = astBuilder.cast_to_address(arg_list[1]);
                  return tx_node(root.fn.t, arg_list, "Transfer", ctx);
                case "allowance":
                  ret = root;
                  ret.arg_list[0] = astBuilder.cast_to_address(ret.arg_list[0]);
                  ret.arg_list[1] = astBuilder.cast_to_address(ret.arg_list[1]);
                  return callback_tx_node("GetAllowance", ret, ctx);
                case "balanceOf":
                  ret = root;
                  ret.arg_list[0] = astBuilder.cast_to_address(ret.arg_list[0]);
                  return callback_tx_node("GetBalance", ret, ctx);
                case "totalSupply":
                  ret = root;
                  ret.arg_list.unshift(astBuilder.unit());
                  return callback_tx_node("GetTotalSupply", ret, ctx);
              }
          }
        }
        return ctx.next_gen(root, ctx);
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.erc20_converter = function(root, ctx) {
    return walk(root, ctx = obj_merge({
      walk: walk,
      next_gen: default_walk
    }, ctx));
  };

}).call(window.require_register("./transforms/erc20_converter"));
