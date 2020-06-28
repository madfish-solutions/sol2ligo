(function() {
  var default_walk;

  default_walk = require("./default_walk").default_walk;

  (function(_this) {
    return (function() {
      var walk;
      walk = function(root, ctx) {
        var mod, _i, _len, _ref;
        walk = ctx.walk;
        switch (root.constructor.name) {
          case "Fn_decl_multiret":
            _ref = root.modifier_list;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              mod = _ref[_i];
              walk(mod, ctx);
            }
            return ctx.next_gen(root, ctx);
          case "Fn_call":
            switch (root.fn.constructor.name) {
              case "Var":
                ctx.fn_map[root.fn.name] = true;
                break;
              case "Field_access":
                if (root.fn.t.constructor.name === "Var") {
                  if (root.fn.t.name === "this") {
                    ctx.fn_map[root.fn.name] = true;
                  }
                }
            }
            return ctx.next_gen(root, ctx);
          default:
            return ctx.next_gen(root, ctx);
        }
      };
      return _this.collect_fn_call = function(root) {
        var fn_map;
        fn_map = {};
        walk(root, {
          walk: walk,
          next_gen: default_walk,
          fn_map: fn_map
        });
        return fn_map;
      };
    });
  })(this)();

}).call(window.require_register("./transforms/collect_fn_call"));
