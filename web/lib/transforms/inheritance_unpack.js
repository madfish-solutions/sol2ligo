(function() {
  var Type, ast, default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  Type = window.Type;

  ast = require("../ast");

  walk = function(root, ctx) {
    var add_fn_decl, class_decl, class_set, fn_call, fn_decl_set, found_constructor, i, inheritance_apply_list, inheritance_list, is_constructor_name, look_list, need_constuctor, need_lookup_list, new_name, old, parent, pick_name, v, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n, _o, _ref, _ref1, _ref2, _ref3;
    switch (root.constructor.name) {
      case "Fn_call":
        if (root.fn.constructor.name === "Field_access") {
          if (root.fn.t.constructor.name === "Var") {
            if (root.fn.t.name === "super") {
              if (new_name = ctx.fn_dedupe_translate_map.get(root.fn.name)) {
                root.fn.name = new_name;
              }
            }
          }
        }
        return root;
      case "Class_decl":
        ctx.fn_dedupe_translate_map = new Map();
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
        fn_decl_set = new Set();
        pick_name = function(start_name) {
          var try_name, _j;
          for (i = _j = 1; 1 <= Infinity ? _j < Infinity : _j > Infinity; i = 1 <= Infinity ? ++_j : --_j) {
            try_name = "" + start_name + "_" + i;
            if (!fn_decl_set.has(try_name)) {
              return try_name;
            }
          }
          throw new Error("unreachable");
        };
        add_fn_decl = function(v) {
          if (fn_decl_set.has(v.name)) {
            if (ctx.fn_dedupe_translate_map.has(v.name)) {
              perr("WARNING (AST transform). Only 1 level of shadowing is allowed. Translated code will be not functional");
            } else {
              new_name = pick_name(v.name);
              ctx.fn_dedupe_translate_map.set(v.name, new_name);
              v.visibility = "internal";
              v.name = new_name;
            }
          } else {
            fn_decl_set.add(v.name);
          }
        };
        _ref1 = root.scope.list;
        for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
          v = _ref1[_j];
          if (v.constructor.name !== "Fn_decl_multiret") {
            continue;
          }
          add_fn_decl(v);
        }
        class_set = new Set;
        for (_k = 0, _len1 = inheritance_apply_list.length; _k < _len1; _k++) {
          parent = inheritance_apply_list[_k];
          if (!ctx.class_map.hasOwnProperty(parent.name)) {
            throw new Error("can't find parent class " + parent.name);
          }
          class_decl = ctx.class_map[parent.name];
          if (class_set.has(parent.name)) {
            continue;
          }
          class_set.add(parent.name);
          if (class_decl.is_interface) {
            continue;
          }
          look_list = class_decl.scope.list;
          need_constuctor = null;
          for (_l = 0, _len2 = look_list.length; _l < _len2; _l++) {
            v = look_list[_l];
            if (v.constructor.name !== "Fn_decl_multiret") {
              continue;
            }
            v = v.clone();
            if (is_constructor_name(v.name)) {
              v.name = "" + parent.name + "_constructor";
              v.visibility = "internal";
              need_constuctor = v;
            }
            add_fn_decl(v);
            root.scope.list.unshift(v);
            _ref2 = root.scope.list;
            for (_m = 0, _len3 = _ref2.length; _m < _len3; _m++) {
              old = _ref2[_m];
              walk(old, ctx);
            }
          }
          for (_n = 0, _len4 = look_list.length; _n < _len4; _n++) {
            v = look_list[_n];
            if (v.constructor.name !== "Var_decl") {
              continue;
            }
            root.scope.list.unshift(v.clone());
          }
          if (!need_constuctor) {
            continue;
          }
          found_constructor = null;
          _ref3 = root.scope.list;
          for (_o = 0, _len5 = _ref3.length; _o < _len5; _o++) {
            v = _ref3[_o];
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
            root.scope.list.push(found_constructor = new ast.Fn_decl_multiret);
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
