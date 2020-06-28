(function() {
  var Type, ast, config, default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  walk = function(root, ctx) {
    var decl, storage;
    walk = ctx.walk;
    switch (root.constructor.name) {
      case "Fn_call":
        decl = ctx.func_decls[root.fn.name];
        if (!decl) {
          perr("can't find declaration for " + root.fn.name);
        } else {
          if (decl.arg_name_list[0] === config.contract_storage) {
            root.arg_list.unshift(storage = new ast.Var);
            storage.name = "self";
            storage.type = new Type(config.storage);
            storage.name_translate = false;
          }
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
