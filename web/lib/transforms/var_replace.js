(function() {
  var default_walk;

  default_walk = require("./default_walk").default_walk;

  (function(_this) {
    return (function() {
      var walk;
      walk = function(root, ctx) {
        walk = ctx.walk;
        switch (root.constructor.name) {
          case "Var":
            if (root.name !== ctx.var_name) {
              return root;
            }
            return ctx.target_ast.clone();
          default:
            return ctx.next_gen(root, ctx);
        }
      };
      return _this.var_replace = function(root, var_name, target_ast) {
        return walk(root, {
          walk: walk,
          next_gen: default_walk,
          var_name: var_name,
          target_ast: target_ast
        });
      };
    });
  })(this)();

}).call(window.require_register("./transforms/var_replace"));
