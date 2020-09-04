(function() {
  var Type, ast, astBuilder, config, default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  astBuilder = require("../ast_builder");

  walk = function(root, ctx) {
    switch (root.constructor.name) {
      case "Class_decl":
        if (root.is_contract || root.is_interface) {
          ctx.known_contracts.add(root.name);
        }
        return ctx.next_gen(root, ctx);
      case "Var_decl":
        if (ctx.known_contracts.has(root.type.main)) {
          root.type = new Type("address");
        }
        return ctx.next_gen(root, ctx);
      case "Fn_call":
        if (ctx.known_contracts.has(root.fn.name)) {
          return astBuilder.cast_to_address(root.arg_list[0]);
        } else {
          return ctx.next_gen(root, ctx);
        }
        break;
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.contract_object_to_address = function(root, ctx) {
    var init_ctx;
    init_ctx = {
      walk: walk,
      next_gen: default_walk,
      known_contracts: new Set
    };
    return walk(root, obj_merge(init_ctx, ctx));
  };

}).call(window.require_register("./transforms/contract_object_to_address"));
