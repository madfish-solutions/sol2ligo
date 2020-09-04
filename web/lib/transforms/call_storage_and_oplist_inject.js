(function() {
  var Type, ast, config, default_var_map_gen, default_walk, ti_map, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  default_var_map_gen = require("../type_inference/common").default_var_map_gen;

  ti_map = default_var_map_gen();

  walk = function(root, ctx) {
    var storage;
    walk = ctx.walk;
    switch (root.constructor.name) {
      case "Fn_call":
        if (ti_map.hasOwnProperty(root.fn.name)) {
          return ctx.next_gen(root, ctx);
        }
        if (!root.fn_decl) {
          perr("WARNING (AST transform). no Fn_decl for Fn call named " + root.fn.name);
          return ctx.next_gen(root, ctx);
        }
        if (root.fn_decl.uses_storage) {
          root.arg_list.unshift(storage = new ast.Var);
          storage.name = config.contract_storage;
          storage.type = new Type(config.storage);
          storage.name_translate = false;
        }
        return ctx.next_gen(root, ctx);
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.call_storage_and_oplist_inject = function(root, ctx) {
    return walk(root, ctx = obj_merge({
      walk: walk,
      next_gen: default_walk
    }, ctx));
  };

}).call(window.require_register("./transforms/call_storage_and_oplist_inject"));
