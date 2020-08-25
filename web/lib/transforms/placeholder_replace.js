(function() {
  var default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  walk = function(root, ctx) {
    var list, v, _i, _len, _ref;
    walk = ctx.walk;
    switch (root.constructor.name) {
      case "Scope":
        root = ctx.next_gen(root, ctx);
        list = [];
        _ref = root.list;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          v = _ref[_i];
          if (v.constructor.name === "Scope") {
            list.append(v.list);
          } else {
            list.push(v);
          }
        }
        root.list = list;
        return root;
      case "Comment":
        if (root.text !== "COMPILER MSG PlaceholderStatement") {
          return root;
        }
        return ctx.target_ast.clone();
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
