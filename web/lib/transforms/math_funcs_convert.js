(function() {
  var ast, default_walk;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  (function(_this) {
    return (function() {
      var walk;
      walk = function(root, ctx) {
        var add, addmod, mul, mulmod;
        walk = ctx.walk;
        switch (root.constructor.name) {
          case "Fn_call":
            if (root.fn.constructor.name === "Var") {
              switch (root.fn.name) {
                case "addmod":
                  add = new ast.Bin_op;
                  add.op = "ADD";
                  add.a = root.arg_list[0];
                  add.b = root.arg_list[1];
                  addmod = new ast.Bin_op;
                  addmod.op = "MOD";
                  addmod.b = root.arg_list[2];
                  addmod.a = add;
                  perr("WARNING (AST transform). `addmod` translation may compute incorrectly due to possible overflow. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#number-types");
                  return addmod;
                case "mulmod":
                  mul = new ast.Bin_op;
                  mul.op = "MUL";
                  mul.a = root.arg_list[0];
                  mul.b = root.arg_list[1];
                  mulmod = new ast.Bin_op;
                  mulmod.op = "MOD";
                  mulmod.b = root.arg_list[2];
                  mulmod.a = mul;
                  perr("WARNING (AST transform). `mulmod` translation may compute incorrectly due to possible overflow. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#number-types");
                  return mulmod;
              }
            }
            return root;
          default:
            return ctx.next_gen(root, ctx);
        }
      };
      return _this.math_funcs_convert = function(root, ctx) {
        return walk(root, obj_merge({
          walk: walk,
          next_gen: default_walk
        }, ctx));
      };
    });
  })(this)();

}).call(window.require_register("./transforms/math_funcs_convert"));
