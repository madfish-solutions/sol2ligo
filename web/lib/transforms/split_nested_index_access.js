(function() {
  var Type, ast, default_walk;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  Type = window.Type;

  (function(_this) {
    return (function() {
      var walk;
      walk = function(root, ctx) {
        var current_scope_sink, idx, is_nested_index_access, res, statements, tmp, v, _i, _len, _ref;
        walk = ctx.walk;
        switch (root.constructor.name) {
          case "Scope":
            statements = [];
            _ref = root.list;
            for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
              v = _ref[idx];
              ctx.scope_sink.unshift({
                statements_to_prepend: [],
                temp_index: 0
              });
              res = walk(v, ctx);
              statements.append(ctx.scope_sink[0].statements_to_prepend);
              ctx.scope_sink.shift();
              statements.push(res);
            }
            root.list = statements;
            return root;
          case "Bin_op":
            root.a = walk(root.a, ctx);
            is_nested_index_access = root.op === "INDEX_ACCESS" && root.a.constructor.name === "Bin_op" && root.a.op === "INDEX_ACCESS";
            if (is_nested_index_access) {
              current_scope_sink = ctx.scope_sink[0];
              tmp = new ast.Var_decl;
              tmp.name = "temp_idx_access" + current_scope_sink.temp_index;
              tmp.type = root.a.type;
              tmp.assign_value = root.a;
              current_scope_sink.statements_to_prepend.push(tmp);
              root.a = new ast.Var;
              root.a.name = tmp.name;
              current_scope_sink.temp_index += 1;
            }
            root.b = walk(root.b, ctx);
            return root;
          default:
            return ctx.next_gen(root, ctx);
        }
      };
      return _this.split_nested_index_access = function(root, ctx) {
        return walk(root, {
          walk: walk,
          next_gen: default_walk,
          scope_sink: []
        });
      };
    });
  })(this)();

}).call(window.require_register("./transforms/split_nested_index_access"));
