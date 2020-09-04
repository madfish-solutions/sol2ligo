(function() {
  var Type, ast, default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  Type = window.Type;

  walk = function(root, ctx) {
    var old_scope, _ref, _ref1, _ref2;
    switch (root.constructor.name) {
      case "Type_cast":
        if (root.target_type.main === "address" && (((_ref = root.t) != null ? _ref.val : void 0) === "0" || ((_ref1 = root.t) != null ? _ref1.val : void 0) === "0x0")) {
          ctx.need_burn_address = true;
        }
        break;
      case "Class_decl":
        ctx.scope = "class";
        break;
      case "Fn_decl_multiret":
        old_scope = ctx.scope;
        ctx.scope = "fn";
        root = ctx.next_gen(root, ctx);
        ctx.scope = old_scope;
        return root;
      case "Var_decl":
        if (((_ref2 = root.type) != null ? _ref2.main : void 0) === "address" && !root.assign_value && ctx.scope === "fn") {
          ctx.need_burn_address = true;
        }
    }
    return ctx.next_gen(root, ctx);
  };

  this.add_burn_address = function(root) {
    var ctx, decl;
    ctx = {
      walk: walk,
      next_gen: default_walk,
      need_burn_address: false,
      scope: ""
    };
    walk(root, ctx);
    if (ctx.need_burn_address) {
      decl = new ast.Var_decl;
      decl.type = new Type("address");
      decl.name = "burn_address";
      root.list.unshift(decl);
    }
    return root;
  };

}).call(window.require_register("./transforms/add_burn_address"));
