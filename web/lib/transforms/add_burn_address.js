(function() {
  var Type, ast, default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  Type = window.Type;

  walk = function(root, ctx) {
    var old_scope, v, _i, _len, _ref, _ref1, _ref2;
    switch (root.constructor.name) {
      case "Type_cast":
        if (root.target_type.main === "address" && root.t) {
          if (+root.t.val === 0) {
            ctx.need_burn_address = true;
          } else {
            root.t.val = "PLEASE_REPLACE_ETH_ADDRESS_" + root.t.val + "_WITH_A_TEZOS_ADDRESS";
            ctx.need_prevent_deploy = true;
          }
        }
        break;
      case "Class_decl":
        ctx.scope = "class";
        if (root.is_struct) {
          _ref = root.scope.list;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            v = _ref[_i];
            if (v.constructor.name === "Var_decl") {
              if (((_ref1 = v.type) != null ? _ref1.main : void 0) === "address") {
                ctx.need_burn_address = true;
              }
            }
          }
        }
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
      need_prevent_deploy: false,
      scope: ""
    };
    walk(root, ctx);
    if (ctx.need_burn_address) {
      decl = new ast.Var_decl;
      decl.type = new Type("address");
      decl.name = "burn_address";
      root.list.unshift(decl);
    }
    if (ctx.need_prevent_deploy) {
      root.need_prevent_deploy = true;
    }
    return root;
  };

}).call(window.require_register("./transforms/add_burn_address"));
