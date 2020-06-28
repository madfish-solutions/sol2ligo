(function() {
  var Type, ast, astBuilder, default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  astBuilder = require("../ast_builder");

  Type = window.Type;

  walk = function(root, ctx) {
    var declaration, i, list_init, op_index, v, _i, _ref;
    switch (root.constructor.name) {
      case "Fn_decl_multiret":
        ctx.current_fn_opcount = 0;
        return ctx.next_gen(root, ctx);
      case "Fn_call":
        if (root.fn.name === "transaction") {
          op_index = ctx.current_fn_opcount;
          declaration = astBuilder.declaration("op" + op_index, root, new Type("operation"));
          ctx.current_fn_opcount += 1;
          return declaration;
        }
        return ctx.next_gen(root, ctx);
      case "Ret_multi":
        if (ctx.current_fn_opcount > 0) {
          list_init = new ast.Array_init;
          list_init.type = new Type("built_in_op_list");
          for (i = _i = 0, _ref = ctx.current_fn_opcount - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
            list_init.list.push(v = new ast.Var);
            v.name = "op" + i;
          }
          root.t_list[0] = list_init;
          return root;
        } else {
          return ctx.next_gen(root, ctx);
        }
        break;
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.return_op_list_count = function(root) {
    return walk(root, {
      walk: walk,
      next_gen: default_walk
    });
  };

}).call(window.require_register("./transforms/return_op_list_count"));
