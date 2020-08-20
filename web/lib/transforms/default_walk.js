(function() {
  this.default_walk = function(root, ctx) {
    var idx, v, walk, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _len6, _m, _n, _o, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
    walk = ctx.walk;
    switch (root.constructor.name) {
      case "Scope":
        _ref = root.list;
        for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
          v = _ref[idx];
          root.list[idx] = walk(v, ctx);
        }
        return root;
      case "Var":
      case "Const":
        return root;
      case "Un_op":
        root.a = walk(root.a, ctx);
        return root;
      case "Bin_op":
        root.a = walk(root.a, ctx);
        root.b = walk(root.b, ctx);
        return root;
      case "Field_access":
        root.t = walk(root.t, ctx);
        return root;
      case "Fn_call":
        _ref1 = root.arg_list;
        for (idx = _j = 0, _len1 = _ref1.length; _j < _len1; idx = ++_j) {
          v = _ref1[idx];
          root.arg_list[idx] = walk(v, ctx);
        }
        root.fn = walk(root.fn, ctx);
        return root;
      case "Struct_init":
        root.fn = root.fn;
        if (ctx.class_map && root.arg_names.length === 0) {
          _ref2 = ctx.class_map[root.fn.name].scope.list;
          for (idx = _k = 0, _len2 = _ref2.length; _k < _len2; idx = ++_k) {
            v = _ref2[idx];
            root.arg_names.push(v.name);
          }
        }
        _ref3 = root.val_list;
        for (idx = _l = 0, _len3 = _ref3.length; _l < _len3; idx = ++_l) {
          v = _ref3[idx];
          root.val_list[idx] = walk(v, ctx);
        }
        return root;
      case "New":
        _ref4 = root.arg_list;
        for (idx = _m = 0, _len4 = _ref4.length; _m < _len4; idx = ++_m) {
          v = _ref4[idx];
          root.arg_list[idx] = walk(v, ctx);
        }
        return root;
      case "Comment":
        return root;
      case "Continue":
      case "Break":
        return root;
      case "Var_decl":
        if (root.assign_value) {
          root.assign_value = walk(root.assign_value, ctx);
        }
        return root;
      case "Var_decl_multi":
        if (root.assign_value) {
          root.assign_value = walk(root.assign_value, ctx);
        }
        return root;
      case "Throw":
        if (root.t) {
          walk(root.t, ctx);
        }
        return root;
      case "Type_cast":
        walk(root.t, ctx);
        return root;
      case "Enum_decl":
      case "PM_switch":
        return root;
      case "Ret_multi":
        _ref5 = root.t_list;
        for (idx = _n = 0, _len5 = _ref5.length; _n < _len5; idx = ++_n) {
          v = _ref5[idx];
          root.t_list[idx] = walk(v, ctx);
        }
        return root;
      case "If":
      case "Ternary":
        root.cond = walk(root.cond, ctx);
        root.t = walk(root.t, ctx);
        root.f = walk(root.f, ctx);
        return root;
      case "While":
        root.cond = walk(root.cond, ctx);
        root.scope = walk(root.scope, ctx);
        return root;
      case "For3":
        if (root.init) {
          root.init = walk(root.init, ctx);
        }
        if (root.cond) {
          root.cond = walk(root.cond, ctx);
        }
        if (root.iter) {
          root.iter = walk(root.iter, ctx);
        }
        root.scope = walk(root.scope, ctx);
        return root;
      case "Class_decl":
        root.scope = walk(root.scope, ctx);
        return root;
      case "Fn_decl_multiret":
        root.scope = walk(root.scope, ctx);
        return root;
      case "Tuple":
      case "Array_init":
        _ref6 = root.list;
        for (idx = _o = 0, _len6 = _ref6.length; _o < _len6; idx = ++_o) {
          v = _ref6[idx];
          root.list[idx] = walk(v, ctx);
        }
        return root;
      case "Event_decl":
        return root;
      case "Include":
        return root;
      default:

        /* !pragma coverage-skip-block */
        perr(root);
        throw new Error("unknown root.constructor.name " + root.constructor.name);
    }
  };

}).call(window.require_register("./transforms/default_walk"));
