(function() {
  var default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  walk = function(root, ctx) {
    var _ref, _ref1;
    walk = ctx.walk;
    switch (root.constructor.name) {
      case "Class_decl":
        if (root.need_skip) {
          return root;
        }
        if (root.is_library) {
          return root;
        }
        ctx.inheritance_list = root.inheritance_list;
        return ctx.next_gen(root, ctx);
      case "Fn_decl_multiret":
        if (((_ref = root.visibility) !== "private" && _ref !== "internal") && (!ctx.contract || root.contract_name === ctx.contract || ((_ref1 = ctx.inheritance_list) != null ? _ref1[ctx.contract] : void 0))) {
          ctx.router_func_list.push(root);
        }
        return root;
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.router_collector = function(root, opt) {
    var ctx;
    walk(root, ctx = obj_merge({
      walk: walk,
      next_gen: default_walk,
      router_func_list: []
    }, opt));
    return ctx.router_func_list;
  };

}).call(window.require_register("./transforms/router_collector"));
