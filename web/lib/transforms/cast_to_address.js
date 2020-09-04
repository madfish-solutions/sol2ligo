(function() {
  var Type, ast, astBuilder, config, default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  astBuilder = require("../ast_builder");

  walk = function(root, ctx) {
    var arg, idx, _i, _len, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
    switch (root.constructor.name) {
      case "Var_decl":
        if (((_ref = root.type) != null ? _ref.main : void 0) === "address") {
          if ((_ref1 = root.assign_value) != null ? _ref1.type : void 0) {
            if (root.assign_value.type.main !== "address") {
              root.assign_value = astBuilder.cast_to_address(root.assign_value);
            }
          }
        }
        return ctx.next_gen(root, ctx);
      case "Bin_op":
        if (root.op !== "INDEX_ACCESS") {
          if (((_ref2 = root.a.type) != null ? _ref2.main : void 0) === "address" && ((_ref3 = root.b.type) != null ? _ref3.main : void 0) !== "address") {
            root.b = astBuilder.cast_to_address(root.b);
          } else if (((_ref4 = root.a.type) != null ? _ref4.main : void 0) !== "address" && ((_ref5 = root.b.type) != null ? _ref5.main : void 0) === "address") {
            root.a = astBuilder.cast_to_address(root.a);
          }
        }
        return ctx.next_gen(root, ctx);
      case "Fn_call":
        _ref6 = root.arg_list;
        for (idx = _i = 0, _len = _ref6.length; _i < _len; idx = ++_i) {
          arg = _ref6[idx];
          if (((_ref7 = root.fn.type) != null ? (_ref8 = _ref7.nest_list[0]) != null ? (_ref9 = _ref8.nest_list[idx]) != null ? _ref9.main : void 0 : void 0 : void 0) === "address") {
            root.arg_list[idx] = astBuilder.cast_to_address(root.arg_list[idx]);
          }
        }
        return ctx.next_gen(root, ctx);
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.cast_to_address = function(root, ctx) {
    var init_ctx;
    init_ctx = {
      walk: walk,
      next_gen: default_walk
    };
    return walk(root, obj_merge(init_ctx, ctx));
  };

}).call(window.require_register("./transforms/cast_to_address"));
