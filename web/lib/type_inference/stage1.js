(function() {
  var Type, config, ti, type_generalize;

  Type = window.Type;

  config = require("../config");

  require("../type_safe");

  ti = require("./common");

  type_generalize = require("../type_generalize").type_generalize;

  this.walk = function(root, ctx) {
    var a, a_type, arg, class_decl, complex_type, ctx_nest, decl, expected, expected_type, f, field_map, field_type, fn_decl, i, idx, k, name, nest_list, nest_type, offset, real, ret_type, root_type, t, tuple_value, type, using, using_list, v, _i, _j, _k, _l, _len, _len1, _len10, _len11, _len12, _len13, _len14, _len15, _len16, _len17, _len2, _len3, _len4, _len5, _len6, _len7, _len8, _len9, _m, _n, _o, _p, _q, _r, _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref19, _ref2, _ref20, _ref21, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9, _s, _t, _u, _v, _w, _x, _y, _z;
    switch (root.constructor.name) {
      case "Var":
        return root.type = ti.type_spread_left(root.type, ctx.check_id(root.name), ctx);
      case "Const":
        return root.type;
      case "Bin_op":
        ctx.walk(root.a, ctx);
        ctx.walk(root.b, ctx);
        switch (root.op) {
          case "ASSIGN":
            root.a.type = ti.type_spread_left(root.a.type, root.b.type, ctx);
            root.b.type = ti.type_spread_left(root.b.type, root.a.type, ctx);
            root.type = ti.type_spread_left(root.type, root.a.type, ctx);
            root.a.type = ti.type_spread_left(root.a.type, root.type, ctx);
            root.b.type = ti.type_spread_left(root.b.type, root.type, ctx);
            break;
          case "EQ":
          case "NE":
          case "GT":
          case "GTE":
          case "LT":
          case "LTE":
            root.type = ti.type_spread_left(root.type, new Type("bool"), ctx);
            root.a.type = ti.type_spread_left(root.a.type, root.b.type, ctx);
            root.b.type = ti.type_spread_left(root.b.type, root.a.type, ctx);
            break;
          case "INDEX_ACCESS":
            switch ((_ref = root.a.type) != null ? _ref.main : void 0) {
              case "string":
                root.b.type = ti.type_spread_left(root.b.type, new Type("uint256"), ctx);
                root.type = ti.type_spread_left(root.type, new Type("string"), ctx);
                break;
              case "map":
                root.b.type = ti.type_spread_left(root.b.type, root.a.type.nest_list[0], ctx);
                root.type = ti.type_spread_left(root.type, root.a.type.nest_list[1], ctx);
                break;
              case "array":
                root.b.type = ti.type_spread_left(root.b.type, new Type("uint256"), ctx);
                root.type = ti.type_spread_left(root.type, root.a.type.nest_list[0], ctx);
                break;
              default:
                if (config.bytes_type_map.hasOwnProperty((_ref1 = root.a.type) != null ? _ref1.main : void 0)) {
                  root.b.type = ti.type_spread_left(root.b.type, new Type("uint256"), ctx);
                  root.type = ti.type_spread_left(root.type, new Type("bytes1"), ctx);
                }
            }
        }
        return root.type;
      case "Un_op":
        a = ctx.walk(root.a, ctx);
        if (root.op === "DELETE") {
          if (root.a.constructor.name === "Bin_op") {
            if (root.a.op === "INDEX_ACCESS") {
              if (((_ref2 = root.a.a.type) != null ? _ref2.main : void 0) === "array") {
                return root.type;
              }
              if (((_ref3 = root.a.a.type) != null ? _ref3.main : void 0) === "map") {
                return root.type;
              }
            }
          }
        }
        return root.type;
      case "Field_access":
        root_type = ctx.walk(root.t, ctx);
        field_map = {};
        if (root_type) {
          switch (root_type.main) {
            case "array":
              field_map = ti.array_field_map;
              break;
            case "address":
              field_map = ti.address_field_map;
              break;
            case "struct":
              field_map = root_type.field_map;
              break;
            case "enum":
              field_map = root_type.field_map;
              break;
            default:
              if (config.bytes_type_map.hasOwnProperty(root_type.main)) {
                field_map = ti.bytes_field_map;
              } else {
                class_decl = ctx.check_type(root_type.main);
                if (class_decl != null ? class_decl._prepared_field2type : void 0) {
                  field_map = class_decl._prepared_field2type;
                } else {
                  type = type_generalize(root_type.main);
                  using_list = ctx.current_class.using_map[type] || ctx.current_class.using_map["*"];
                  if (using_list) {
                    for (_i = 0, _len = using_list.length; _i < _len; _i++) {
                      using = using_list[_i];
                      class_decl = ctx.check_type(using);
                      if (!class_decl) {
                        perr("WARNING (Type inference). Bad using '" + using + "'");
                        continue;
                      }
                      if (!(fn_decl = class_decl._prepared_field2type[root.name])) {
                        continue;
                      }
                      ret_type = fn_decl.clone();
                      a_type = ret_type.nest_list[0].nest_list.shift();
                      if (!a_type.cmp(root_type)) {
                        perr("WARNING (Type inference). Bad using '" + using + "' types for self are not same " + a_type + " != " + root_type);
                      }
                      root.type = ti.type_spread_left(root.type, ret_type, ctx);
                      return root.type;
                    }
                    perr("WARNING (Type inference). Can't find " + root.name + " for Field_access");
                    return root_type;
                  } else {
                    perr("WARNING (Type inference). Can't find declaration for Field_access ." + root.name);
                    return root_type;
                  }
                }
              }
          }
        }
        if (!field_map.hasOwnProperty(root.name)) {
          perr("WARNING (Type inference). Unknown field. '" + root.name + "' at type '" + root_type + "'. Allowed fields [" + (Object.keys(field_map).join(', ')) + "]");
          return root.type;
        }
        field_type = field_map[root.name];
        if (typeof field_type === "function") {
          field_type = field_type(root.t.type);
        }
        root.type = ti.type_spread_left(root.type, field_type, ctx);
        return root.type;
      case "Fn_call":
        switch (root.fn.constructor.name) {
          case "Var":
            if (root.fn.name === "super") {
              perr("WARNING (Type inference). Skipping super() call");
              _ref4 = root.arg_list;
              for (_j = 0, _len1 = _ref4.length; _j < _len1; _j++) {
                arg = _ref4[_j];
                ctx.walk(arg, ctx);
              }
              return root.type;
            }
            break;
          case "Field_access":
            if (root.fn.t.constructor.name === "Var") {
              if (root.fn.t.name === "super") {
                perr("WARNING (Type inference). Skipping super.fn call");
                _ref5 = root.arg_list;
                for (_k = 0, _len2 = _ref5.length; _k < _len2; _k++) {
                  arg = _ref5[_k];
                  ctx.walk(arg, ctx);
                }
                return root.type;
              }
            }
        }
        root_type = ctx.walk(root.fn, ctx);
        root_type = ti.type_resolve(root_type, ctx);
        if (!root_type) {
          perr("WARNING (Type inference). Can't resolve function type for Fn_call");
          return root.type;
        }
        offset = 0;
        _ref6 = root.arg_list;
        for (i = _l = 0, _len3 = _ref6.length; _l < _len3; i = ++_l) {
          arg = _ref6[i];
          ctx.walk(arg, ctx);
          if (root_type.main !== "struct") {
            expected_type = root_type.nest_list[0].nest_list[i + offset];
            arg.type = ti.type_spread_left(arg.type, expected_type, ctx);
          }
        }
        if (root_type.main === "struct") {
          if (root.arg_list.length !== 1) {
            perr("WARNING (Type inference). contract(address) call should have 1 argument. real=" + root.arg_list.length);
            return root.type;
          }
          arg = root.arg_list[0];
          arg.type = ti.type_spread_left(arg.type, new Type("address"), ctx);
          return root.type = ti.type_spread_left(root.type, root_type, ctx);
        } else {
          return root.type = ti.type_spread_left(root.type, root_type.nest_list[1].nest_list[offset], ctx);
        }
        break;
      case "Struct_init":
        root_type = ctx.walk(root.fn, ctx);
        root_type = ti.type_resolve(root_type, ctx);
        if (!root_type) {
          perr("WARNING (Type inference). Can't resolve function type for Struct_init");
          return root.type;
        }
        _ref7 = root.val_list;
        for (i = _m = 0, _len4 = _ref7.length; _m < _len4; i = ++_m) {
          arg = _ref7[i];
          ctx.walk(arg, ctx);
        }
        return root.type;
      case "Comment":
        return null;
      case "Continue":
      case "Break":
        return root;
      case "Var_decl":
        if (root.assign_value) {
          root.assign_value.type = ti.type_spread_left(root.assign_value.type, root.type, ctx);
          ctx.walk(root.assign_value, ctx);
        }
        ctx.var_map[root.name] = root.type;
        return null;
      case "Var_decl_multi":
        if (root.assign_value) {
          root.assign_value.type = ti.type_spread_left(root.assign_value.type, root.type, ctx);
          ctx.walk(root.assign_value, ctx);
        }
        _ref8 = root.list;
        for (_n = 0, _len5 = _ref8.length; _n < _len5; _n++) {
          decl = _ref8[_n];
          ctx.var_map[decl.name] = decl.type;
        }
        return null;
      case "Throw":
        if (root.t) {
          ctx.walk(root.t, ctx);
        }
        return null;
      case "Scope":
        ctx_nest = ctx.mk_nest();
        _ref9 = root.list;
        for (_o = 0, _len6 = _ref9.length; _o < _len6; _o++) {
          v = _ref9[_o];
          if (v.constructor.name === "Class_decl") {
            ti.class_prepare(v, ctx);
          }
        }
        _ref10 = root.list;
        for (_p = 0, _len7 = _ref10.length; _p < _len7; _p++) {
          v = _ref10[_p];
          ctx.walk(v, ctx_nest);
        }
        return null;
      case "Ret_multi":
        _ref11 = root.t_list;
        for (idx = _q = 0, _len8 = _ref11.length; _q < _len8; idx = ++_q) {
          v = _ref11[idx];
          v.type = ti.type_spread_left(v.type, ctx.parent_fn.type_o.nest_list[idx], ctx);
          expected = ctx.parent_fn.type_o.nest_list[idx];
          real = v.type;
          if (!expected.cmp(real)) {
            perr(root);
            perr("fn_type=" + ctx.parent_fn.type_o);
            perr(v);
            throw new Error("Ret_multi type mismatch [" + idx + "] expected=" + expected + " real=" + real + " @fn=" + ctx.parent_fn.name);
          }
          ctx.walk(v, ctx);
        }
        return null;
      case "Class_decl":
        ti.class_prepare(root, ctx);
        ctx_nest = ctx.mk_nest();
        ctx_nest.current_class = root;
        _ref12 = root._prepared_field2type;
        for (k in _ref12) {
          v = _ref12[k];
          ctx_nest.var_map[k] = v;
        }
        ctx.walk(root.scope, ctx_nest);
        return root.type;
      case "Fn_decl_multiret":
        complex_type = new Type("function2");
        complex_type.nest_list.push(root.type_i);
        complex_type.nest_list.push(root.type_o);
        ctx.var_map[root.name] = complex_type;
        ctx_nest = ctx.mk_nest();
        ctx_nest.parent_fn = root;
        _ref13 = root.arg_name_list;
        for (k = _r = 0, _len9 = _ref13.length; _r < _len9; k = ++_r) {
          name = _ref13[k];
          type = root.type_i.nest_list[k];
          ctx_nest.var_map[name] = type;
        }
        ctx.walk(root.scope, ctx_nest);
        return root.type;
      case "PM_switch":
        return null;
      case "If":
        ctx.walk(root.cond, ctx);
        ctx.walk(root.t, ctx.mk_nest());
        ctx.walk(root.f, ctx.mk_nest());
        return null;
      case "While":
        ctx.walk(root.cond, ctx.mk_nest());
        ctx.walk(root.scope, ctx.mk_nest());
        return null;
      case "Enum_decl":
        ctx.type_map[root.name] = root;
        _ref14 = root.value_list;
        for (_s = 0, _len10 = _ref14.length; _s < _len10; _s++) {
          decl = _ref14[_s];
          ctx.var_map[decl.name] = decl.type;
        }
        return new Type("enum");
      case "Type_cast":
        ctx.walk(root.t, ctx);
        return root.type;
      case "Ternary":
        ctx.walk(root.cond, ctx);
        t = ctx.walk(root.t, ctx);
        f = ctx.walk(root.f, ctx);
        root.t.type = ti.type_spread_left(root.t.type, root.f.type, ctx);
        root.f.type = ti.type_spread_left(root.f.type, root.t.type, ctx);
        root.type = ti.type_spread_left(root.type, root.t.type, ctx);
        return root.type;
      case "New":
        _ref15 = root.arg_list;
        for (_t = 0, _len11 = _ref15.length; _t < _len11; _t++) {
          arg = _ref15[_t];
          ctx.walk(arg, ctx);
        }
        return root.type;
      case "Tuple":
        _ref16 = root.list;
        for (_u = 0, _len12 = _ref16.length; _u < _len12; _u++) {
          v = _ref16[_u];
          ctx.walk(v, ctx);
        }
        nest_list = [];
        _ref17 = root.list;
        for (_v = 0, _len13 = _ref17.length; _v < _len13; _v++) {
          v = _ref17[_v];
          nest_list.push(v.type);
        }
        type = new Type("tuple<>");
        type.nest_list = nest_list;
        root.type = ti.type_spread_left(root.type, type, ctx);
        _ref18 = root.type.nest_list;
        for (idx = _w = 0, _len14 = _ref18.length; _w < _len14; idx = ++_w) {
          v = _ref18[idx];
          tuple_value = root.list[idx];
          tuple_value.type = ti.type_spread_left(tuple_value.type, v, ctx);
        }
        return root.type;
      case "Array_init":
        _ref19 = root.list;
        for (_x = 0, _len15 = _ref19.length; _x < _len15; _x++) {
          v = _ref19[_x];
          ctx.walk(v, ctx);
        }
        nest_type = null;
        if (root.type) {
          if (root.type.main !== "array") {
            throw new Error("Array_init can have only array type");
          }
          nest_type = root.type.nest_list[0];
        }
        _ref20 = root.list;
        for (_y = 0, _len16 = _ref20.length; _y < _len16; _y++) {
          v = _ref20[_y];
          nest_type = ti.type_spread_left(nest_type, v.type, ctx);
        }
        _ref21 = root.list;
        for (_z = 0, _len17 = _ref21.length; _z < _len17; _z++) {
          v = _ref21[_z];
          v.type = ti.type_spread_left(v.type, nest_type, ctx);
        }
        type = new Type("array<>");
        type.nest_list[0] = nest_type.clone();
        root.type = ti.type_spread_left(root.type, type, ctx);
        return root.type;
      case "Event_decl":
        return null;
      default:

        /* !pragma coverage-skip-block */
        perr(root);
        throw new Error("ti phase 1 unknown node '" + root.constructor.name + "'");
    }
  };

}).call(window.require_register("./type_inference/stage1"));
