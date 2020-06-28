(function() {
  var Type, ast, default_walk;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  Type = window.Type;

  (function(_this) {
    return (function() {
      var walk;
      walk = function(root, ctx) {
        var ret, while_inside;
        walk = ctx.walk;
        switch (root.constructor.name) {
          case "For3":
            ret = new ast.Scope;
            ret.need_nest = false;
            if (root.init) {
              ret.list.push(root.init);
            }
            while_inside = new ast.While;
            if (root.cond) {
              while_inside.cond = root.cond;
            } else {
              while_inside.cond = new ast.Const;
              while_inside.cond.val = "true";
              while_inside.cond.type = new Type("bool");
            }
            while_inside.scope.list.append(root.scope.list);
            if (root.iter) {
              while_inside.scope.list.push(root.iter);
            }
            ret.list.push(while_inside);
            return ret;
          default:
            return ctx.next_gen(root, ctx);
        }
      };
      return _this.for3_unpack = function(root) {
        return walk(root, {
          walk: walk,
          next_gen: default_walk
        });
      };
    });
  })(this)();

}).call(window.require_register("./transforms/for3_unpack"));
