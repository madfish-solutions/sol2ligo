(function() {
  var ast, config, default_walk, translate_var_name;

  default_walk = require("./default_walk").default_walk;

  translate_var_name = require("../translate_var_name").translate_var_name;

  config = require("../config");

  ast = require("../ast");

  (function(_this) {
    return (function() {
      var walk;
      walk = function(root, ctx) {
        var arg, idx, library_name, name, prefix, value, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _var;
        switch (root.constructor.name) {
          case "Class_decl":
            ctx.current_class = root;
            if (root.is_library) {
              ctx.libraries[root.name] = true;
            }
            return default_walk(root, ctx);
          case "Var":
            root.name = translate_var_name(root.name);
            return root;
          case "Var_decl":
            if (root.assign_value) {
              root.assign_value = walk(root.assign_value, ctx);
            }
            root.name = translate_var_name(root.name);
            return root;
          case "Field_access":
            if (((_ref = root.t.type) != null ? _ref.main : void 0) === "enum") {
              name = translate_var_name(root.name, ctx);
              if (((_ref1 = root.t) != null ? _ref1.name : void 0) !== config.router_enum) {
                prefix = "";
                if (ctx.current_class.name) {
                  prefix = "" + ctx.current_class.name + "_";
                }
                root.name = "" + (translate_var_name(prefix + root.t.name)) + "_" + root.name;
              } else {
                name = "" + (ctx.current_class.name.toUpperCase()) + "_" + name;
                root.name = "" + name + "(unit)";
              }
            }
            root.name = translate_var_name(root.name);
            return default_walk(root, ctx);
          case "Var_decl_multi":
            if (root.assign_value) {
              root.assign_value = walk(root.assign_value, ctx);
            }
            _ref2 = root.list;
            for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
              _var = _ref2[_i];
              _var.name = translate_var_name(_var.name);
            }
            return root;
          case "Fn_decl_multiret":
            name = root.name;
            if ((_ref3 = ctx.current_class) != null ? _ref3.is_library : void 0) {
              name = "" + ctx.current_class.name + "_" + name;
            }
            root.name = translate_var_name(name);
            root.scope = walk(root.scope, ctx);
            _ref4 = root.arg_name_list;
            for (idx = _j = 0, _len1 = _ref4.length; _j < _len1; idx = ++_j) {
              name = _ref4[idx];
              root.arg_name_list[idx] = translate_var_name(name);
            }
            return root;
          case "Fn_call":
            name = root.fn.name;
            if (root.fn.constructor.name === "Var") {
              if (((_ref5 = ctx.current_class) != null ? _ref5.is_library : void 0) && ctx.current_class._prepared_field2type[name]) {
                root.fn.name = "" + ctx.current_class.name + "_" + name;
              }
            } else if (root.fn.constructor.name === "Field_access") {
              library_name = root.fn.t.name;
              if (ctx.libraries.hasOwnProperty(library_name)) {
                name = "" + library_name + "_" + name;
                root.fn = new ast.Var;
                root.fn.name = name;
              }
            }
            return default_walk(root, ctx);
          case "Enum_decl":
            root.name = translate_var_name(root.name);
            _ref6 = root.value_list;
            for (idx = _k = 0, _len2 = _ref6.length; _k < _len2; idx = ++_k) {
              value = _ref6[idx];
              root.value_list[idx].name = "" + value.name;
            }
            return root;
          case "Event_decl":
            _ref7 = root.arg_list;
            for (idx = _l = 0, _len3 = _ref7.length; _l < _len3; idx = ++_l) {
              arg = _ref7[idx];
              root.arg_list[idx]._name = translate_var_name(arg._name);
            }
            return root;
          default:
            return default_walk(root, ctx);
        }
      };
      return _this.var_translate = function(root, ctx) {
        return walk(root, {
          walk: walk,
          next_gen: default_walk,
          libraries: {}
        });
      };
    });
  })(this)();

}).call(window.require_register("./transforms/var_translate"));
