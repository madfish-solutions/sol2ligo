(function() {
  var default_walk, module;

  default_walk = require("./default_walk").default_walk;

  module = this;

  this.walk = function(root, ctx) {
    var walk;
    walk = ctx.walk;
    switch (root.constructor.name) {
      case "Fn_call":
        if (root.fn.constructor.name === "Var") {
          if (root.fn.name === "require") {
            if (root.arg_list.length === 2) {
              root.fn.name = "require2";
            }
          }
        }
        return ctx.next_gen(root, ctx);
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.require_distinguish = function(root) {
    return module.walk(root, {
      walk: module.walk,
      next_gen: default_walk
    });
  };

}).call(window.require_register("./transforms/require_distinguish"));
