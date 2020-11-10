(function() {
  var Type, ast, default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  Type = window.Type;

  walk = function(root, ctx) {
    if (root.constructor.name === "Bin_op" && root.op === "POW") {
      ctx.need_pow = true;
    }
    return ctx.next_gen(root, ctx);
  };

  this.add_pow = function(root) {
    var ctx, decl;
    ctx = {
      walk: walk,
      next_gen: default_walk,
      need_pow: false
    };
    walk(root, ctx);
    if (ctx.need_pow) {
      decl = new ast.Fn_decl_multiret;
      decl.name = "pow";
      root.list.unshift(decl);
    }
    return root;
  };

}).call(window.require_register("./transforms/add_pow"));
