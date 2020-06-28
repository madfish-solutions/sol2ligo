(function() {
  var ast, default_walk, placeholder_replace;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  placeholder_replace = require("./placeholder_replace").placeholder_replace;

  (function(_this) {
    return (function() {
      var fn_apply_modifier, walk;
      fn_apply_modifier = function(fn, mod, ctx) {

        /*
        Possible intersections
          1. Var_decl
          2. Var_decl in arg_list
          3. Multiple placeholders = multiple cloned Var_decl
         */
        var arg, idx, mod_decl, prepend_list, ret, var_decl, _i, _len, _ref;
        if (mod.fn.constructor.name !== "Var") {
          throw new Error("unimplemented");
        }
        if (!ctx.modifier_map.hasOwnProperty(mod.fn.name)) {
          throw new Error("unknown modifier " + mod.fn.name);
        }
        mod_decl = ctx.modifier_map[mod.fn.name];
        ret = mod_decl.scope.clone();
        prepend_list = [];
        _ref = mod.arg_list;
        for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
          arg = _ref[idx];
          if (arg.name === mod_decl.arg_name_list[idx]) {
            continue;
          }
          prepend_list.push(var_decl = new ast.Var_decl);
          var_decl.name = mod_decl.arg_name_list[idx];
          var_decl.assign_value = arg.clone();
          var_decl.type = mod_decl.type_i.nest_list[idx];
        }
        ret = placeholder_replace(ret, fn);
        ret.list = arr_merge(prepend_list, ret.list);
        return ret;
      };
      walk = function(root, ctx) {
        var idx, inner, mod, ret, _i, _len, _ref;
        walk = ctx.walk;
        switch (root.constructor.name) {
          case "Fn_decl_multiret":
            if (root.is_modifier) {
              ctx.modifier_map[root.name] = root;
              ret = new ast.Comment;
              ret.text = "modifier " + root.name + " inlined";
              return ret;
            } else {
              if (root.is_constructor) {
                ctx.modifier_map[root.contract_name] = root;
              }
              if (root.modifier_list.length === 0) {
                return root;
              }
              inner = root.scope.clone();
              _ref = root.modifier_list;
              for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
                mod = _ref[idx];
                inner.need_nest = false;
                inner = fn_apply_modifier(inner, mod, ctx);
              }
              inner.need_nest = true;
              ret = root.clone();
              ret.modifier_list.clear();
              ret.scope = inner;
              return ret;
            }
            break;
          default:
            return ctx.next_gen(root, ctx);
        }
      };
      return _this.modifier_unpack = function(root) {
        return walk(root, {
          walk: walk,
          next_gen: default_walk,
          modifier_map: {}
        });
      };
    });
  })(this)();

}).call(window.require_register("./transforms/modifier_unpack"));
