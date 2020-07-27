(function() {
  var Type, config, get_list_sign, ti;

  config = require("../config");

  Type = window.Type;

  ti = require("./common");

  get_list_sign = function(list) {
    var has_signed, has_unsigned, has_wtf, v, _i, _len;
    has_signed = false;
    has_unsigned = false;
    has_wtf = false;
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      v = list[_i];
      if (config.int_type_map.hasOwnProperty(v) || v === "signed_number") {
        has_signed = true;
      } else if (config.uint_type_map.hasOwnProperty(v) || v === "unsigned_number") {
        has_unsigned = true;
      } else if (v === "number") {
        has_signed = true;
        has_unsigned = true;
      } else {
        has_wtf = true;
      }
    }
    if (has_wtf) {
      return null;
    }
    if (has_signed && has_unsigned) {
      return "number";
    }
    if (has_signed && !has_unsigned) {
      return "signed_number";
    }
    if (!has_signed && has_unsigned) {
      return "unsigned_number";
    }
    throw new Error("unreachable");
  };

  this.walk = function(root, ctx) {
    var a, a_type_list, b, b_type_list, bruteforce_a, bruteforce_b, bruteforce_ret, filter_found_list, found_list, list, new_type, ret, ret_type_list, tuple, _i, _j, _k, _l, _len, _len1, _len10, _len11, _len2, _len3, _len4, _len5, _len6, _len7, _len8, _len9, _m, _n, _o, _p, _q, _r, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _s, _t;
    switch (root.constructor.name) {
      case "Var":
      case "Const":
      case "Field_access":
      case "Struct_init":
      case "Comment":
      case "Continue":
      case "Break":
      case "Var_decl":
      case "Var_decl_multi":
      case "Throw":
      case "Scope":
      case "Ret_multi":
      case "Class_decl":
      case "Fn_decl_multiret":
      case "PM_switch":
      case "If":
      case "While":
      case "Enum_decl":
      case "Type_cast":
      case "Ternary":
      case "New":
      case "Tuple":
      case "Event_decl":
      case "Fn_call":
      case "Array_init":
        return ctx.first_stage_walk(root, ctx);
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
            return root.type;
          case "EQ":
          case "NE":
          case "GT":
          case "GTE":
          case "LT":
          case "LTE":
            root.type = ti.type_spread_left(root.type, new Type("bool"), ctx);
            root.a.type = ti.type_spread_left(root.a.type, root.b.type, ctx);
            root.b.type = ti.type_spread_left(root.b.type, root.a.type, ctx);
            return root.type;
          case "INDEX_ACCESS":
            switch ((_ref = root.a.type) != null ? _ref.main : void 0) {
              case "string":
                root.b.type = ti.type_spread_left(root.b.type, new Type("uint256"), ctx);
                root.type = ti.type_spread_left(root.type, new Type("string"), ctx);
                return root.type;
              case "map":
                root.b.type = ti.type_spread_left(root.b.type, root.a.type.nest_list[0], ctx);
                root.type = ti.type_spread_left(root.type, root.a.type.nest_list[1], ctx);
                return root.type;
              case "array":
                root.b.type = ti.type_spread_left(root.b.type, new Type("uint256"), ctx);
                root.type = ti.type_spread_left(root.type, root.a.type.nest_list[0], ctx);
                return root.type;
              default:
                if (config.bytes_type_map.hasOwnProperty((_ref1 = root.a.type) != null ? _ref1.main : void 0)) {
                  root.b.type = ti.type_spread_left(root.b.type, new Type("uint256"), ctx);
                  root.type = ti.type_spread_left(root.type, new Type("bytes1"), ctx);
                  return root.type;
                }
            }
        }
        bruteforce_a = ti.is_not_defined_type(root.a.type);
        bruteforce_b = ti.is_not_defined_type(root.b.type);
        bruteforce_ret = ti.is_not_defined_type(root.type);
        a = (root.a.type || "").toString();
        b = (root.b.type || "").toString();
        ret = (root.type || "").toString();
        if (!(list = ti.bin_op_ret_type_map_list[root.op])) {
          throw new Error("unknown bin_op " + root.op);
        }
        found_list = [];
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          tuple = list[_i];
          if (tuple[0] !== a && !bruteforce_a) {
            continue;
          }
          if (tuple[1] !== b && !bruteforce_b) {
            continue;
          }
          if (tuple[2] !== ret && !bruteforce_ret) {
            continue;
          }
          found_list.push(tuple);
        }
        if (ti.is_number_type(root.a.type)) {
          filter_found_list = [];
          for (_j = 0, _len1 = found_list.length; _j < _len1; _j++) {
            tuple = found_list[_j];
            if (!config.any_int_type_map.hasOwnProperty(tuple[0])) {
              continue;
            }
            filter_found_list.push(tuple);
          }
          found_list = filter_found_list;
        }
        if (ti.is_number_type(root.b.type)) {
          filter_found_list = [];
          for (_k = 0, _len2 = found_list.length; _k < _len2; _k++) {
            tuple = found_list[_k];
            if (!config.any_int_type_map.hasOwnProperty(tuple[1])) {
              continue;
            }
            filter_found_list.push(tuple);
          }
          found_list = filter_found_list;
        }
        if (ti.is_number_type(root.type)) {
          filter_found_list = [];
          for (_l = 0, _len3 = found_list.length; _l < _len3; _l++) {
            tuple = found_list[_l];
            if (!config.any_int_type_map.hasOwnProperty(tuple[2])) {
              continue;
            }
            filter_found_list.push(tuple);
          }
          found_list = filter_found_list;
        }
        if (found_list.length === 0) {
          throw new Error("type inference stuck bin_op " + root.op + " invalid a=" + a + " b=" + b + " ret=" + ret);
        } else if (found_list.length === 1) {
          _ref2 = found_list[0], a = _ref2[0], b = _ref2[1], ret = _ref2[2];
          root.a.type = ti.type_spread_left(root.a.type, new Type(a), ctx);
          root.b.type = ti.type_spread_left(root.b.type, new Type(b), ctx);
          root.type = ti.type_spread_left(root.type, new Type(ret), ctx);
        } else {
          if (bruteforce_a) {
            a_type_list = [];
            for (_m = 0, _len4 = found_list.length; _m < _len4; _m++) {
              tuple = found_list[_m];
              a_type_list.upush(tuple[0]);
            }
            if (a_type_list.length === 0) {
              perr("bruteforce stuck bin_op " + root.op + " caused a can't be any type");
            } else if (a_type_list.length === 1) {
              root.a.type = ti.type_spread_left(root.a.type, new Type(a_type_list[0]), ctx);
            } else {
              if (new_type = get_list_sign(a_type_list)) {
                root.a.type = ti.type_spread_left(root.a.type, new Type(new_type), ctx);
              }
            }
          }
          if (bruteforce_b) {
            b_type_list = [];
            for (_n = 0, _len5 = found_list.length; _n < _len5; _n++) {
              tuple = found_list[_n];
              b_type_list.upush(tuple[1]);
            }
            if (b_type_list.length === 0) {
              perr("bruteforce stuck bin_op " + root.op + " caused b can't be any type");
            } else if (b_type_list.length === 1) {
              root.b.type = ti.type_spread_left(root.b.type, new Type(b_type_list[0]), ctx);
            } else {
              if (new_type = get_list_sign(b_type_list)) {
                root.b.type = ti.type_spread_left(root.b.type, new Type(new_type), ctx);
              }
            }
          }
          if (bruteforce_ret) {
            ret_type_list = [];
            for (_o = 0, _len6 = found_list.length; _o < _len6; _o++) {
              tuple = found_list[_o];
              ret_type_list.upush(tuple[2]);
            }
            if (ret_type_list.length === 0) {
              perr("bruteforce stuck bin_op " + root.op + " caused ret can't be any type");
            } else if (ret_type_list.length === 1) {
              root.type = ti.type_spread_left(root.type, new Type(ret_type_list[0]), ctx);
            } else {
              if (new_type = get_list_sign(ret_type_list)) {
                root.type = ti.type_spread_left(root.type, new Type(new_type), ctx);
              }
            }
          }
        }
        return root.type;
      case "Un_op":
        ctx.walk(root.a, ctx);
        if (root.op === "DELETE") {
          if (root.a.constructor.name === "Bin_op") {
            if (root.a.op === "INDEX_ACCESS") {
              if (((_ref3 = root.a.a.type) != null ? _ref3.main : void 0) === "array") {
                return root.type;
              }
              if (((_ref4 = root.a.a.type) != null ? _ref4.main : void 0) === "map") {
                return root.type;
              }
            }
          }
        }
        bruteforce_a = ti.is_not_defined_type(root.a.type);
        bruteforce_ret = ti.is_not_defined_type(root.type);
        a = (root.a.type || "").toString();
        ret = (root.type || "").toString();
        if (!(list = ti.un_op_ret_type_map_list[root.op])) {
          throw new Error("unknown un_op " + root.op);
        }
        found_list = [];
        for (_p = 0, _len7 = list.length; _p < _len7; _p++) {
          tuple = list[_p];
          if (tuple[0] !== a && !bruteforce_a) {
            continue;
          }
          if (tuple[1] !== ret && !bruteforce_ret) {
            continue;
          }
          found_list.push(tuple);
        }
        if (ti.is_number_type(root.a.type)) {
          filter_found_list = [];
          for (_q = 0, _len8 = found_list.length; _q < _len8; _q++) {
            tuple = found_list[_q];
            if (!config.any_int_type_map.hasOwnProperty(tuple[0])) {
              continue;
            }
            filter_found_list.push(tuple);
          }
          found_list = filter_found_list;
        }
        if (ti.is_number_type(root.type)) {
          filter_found_list = [];
          for (_r = 0, _len9 = found_list.length; _r < _len9; _r++) {
            tuple = found_list[_r];
            if (!config.any_int_type_map.hasOwnProperty(tuple[1])) {
              continue;
            }
            filter_found_list.push(tuple);
          }
          found_list = filter_found_list;
        }
        if (found_list.length === 0) {
          throw new Error("type inference stuck un_op " + root.op + " invalid a=" + a + " ret=" + ret);
        } else if (found_list.length === 1) {
          _ref5 = found_list[0], a = _ref5[0], ret = _ref5[1];
          root.a.type = ti.type_spread_left(root.a.type, new Type(a), ctx);
          root.type = ti.type_spread_left(root.type, new Type(ret), ctx);
        } else {
          if (bruteforce_a) {
            a_type_list = [];
            for (_s = 0, _len10 = found_list.length; _s < _len10; _s++) {
              tuple = found_list[_s];
              a_type_list.upush(tuple[0]);
            }
            if (a_type_list.length === 0) {
              throw new Error("type inference bruteforce stuck un_op " + root.op + " caused a can't be any type");
            } else if (a_type_list.length === 1) {
              root.a.type = ti.type_spread_left(root.a.type, new Type(a_type_list[0]), ctx);
            } else {
              if (new_type = get_list_sign(a_type_list)) {
                root.a.type = ti.type_spread_left(root.a.type, new Type(new_type), ctx);
              }
            }
          }
          if (bruteforce_ret) {
            ret_type_list = [];
            for (_t = 0, _len11 = found_list.length; _t < _len11; _t++) {
              tuple = found_list[_t];
              ret_type_list.upush(tuple[1]);
            }
            if (ret_type_list.length === 0) {
              throw new Error("type inference bruteforce stuck un_op " + root.op + " caused ret can't be any type");
            } else if (ret_type_list.length === 1) {
              root.type = ti.type_spread_left(root.type, new Type(ret_type_list[0]), ctx);
            } else {
              if (new_type = get_list_sign(ret_type_list)) {
                root.type = ti.type_spread_left(root.type, new Type(new_type), ctx);
              }
            }
          }
        }
        return root.type;
      default:

        /* !pragma coverage-skip-block */
        perr(root);
        throw new Error("ti phase 2 unknown node '" + root.constructor.name + "'");
    }
  };

}).call(window.require_register("./type_inference/stage2"));
