(function() {
  var Type, ast, astBuilder, config, default_walk, tx_node, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  astBuilder = require("../ast_builder");

  tx_node = function(arg_list, cost, address_expr, name, ctx) {
    var entrypoint, tez_cost, tx;
    entrypoint = astBuilder.foreign_entrypoint(address_expr, name);
    tez_cost = astBuilder.cast_to_tez(cost);
    tx = astBuilder.transaction(arg_list, entrypoint, tez_cost);
    return tx;
  };

  walk = function(root, ctx) {
    var _ref;
    switch (root.constructor.name) {
      case "Fn_decl_multiret":
        ctx.current_scope_ops_count = 0;
        return ctx.next_gen(root, ctx);
      case "Fn_call":
        if ((_ref = root.fn.t) != null ? _ref.type : void 0) {
          switch (root.fn.t.type.main) {
            case "address":
              switch (root.fn.name) {
                case "transfer":
                  return tx_node([astBuilder.unit()], root.arg_list[0], root.fn.t, "unit", ctx);
                case "delegatecall":
                  return tx_node([astBuilder.unit()], root.arg_list[0], root.fn.t, "unit", ctx);
                case "call":
                  return tx_node([astBuilder.unit()], root.arg_list[0], root.fn.t, "unit", ctx);
                case "send":
                  return tx_node([astBuilder.unit()], root.arg_list[0], root.fn.t, "unit", ctx);
              }
          }
        }
        return ctx.next_gen(root, ctx);
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.address_calls_converter = function(root, ctx) {
    return walk(root, ctx = obj_merge({
      walk: walk,
      next_gen: default_walk
    }, ctx));
  };

}).call(window.require_register("./transforms/address_calls_converter"));
