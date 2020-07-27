(function() {
  var Type, ast, default_walk;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  Type = window.Type;

  (function(_this) {
    return (function() {
      var walk;
      walk = function(root, ctx) {
        var decl, idx, ret, type, v, value, _i, _j, _len, _len1, _ref, _ref1, _ref2;
        walk = ctx.walk;
        switch (root.constructor.name) {
          case "Scope":
            if (root.original_node_type === "SourceUnit") {
              ctx.enums_map = new Map;
              ctx.new_declarations = [];
              root = ctx.next_gen(root, ctx);
              root.list = ctx.new_declarations.concat(root.list);
              return root;
            } else {
              return ctx.next_gen(root, ctx);
            }
            break;
          case "Enum_decl":
            ctx.enums_map.set(root.name, true);
            _ref = root.value_list;
            for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
              value = _ref[idx];
              decl = new ast.Var_decl;
              decl.name = "" + root.name + "_" + value.name;
              decl.type = new Type("uint");
              decl.assign_value = new ast.Const;
              decl.assign_value.type = new Type("uint");
              decl.assign_value.val = idx;
              decl.is_enum_decl = true;
              ctx.new_declarations.push(decl);
            }
            ret = new ast.Comment;
            ret.text = "enum " + root.name + " converted into list of nats";
            return ret;
          case "Var_decl":
            if (root.type) {
              if (root.type.main === "map") {
                _ref2 = (_ref1 = root.type) != null ? _ref1.nest_list : void 0;
                for (idx = _j = 0, _len1 = _ref2.length; _j < _len1; idx = ++_j) {
                  type = _ref2[idx];
                  if (ctx.enums_map.has(type.main)) {
                    root.type.nest_list[idx] = new Type("uint");
                  }
                }
              } else {
                if (ctx.enums_map.has(root.type.main)) {
                  root.type = new Type("uint");
                }
              }
            }
            return ctx.next_gen(root, ctx);
          case "Field_access":
            if (root.t.constructor.name === "Var") {
              if (ctx.enums_map.has(root.t.name)) {
                v = new ast.Var;
                v.name = "" + root.t.name + "_" + root.name;
                v.type = new Type("nat");
                return v;
              }
            }
            return ctx.next_gen(root, ctx);
          default:
            return ctx.next_gen(root, ctx);
        }
      };
      return _this.replace_enums_by_nat = function(root, ctx) {
        return walk(root, {
          walk: walk,
          next_gen: default_walk
        });
      };
    });
  })(this)();

}).call(window.require_register("./transforms/replace_enums_by_nat"));
