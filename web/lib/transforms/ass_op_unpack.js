(function() {
  var ast, default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  walk = function(root, ctx) {
    var ext, reg_ret;
    walk = ctx.walk;
    switch (root.constructor.name) {
      case "Bin_op":
        if (reg_ret = /^ASS_(.*)/.exec(root.op)) {
          ext = new ast.Bin_op;
          ext.op = "ASSIGN";
          ext.a = root.a.clone();
          ext.b = root;
          root.op = reg_ret[1];
          return ext;
        } else {
          root.a = walk(root.a, ctx);
          root.b = walk(root.b, ctx);
          return root;
        }
        break;
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.ass_op_unpack = function(root) {
    return walk(root, {
      walk: walk,
      next_gen: default_walk
    });
  };

}).call(window.require_register("./transforms/ass_op_unpack"));
