(function() {
  var default_walk;

  default_walk = require("./default_walk").default_walk;

  (function(_this) {
    return (function() {
      var walk;
      walk = function(root, ctx) {
        walk = ctx.walk;
        switch (root.constructor.name) {
          case "Fn_decl_multiret":
            ctx.fn_map[root.name] = root;
            return ctx.next_gen(root, ctx);
          default:
            return ctx.next_gen(root, ctx);
        }
      };
      return _this.collect_fn_decl = function(root) {
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

}).call(window.require_register("./transforms/collect_fn_decl"));
