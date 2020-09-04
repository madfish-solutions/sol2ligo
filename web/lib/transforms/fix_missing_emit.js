(function() {
  var ast, default_walk;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  (function(_this) {
    return (function() {
      var walk;
      walk = function(root, ctx) {
        var args, ret;
        walk = ctx.walk;
        switch (root.constructor.name) {
          case "Event_decl":
            ctx.emit_decl_map[root.name] = true;
            return root;
          case "Fn_call":
            if (root.fn.constructor.name === "Var") {
              if (ctx.emit_decl_map.hasOwnProperty(root.fn.name)) {
                perr("WARNING (AST transform). EmitStatement is not supported. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#solidity-events");
                ret = new ast.Comment;
                args = root.arg_list.map(function(arg) {
                  return arg.name;
                });
                ret.text = "EmitStatement " + root.fn.name + "(" + (args.join(", ")) + ")";
                return ret;
              }
            }
            return ctx.next_gen(root, ctx);
          default:
            return ctx.next_gen(root, ctx);
        }
      };
      return _this.fix_missing_emit = function(root) {
        return walk(root, {
          walk: walk,
          next_gen: default_walk,
          emit_decl_map: {}
        });
      };
    });
  })(this)();

}).call(window.require_register("./transforms/fix_missing_emit"));
