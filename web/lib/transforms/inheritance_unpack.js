(function() {
  var ast, default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  walk = function(root, ctx) {
    var class_decl, fn_call, found_constructor, i, inheritance_apply_list, inheritance_list, is_constructor_name, look_list, need_constuctor, need_lookup_list, parent, v, _i, _j, _k, _l, _len, _len1, _len2, _len3, _m, _ref, _ref1;
    walk = ctx.walk;
    switch (root.constructor.name) {
      case "Class_decl":
        is_constructor_name = function(name) {
          return name === "constructor" || name === root.name;
        };
        root = ctx.next_gen(root, ctx);
        ctx.class_map[root.name] = root;
        if (!root.inheritance_list.length) {
          return root;
        }
        inheritance_apply_list = [];
        inheritance_list = root.inheritance_list;
        while (inheritance_list.length) {
          need_lookup_list = [];
          for (i = _i = _ref = inheritance_list.length - 1; _i >= 0; i = _i += -1) {
            v = inheritance_list[i];
            if (!ctx.class_map.hasOwnProperty(v.name)) {
              throw new Error("can't find parent class " + v.name);
            }
            class_decl = ctx.class_map[v.name];
            class_decl.need_skip = true;
            inheritance_apply_list.push(v);
            need_lookup_list.append(class_decl.inheritance_list);
          }
          inheritance_list = need_lookup_list;
        }
        root = root.clone();
        for (_j = 0, _len = inheritance_apply_list.length; _j < _len; _j++) {
          parent = inheritance_apply_list[_j];
          if (!ctx.class_map.hasOwnProperty(parent.name)) {
            throw new Error("can't find parent class " + parent.name);
          }
          class_decl = ctx.class_map[parent.name];
          if (class_decl.is_interface) {
            continue;
          }
          look_list = class_decl.scope.list;
          need_constuctor = null;
          for (_k = 0, _len1 = look_list.length; _k < _len1; _k++) {
            v = look_list[_k];
            if (v.constructor.name !== "Fn_decl_multiret") {
              continue;
            }
            v = v.clone();
            if (is_constructor_name(v.name)) {
              v.name = "" + parent.name + "_constructor";
              v.visibility = "internal";
              need_constuctor = v;
            }
            root.scope.list.unshift(v);
          }
          for (_l = 0, _len2 = look_list.length; _l < _len2; _l++) {
            v = look_list[_l];
            if (v.constructor.name !== "Var_decl") {
              continue;
            }
            root.scope.list.unshift(v.clone());
          }
          if (!need_constuctor) {
            continue;
          }
          found_constructor = null;
          _ref1 = root.scope.list;
          for (_m = 0, _len3 = _ref1.length; _m < _len3; _m++) {
            v = _ref1[_m];
            if (v.constructor.name !== "Fn_decl_multiret") {
              continue;
            }
            if (!is_constructor_name(v.name)) {
              continue;
            }
            found_constructor = v;
            break;
          }
          if (!found_constructor) {
            root.scope.list.unshift(found_constructor = new ast.Fn_decl_multiret);
            found_constructor.name = "constructor";
            found_constructor.type_i = new Type("function");
            found_constructor.type_o = new Type("function");
          }
          found_constructor.scope.list.unshift(fn_call = new ast.Fn_call);
          fn_call.fn = new ast.Var;
          fn_call.fn.name = need_constuctor.name;
        }
        return root;
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.inheritance_unpack = function(root) {
    return walk(root, {
      walk: walk,
      next_gen: default_walk,
      class_map: {}
    });
  };

}).call(window.require_register("./transforms/inheritance_unpack"));
