(function() {
  var Type, ast, astBuilder, collect_local_decls, config, default_walk, foreign_calls_to_external, tx_node;

  default_walk = require("./default_walk").default_walk;

  Type = window.Type;

  ast = require("../ast");

  astBuilder = require("../ast_builder");

  config = require("../config");

  tx_node = function(arg_list, cost, address_expr, name, ctx) {
    var entrypoint, tez_cost, tx;
    entrypoint = astBuilder.foreign_entrypoint(address_expr, name);
    tez_cost = astBuilder.cast_to_tez(cost);
    tx = astBuilder.transaction(arg_list, entrypoint, tez_cost);
    return tx;
  };

  collect_local_decls = function(root, ctx) {
    switch (root.constructor.name) {
      case "Class_decl":
        ctx.is_cur_contract_main = root.is_last;
        ctx.foreign_contracts.add(root.name);
        return ctx.next_gen(root, ctx);
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  foreign_calls_to_external = function(root, ctx) {
    var arg, contract_type, entrypoint, is_foreign_call, name, tx, _i, _len, _ref, _ref1, _ref2;
    switch (root.constructor.name) {
      case "Fn_call":
        is_foreign_call = false;
        if ((_ref = root.fn.t) != null ? (_ref1 = _ref.type) != null ? _ref1.main : void 0 : void 0) {
          is_foreign_call = ctx.foreign_contracts.has(root.fn.t.type.main);
        }
        if (is_foreign_call) {
          name = root.fn.name;
          contract_type = new Type("contract");
          _ref2 = root.arg_list;
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            arg = _ref2[_i];
            contract_type.nest_list.push(arg.type);
          }
          name = astBuilder.string_val("%" + name);
          entrypoint = astBuilder.get_entrypoint(name, root.fn.t, contract_type);
          tx = astBuilder.transaction(root.arg_list, entrypoint);
          return tx;
        } else {
          return ctx.next_gen(root, ctx);
        }
        break;
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.make_calls_external = function(root, ctx) {
    var full_ctx;
    full_ctx = {
      walk: collect_local_decls,
      next_gen: default_walk,
      is_cur_contract_main: false,
      foreign_contracts: new Set
    };
    collect_local_decls(root, obj_merge(ctx, full_ctx));
    return foreign_calls_to_external(root, obj_merge(full_ctx, {
      walk: foreign_calls_to_external,
      next_gen: default_walk
    }));
  };

}).call(window.require_register("./transforms/make_calls_external"));
