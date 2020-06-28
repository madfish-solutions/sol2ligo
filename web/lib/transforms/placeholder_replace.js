(function() {
  var default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  walk = function(root, ctx) {
    var last, ret;
    walk = ctx.walk;
    switch (root.constructor.name) {
      case "Comment":
        if (root.text !== "COMPILER MSG PlaceholderStatement") {
          return root;
        }
        ret = ctx.target_ast.clone();
        if (!ctx.need_nest) {
          last = ret.list.last();
          if (last && last.constructor.name === "Ret_multi") {
            last = ret.list.pop();
          }
        }
        return ret;
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.placeholder_replace = function(root, target_ast) {
    return walk(root, {
      walk: walk,
      next_gen: default_walk,
      target_ast: target_ast
    });
  };

}).call(window.require_register("./transforms/placeholder_replace"));
