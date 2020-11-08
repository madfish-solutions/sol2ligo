(function() {
  var Type, config, default_var_map_gen, last_bracket_state, module, number2bytes, some2nat, spec_id_translate, string2bytes, ti_map, translate_type, translate_var_name, type2default_value, type_generalize, walk, _ref;

  module = this;

  

  config = require("./config");

  Type = window.Type;

  _ref = require("./translate_var_name"), translate_var_name = _ref.translate_var_name, spec_id_translate = _ref.spec_id_translate;

  default_var_map_gen = require("./type_inference/common").default_var_map_gen;

  type_generalize = require("./type_generalize").type_generalize;

  ti_map = default_var_map_gen();

  ti_map["encodePacked"] = new Type("function2<function<bytes>,function<bytes>>");

  module.warning_counter = 0;

  walk = null;

  this.bin_op_name_map = {
    ADD: "+",
    MUL: "*",
    DIV: "/",
    EQ: "=",
    NE: "=/=",
    GT: ">",
    LT: "<",
    GTE: ">=",
    LTE: "<=",
    BOOL_AND: "and",
    BOOL_OR: "or"
  };

  string2bytes = function(val) {
    var ch, ret, _i, _len;
    ret = ["0x"];
    for (_i = 0, _len = val.length; _i < _len; _i++) {
      ch = val[_i];
      ret.push(ch.charCodeAt(0).rjust(2, "0"));
    }
    if (ret.length === 1) {
      return "(\"00\": bytes)";
    }
    return ret.join("");
  };

  some2nat = function(val, type) {
    if (config.int_type_map.hasOwnProperty(type)) {
      if (/^\d+$/.test(val)) {
        val = "" + val + "n";
      } else {
        val = "abs(" + val + ")";
      }
    }
    if (type.match(/^byte[s]?\d{0,2}$/)) {
      val = "(case (bytes_unpack (" + val + ") : option (nat)) of | Some(a) -> a | None -> 0n end)";
    }
    return val;
  };

  number2bytes = function(val, precision) {
    var hex, i, ret, _i;
    if (precision == null) {
      precision = 32;
    }
    ret = [];
    val = BigInt(val);
    for (i = _i = 0; 0 <= precision ? _i < precision : _i > precision; i = 0 <= precision ? ++_i : --_i) {
      hex = val & BigInt("0xFF");
      ret.push(hex.toString(16).rjust(2, "0"));
      val >>= BigInt(8);
    }
    ret.push("0x");
    ret.reverse();
    return ret.join("");
  };

  config.uint_type_map["unsigned_number"] = true;

  config.int_type_map["signed_number"] = true;

  this.bin_op_name_cb_map = {
    ASSIGN: function(a, b, ctx, ast) {
      if (config.bytes_type_map.hasOwnProperty(ast.a.type.main) && ast.b.type.main === "string" && ast.b.constructor.name === "Const") {
        b = string2bytes(ast.b.val);
      }
      return "" + a + " := " + b;
    },
    BIT_AND: function(a, b, ctx, ast) {
      var ret;
      a = some2nat(a, ast.a.type.main);
      b = some2nat(b, ast.b.type.main);
      ret = "Bitwise.and(" + a + ", " + b + ")";
      if (config.int_type_map.hasOwnProperty(ast.a.type.main) && config.int_type_map.hasOwnProperty(ast.b.type.main)) {
        return "int(" + ret + ")";
      } else {
        return ret;
      }
    },
    BIT_OR: function(a, b, ctx, ast) {
      var ret;
      a = some2nat(a, ast.a.type.main);
      b = some2nat(b, ast.b.type.main);
      ret = "Bitwise.or(" + a + ", " + b + ")";
      if (config.int_type_map.hasOwnProperty(ast.a.type.main) && config.int_type_map.hasOwnProperty(ast.b.type.main)) {
        return "int(" + ret + ")";
      } else {
        return ret;
      }
    },
    BIT_XOR: function(a, b, ctx, ast) {
      var ret;
      a = some2nat(a, ast.a.type.main);
      b = some2nat(b, ast.b.type.main);
      ret = "Bitwise.xor(" + a + ", " + b + ")";
      if (config.int_type_map.hasOwnProperty(ast.a.type.main) && config.int_type_map.hasOwnProperty(ast.b.type.main)) {
        return "int(" + ret + ")";
      } else {
        return ret;
      }
    },
    SHR: function(a, b, ctx, ast) {
      var ret;
      a = some2nat(a, ast.a.type.main);
      b = some2nat(b, ast.b.type.main);
      ret = "Bitwise.shift_right(" + a + ", " + b + ")";
      if (config.int_type_map.hasOwnProperty(ast.a.type.main) && config.int_type_map.hasOwnProperty(ast.b.type.main)) {
        return "int(" + ret + ")";
      } else {
        return ret;
      }
    },
    SHL: function(a, b, ctx, ast) {
      var ret;
      a = some2nat(a, ast.a.type.main);
      b = some2nat(b, ast.b.type.main);
      ret = "Bitwise.shift_left(" + a + ", " + b + ")";
      if (config.int_type_map.hasOwnProperty(ast.a.type.main) && config.int_type_map.hasOwnProperty(ast.b.type.main)) {
        return "int(" + ret + ")";
      } else {
        return ret;
      }
    },
    INDEX_ACCESS: function(a, b, ctx, ast) {
      var ret, val;
      return ret = ctx.lvalue ? "" + a + "[" + b + "]" : (val = type2default_value(ast.type, ctx), "(case " + a + "[" + b + "] of | None -> " + val + " | Some(x) -> x end)");
    },
    SUB: function(a, b, ctx, ast) {
      if (config.uint_type_map.hasOwnProperty(ast.a.type.main) && config.uint_type_map.hasOwnProperty(ast.b.type.main)) {
        return "abs(" + a + " - " + b + ")";
      } else {
        return "(" + a + " - " + b + ")";
      }
    },
    MOD: function(a, b, ctx, ast) {
      if (config.int_type_map.hasOwnProperty(ast.a.type.main) && config.int_type_map.hasOwnProperty(ast.b.type.main)) {
        return "int(" + a + " mod " + b + ")";
      } else {
        return "(" + a + " mod " + b + ")";
      }
    },
    POW: function(a, b, ctx, ast) {
      if (config.uint_type_map.hasOwnProperty(ast.a.type.main) && config.uint_type_map.hasOwnProperty(ast.b.type.main)) {
        return "pow(" + a + ", " + b + ")";
      } else {
        return "failwith('Exponentiation is only available for unsigned types. Here operands " + a + " and " + b + " have types " + ast.a.type.main + " and " + ast.a.type.main + "');";
      }
    }
  };

  this.un_op_name_cb_map = {
    MINUS: function(a) {
      return "-(" + a + ")";
    },
    PLUS: function(a) {
      return "+(" + a + ")";
    },
    BIT_NOT: function(a, ctx, ast) {
      if (!ast.type) {
        perr("WARNING (Translate). BIT_NOT ( ~" + a + " ) translation may be incorrect. Read more https://git.io/JUqiS");
        module.warning_counter++;
      }
      if (ast.type && config.uint_type_map.hasOwnProperty(ast.type.main)) {
        return "abs(not (" + a + "))";
      } else {
        return "not (" + a + ")";
      }
    },
    BOOL_NOT: function(a) {
      return "not (" + a + ")";
    },
    RET_INC: function(a, ctx, ast) {
      var is_uint, one;
      perr("WARNING (Translate). RET_INC may have not fully correct implementation. Read more https://git.io/JUqiS");
      module.warning_counter++;
      is_uint = config.uint_type_map.hasOwnProperty(ast.a.type.main);
      one = "1";
      if (is_uint) {
        one += "n";
      }
      ctx.sink_list.push("" + a + " := " + a + " + " + one);
      if (is_uint) {
        return ctx.trim_expr = "abs(" + a + " - " + one + ")";
      } else {
        return ctx.trim_expr = "(" + a + " - " + one + ")";
      }
    },
    RET_DEC: function(a, ctx, ast) {
      var is_uint, one;
      perr("WARNING (Translate). RET_DEC may have not fully correct implementation. Read more https://git.io/JUqiS");
      module.warning_counter++;
      is_uint = config.uint_type_map.hasOwnProperty(ast.a.type.main);
      one = "1";
      if (is_uint) {
        one += "n";
      }
      if (is_uint) {
        ctx.sink_list.push("" + a + " := abs(" + a + " - " + one + ")");
      } else {
        ctx.sink_list.push("" + a + " := " + a + " - " + one);
      }
      return ctx.trim_expr = "(" + a + " + " + one + ")";
    },
    INC_RET: function(a, ctx, ast) {
      var is_uint, one;
      perr("WARNING (Translate). INC_RET may have not fully correct implementation. Read more https://git.io/JUqiS");
      module.warning_counter++;
      is_uint = config.uint_type_map.hasOwnProperty(ast.a.type.main);
      one = "1";
      if (is_uint) {
        one += "n";
      }
      ctx.sink_list.push("" + a + " := " + a + " + " + one);
      return ctx.trim_expr = "" + a;
    },
    DEC_RET: function(a, ctx, ast) {
      var is_uint, one;
      perr("WARNING (Translate). DEC_RET may have not fully correct implementation. Read more https://git.io/JUqiS");
      module.warning_counter++;
      is_uint = config.uint_type_map.hasOwnProperty(ast.a.type.main);
      one = "1";
      if (is_uint) {
        one += "n";
      }
      if (is_uint) {
        ctx.sink_list.push("" + a + " := abs(" + a + " - " + one + ")");
      } else {
        ctx.sink_list.push("" + a + " := " + a + " - " + one);
      }
      return ctx.trim_expr = "" + a;
    },
    DELETE: function(a, ctx, ast) {
      var bin_op_a, bin_op_b, nest_ctx;
      if (ast.a.constructor.name !== "Bin_op") {
        throw new Error("can't compile DELETE operation for non 'delete a[b]' like construction. Reason not Bin_op");
      }
      if (ast.a.op !== "INDEX_ACCESS") {
        throw new Error("can't compile DELETE operation for non 'delete a[b]' like construction. Reason not INDEX_ACCESS");
      }
      nest_ctx = ctx.mk_nest();
      bin_op_a = walk(ast.a.a, nest_ctx);
      bin_op_b = walk(ast.a.b, nest_ctx);
      return "remove " + bin_op_b + " from map " + bin_op_a;
    }
  };

  this.translate_type = translate_type = function(type, ctx) {
    var is_struct, key, list, name, nest, translated_type, type_list, v, value, _i, _j, _len, _len1, _ref1, _ref2, _ref3, _ref4;
    switch (type.main) {
      case "bool":
        return "bool";
      case "Unit":
        return "Unit";
      case "string":
        return "string";
      case "address":
        return "address";
      case "timestamp":
        return "timestamp";
      case "operation":
        return "operation";
      case "built_in_op_list":
        return "list(operation)";
      case "list":
        nest = translate_type(type.nest_list[0], ctx);
        return "list(" + nest + ")";
      case "array":
        nest = translate_type(type.nest_list[0], ctx);
        return "map(nat, " + nest + ")";
      case "tuple":
        list = [];
        _ref1 = type.nest_list;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          v = _ref1[_i];
          list.push(translate_type(v, ctx));
        }
        if (list.length === 0) {
          return "unit";
        } else {
          return "(" + (list.join(' * ')) + ")";
        }
        break;
      case "map":
        key = translate_type(type.nest_list[0], ctx);
        value = translate_type(type.nest_list[1], ctx);
        return "map(" + key + ", " + value + ")";
      case config.storage:
        return config.storage;
      case "contract":
        if (type.val) {
          return "contract(" + type.val + ")";
        } else {
          type_list = [];
          _ref2 = type.nest_list;
          for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
            type = _ref2[_j];
            translated_type = translate_type(type, ctx);
            type_list.push(translated_type);
          }
          return "contract(" + (type_list.join(", ")) + ")";
        }
        break;
      default:
        if ((_ref3 = ctx.type_decl_map) != null ? _ref3.hasOwnProperty(type.main) : void 0) {
          name = type.main.replace(/\./g, "_");
          is_struct = ((ctx.current_class && ctx.type_decl_map["" + ctx.current_class.name + "_" + name]) || ctx.type_decl_map[name]) && ((_ref4 = ctx.type_decl_map[name]) != null ? _ref4.constructor.name : void 0) === "Class_decl";
          if (ctx.current_class && is_struct) {
            name = "" + ctx.current_class.name + "_" + name;
          }
          name = translate_var_name(name, ctx);
          return name;
        } else if (type.main.match(/^byte[s]?\d{0,2}$/)) {
          return "bytes";
        } else if (config.uint_type_map.hasOwnProperty(type.main)) {
          return "nat";
        } else if (config.int_type_map.hasOwnProperty(type.main)) {
          return "int";
        } else if (type.main.match(RegExp("^" + config.storage + "_"))) {
          return type.main;
        } else if (type.main.startsWith("@")) {
          return type.main.substr(1);
        } else {
          perr("WARNING (Translate). translate_type unknown solidity type '" + type + "'");
          return "UNKNOWN_TYPE_" + type;
        }
    }
  };

  this.type2default_value = type2default_value = function(type, ctx) {
    var first_item, name, prefix, t, _ref1;
    if (config.uint_type_map.hasOwnProperty(type.main)) {
      return "0n";
    }
    if (config.int_type_map.hasOwnProperty(type.main)) {
      return "0";
    }
    if (config.bytes_type_map.hasOwnProperty(type.main)) {
      return "(\"00\": bytes)";
    }
    switch (type.main) {
      case "bool":
        return "False";
      case "address":
        if (!ctx.parent) {
          return "(" + (JSON.stringify(config.burn_address)) + " : address)";
        } else {
          return "burn_address";
        }
        break;
      case "built_in_op_list":
        return "(nil: list(operation))";
      case "contract":
        return "contract(unit)";
      case "map":
      case "array":
        return "(map end : " + (translate_type(type, ctx)) + ")";
      case "string":
        return '""';
      default:
        if (ctx.type_decl_map.hasOwnProperty(type.main)) {
          t = ctx.type_decl_map[type.main];
          if (t.constructor.name === "Enum_decl") {
            first_item = t.value_list[0].name;
            if (ctx.current_class.name) {
              prefix = "";
              if (ctx.current_class.name) {
                prefix = "" + ctx.current_class.name + "_";
              }
              return "" + name + "_" + first_item;
            } else {
              return "" + name + "(unit)";
            }
          }
          if (t.constructor.name === "Class_decl") {
            name = type.main;
            if ((_ref1 = ctx.current_class) != null ? _ref1.name : void 0) {
              name = "" + ctx.current_class.name + "_" + type.main;
            }
            return translate_var_name("" + name + "_default", ctx);
          }
        }
        perr("WARNING (Translate). Can't translate unknown Solidity type '" + type + "'");
        return "UNKNOWN_TYPE_DEFAULT_VALUE_" + type;
    }
  };

  this.Gen_context = (function() {
    Gen_context.prototype.parent = null;

    Gen_context.prototype.next_gen = null;

    Gen_context.prototype.current_class = null;

    Gen_context.prototype.is_class_scope = false;

    Gen_context.prototype.lvalue = false;

    Gen_context.prototype.type_decl_map = {};

    Gen_context.prototype.contract_var_map = {};

    Gen_context.prototype.contract = false;

    Gen_context.prototype.trim_expr = "";

    Gen_context.prototype.terminate_expr_check = "";

    Gen_context.prototype.terminate_expr_replace_fn = null;

    Gen_context.prototype.sink_list = [];

    Gen_context.prototype.tmp_idx = 0;

    Gen_context.prototype.storage_sink_list = {};

    Gen_context.prototype.type_decl_sink_list = [];

    Gen_context.prototype.structs_default_list = [];

    Gen_context.prototype.enum_list = [];

    Gen_context.prototype.files = null;

    Gen_context.prototype.keep_dir_structure = false;

    Gen_context.prototype.scope_root = null;

    function Gen_context() {
      this.type_decl_map = {};
      this.contract_var_map = {};
      this.storage_sink_list = {};
      this.sink_list = [];
      this.type_decl_sink_list = [];
      this.structs_default_list = [];
      this.enum_list = [];
      this.contract = false;
      this.files = null;
      this.keep_dir_structure = false;
    }

    Gen_context.prototype.mk_nest = function() {
      var t;
      t = new module.Gen_context;
      t.parent = this;
      t.current_class = this.current_class;
      obj_set(t.contract_var_map, this.contract_var_map);
      obj_set(t.type_decl_map, this.type_decl_map);
      t.type_decl_sink_list = this.type_decl_sink_list;
      t.structs_default_list = this.structs_default_list;
      t.enum_list = this.enum_list;
      t.contract = this.contract;
      t.files = this.files;
      t.keep_dir_structure = this.keep_dir_structure;
      t.scope_root = this.scope_root;
      return t;
    };

    return Gen_context;

  })();

  last_bracket_state = false;

  walk = function(root, ctx) {
    var a, arg, arg_jl, arg_list, arg_num, args, aux, body, call_expr, case_scope, cb, chk_ret, code, cond, ctx_lvalue, decl, decls, entry, f, field_access_translation, field_decl_jl, fn, get_tmp, i, idx, jl, jls, k, loc_code, main_file, main_file_unshift_list, modifies_storage, msg, name, old_scope_root, op, orig_ctx, path, prefix, ret, ret_jl, ret_types_list, returns_op_list, returns_value, scope, shift_self, state_name, str, t, target_type, text, tmp_var, translated_type, type, type_decl, type_decl_jl, type_list, type_o, type_str, uses_storage, v, val, _a, _aa, _ab, _ac, _ad, _ae, _af, _ag, _ah, _ai, _b, _base, _case, _i, _j, _k, _l, _len, _len1, _len10, _len11, _len12, _len13, _len14, _len15, _len16, _len17, _len18, _len19, _len2, _len20, _len21, _len22, _len23, _len24, _len25, _len3, _len4, _len5, _len6, _len7, _len8, _len9, _m, _n, _o, _p, _q, _r, _ref1, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref19, _ref2, _ref20, _ref21, _ref22, _ref23, _ref24, _ref25, _ref26, _ref27, _ref28, _ref29, _ref3, _ref30, _ref31, _ref32, _ref33, _ref34, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9, _s, _t, _u, _v, _var, _w, _x, _y, _z;
    main_file = "";
    last_bracket_state = false;
    switch (root.constructor.name) {
      case "Scope":
        switch (root.original_node_type) {
          case "SourceUnit":
            jls = {};
            jls[main_file] = [];
            main_file_unshift_list = [];
            _ref1 = root.list;
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              v = _ref1[_i];
              code = walk(v, ctx);
              path = ctx.keep_dir_structure ? v.file : null;
              if (path == null) {
                path = main_file;
              }
              if (code) {
                if ((_ref2 = v.constructor.name) !== "Comment" && _ref2 !== "Scope" && _ref2 !== "Include") {
                  if (!/;$/.test(code)) {
                    code += ";";
                  }
                  if ((_ref3 = v.name) === "burn_address" || _ref3 === "pow") {
                    code += "\n";
                    main_file_unshift_list.push(code);
                    continue;
                  }
                }
                if (jls[path] == null) {
                  jls[path] = [];
                }
                jls[path].push(code);
              }
            }
            if (ctx.structs_default_list.length) {
              jls[main_file].unshift("" + (join_list(ctx.structs_default_list)));
            }
            name = config.storage;
            while ((v = main_file_unshift_list.pop()) != null) {
              jls[main_file].unshift(v);
            }
            jls[main_file].unshift("");
            if (Object.keys(ctx.storage_sink_list).length === 0) {
              jls[main_file].unshift("type " + name + " is unit;");
            } else {
              _ref4 = ctx.storage_sink_list;
              for (k in _ref4) {
                v = _ref4[k];
                if (v.length === 0) {
                  jls[main_file].unshift("type " + k + " is unit;");
                } else {
                  jls[main_file].unshift("type " + k + " is record\n  " + (join_list(v, '  ')) + "\nend;");
                }
              }
            }
            ctx.storage_sink_list = {};
            if (ctx.type_decl_sink_list.length) {
              type_decl_jl = [];
              _ref5 = ctx.type_decl_sink_list;
              for (_j = 0, _len1 = _ref5.length; _j < _len1; _j++) {
                type_decl = _ref5[_j];
                name = type_decl.name, field_decl_jl = type_decl.field_decl_jl;
                if (field_decl_jl.length === 0) {
                  type_decl_jl.push("type " + name + " is unit;");
                } else {
                  type_decl_jl.push("type " + name + " is record\n  " + (join_list(field_decl_jl, '  ')) + "\nend;\n");
                }
              }
              jls[main_file].unshift("" + (join_list(type_decl_jl)));
              if (ctx.enum_list.length) {
                jls[main_file].unshift("");
                jls[main_file].unshift("" + (join_list(ctx.enum_list)));
                ctx.enum_list = [];
              }
            }
            for (path in jls) {
              jl = jls[path];
              ctx.files[path] = join_list(jl, "");
            }
            return ctx.files[main_file];
          default:
            if (!root.original_node_type) {
              jls = {};
              jls[main_file] = [];
              _ref6 = root.list;
              for (_k = 0, _len2 = _ref6.length; _k < _len2; _k++) {
                v = _ref6[_k];
                path = ctx.keep_dir_structure ? v.file : null;
                if (path == null) {
                  path = main_file;
                }
                if (jls[path] == null) {
                  jls[path] = [];
                }
                code = walk(v, ctx);
                _ref7 = ctx.sink_list;
                for (_l = 0, _len3 = _ref7.length; _l < _len3; _l++) {
                  loc_code = _ref7[_l];
                  if (!/;$/.test(loc_code)) {
                    loc_code += ";";
                  }
                  jls[path].push(loc_code);
                }
                ctx.sink_list.clear();
                if (ctx.trim_expr === code) {
                  ctx.trim_expr = "";
                  continue;
                }
                if (ctx.terminate_expr_check === code) {
                  ctx.terminate_expr_check = "";
                  code = ctx.terminate_expr_replace_fn();
                }
                if (code) {
                  if ((_ref8 = v.constructor.name) !== "Comment" && _ref8 !== "Scope" && _ref8 !== "Include") {
                    if (!/;$/.test(code)) {
                      code += ";";
                    }
                  }
                  jls[path].push(code);
                }
              }
              for (path in jls) {
                jl = jls[path];
                ret = jl.pop() || "";
                if (!ret.startsWith("with")) {
                  jl.push(ret);
                  ret = "";
                }
                jl = jl.filter(function(t) {
                  return t !== "";
                });
                if (!root.need_nest) {
                  if (jl.length) {
                    body = join_list(jl, "");
                  } else {
                    body = "";
                  }
                  ret = "";
                } else {
                  if (jl.length) {
                    body = "block {\n  " + (join_list(jl, '  ')) + "\n}";
                  } else {
                    body = "block {\n  skip\n}";
                  }
                }
                if (ret) {
                  ret = " " + ret;
                }
                code = "" + body + ret;
                ctx.files[path] = code;
              }
              return ctx.files[main_file];
            } else {
              puts(root);
              throw new Error("Unknown root.original_node_type " + root.original_node_type);
            }
        }
        break;
      case "Var":
        name = root.name;
        if (name === "this" || name === "super") {
          return "";
        }
        if (ctx.contract_var_map.hasOwnProperty(name)) {
          return "" + config.contract_storage + "." + name;
        } else {
          return name;
        }
        break;
      case "Const":
        if (!root.type) {
          puts(root);
          throw new Error("Can't type inference");
        }
        if (config.uint_type_map.hasOwnProperty(root.type.main)) {
          return "" + root.val + "n";
        }
        switch (root.type.main) {
          case "bool":
            switch (root.val) {
              case "true":
                return "True";
              case "false":
                return "False";
              default:
                throw new Error("can't translate bool constant '" + root.val + "'");
            }
            break;
          case "Unit":
            return "unit";
          case "number":
            perr("WARNING (Translate). Number constant passed to the translation stage. That's a type inference mistake");
            module.warning_counter++;
            return root.val;
          case "unsigned_number":
            return "" + root.val + "n";
          case "mutez":
            return "" + root.val + "mutez";
          case "string":
            return JSON.stringify(root.val);
          case "built_in_op_list":
            if (root.val) {
              return "" + root.val;
            } else {
              return "(nil: list(operation))";
            }
            break;
          default:
            if (config.bytes_type_map.hasOwnProperty(root.type.main)) {
              return number2bytes(root.val, +root.type.main.replace(/bytes/, ''));
            } else {
              return root.val;
            }
        }
        break;
      case "Bin_op":
        ctx_lvalue = ctx.mk_nest();
        if (0 === root.op.indexOf("ASS")) {
          ctx_lvalue.lvalue = true;
        }
        _a = walk(root.a, ctx_lvalue);
        ctx.sink_list.append(ctx_lvalue.sink_list);
        _b = walk(root.b, ctx);
        return ret = (function() {
          if (op = module.bin_op_name_map[root.op]) {
            last_bracket_state = true;
            if (((root.a.type && root.a.type.main === 'bool') || (root.b.type && root.b.type.main === 'bool')) && (op === '>=' || op === '=/=' || op === '<=' || op === '>' || op === '<' || op === '=')) {
              switch (op) {
                case "=":
                  return "(" + _a + " = " + _b + ")";
                case "=/=":
                  return "(" + _a + " =/= " + _b + ")";
                case ">":
                  return "(" + _a + " and not " + _b + ")";
                case "<":
                  return "((not " + _a + ") and " + _b + ")";
                case ">=":
                  return "(" + _a + " or not " + _b + ")";
                case "<=":
                  return "((not " + _a + ") or " + _b + ")";
                default:
                  return "(" + _a + " " + op + " " + _b + ")";
              }
            } else {
              return "(" + _a + " " + op + " " + _b + ")";
            }
          } else if (cb = module.bin_op_name_cb_map[root.op]) {
            return cb(_a, _b, ctx, root);
          } else {
            throw new Error("Unknown/unimplemented bin_op " + root.op);
          }
        })();
      case "Un_op":
        a = walk(root.a, ctx);
        if (cb = module.un_op_name_cb_map[root.op]) {
          return cb(a, ctx, root);
        } else {
          throw new Error("Unknown/unimplemented un_op " + root.op);
        }
        break;
      case "Field_access":
        t = walk(root.t, ctx);
        if (!root.t.type) {
          perr("WARNING (Translate). Some of types in Field_access aren't resolved. This can cause invalid code generated");
        } else {
          switch (root.t.type.main) {
            case "array":
              switch (root.name) {
                case "length":
                  return "size(" + t + ")";
                default:
                  throw new Error("unknown array field " + root.name);
              }
              break;
            case "bytes":
              switch (root.name) {
                case "length":
                  return "size(" + t + ")";
                default:
                  throw new Error("unknown array field " + root.name);
              }
              break;
            case "enum":
              return root.name;
          }
        }
        if (t === "") {
          return root.name;
        }
        chk_ret = "" + t + "." + root.name;
        ret = "" + t + "." + root.name;
        if (root.t.constructor.name === "Var") {
          if ((_ref9 = ctx.type_decl_map[root.t.name]) != null ? _ref9.is_library : void 0) {
            ret = translate_var_name("" + t + "_" + root.name, ctx);
          }
        }
        return spec_id_translate(chk_ret, ret);
      case "Fn_call":
        arg_list = [];
        _ref10 = root.arg_list;
        for (_m = 0, _len4 = _ref10.length; _m < _len4; _m++) {
          v = _ref10[_m];
          arg_list.push(walk(v, ctx));
        }
        field_access_translation = null;
        if (root.fn.constructor.name === "Field_access") {
          field_access_translation = walk(root.fn.t, ctx);
          if (root.fn.t.type) {
            switch (root.fn.t.type.main) {
              case "array":
                switch (root.fn.name) {
                  case "push":
                    tmp_var = "tmp_" + (ctx.tmp_idx++);
                    ctx.sink_list.push("const " + tmp_var + " : " + (translate_type(root.fn.t.type, ctx)) + " = " + field_access_translation + ";");
                    return "" + tmp_var + "[size(" + tmp_var + ")] := " + arg_list[0];
                  default:
                    throw new Error("unknown array field function " + root.fn.name);
                }
            }
          }
        }
        if (root.fn.constructor.name === "Var") {
          switch (root.fn.name) {
            case "require":
            case "assert":
            case "require2":
              cond = arg_list[0];
              str = arg_list[1];
              if (str) {
                return "assert(" + cond + ") (* " + str + " *)";
              } else {
                return "assert(" + cond + ")";
              }
              break;
            case "revert":
              str = arg_list[0] || '"revert"';
              return "failwith(" + str + ")";
            case "sha256":
              msg = arg_list[0];
              return "sha_256(" + msg + ")";
            case "sha3":
            case "keccak256":
              perr("WARNING (Translate). " + root.fn.name + " hash function will be translated as sha_256. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#hash-functions");
              msg = arg_list[0];
              return "sha_256(" + msg + ")";
            case "selfdestruct":
              perr("WARNING (Translate). " + root.fn.name + " does not exist in LIGO. Statement translated as is");
              msg = arg_list[0];
              return "selfdestruct(" + msg + ") (* unsupported *)";
            case "blockhash":
              msg = arg_list[0];
              perr("WARNING (Translate). " + root.fn.name + " does not exist in LIGO. We replaced it with (\"" + msg + "\" : bytes).");
              return "(\"00\" : bytes) (* Should be blockhash of " + msg + " *)";
            case "ripemd160":
              perr("WARNING (Translate). " + root.fn.name + " hash function will be translated as blake2b. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#hash-functions");
              msg = arg_list[0];
              return "blake2b(" + msg + ")";
            case "ecrecover":
              perr("WARNING (Translate). ecrecover function does not exist in LIGO. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#ecrecover");
              fn = "ecrecover";
              break;
            case "@respond":
              type_list = [];
              _ref11 = root.arg_list;
              for (_n = 0, _len5 = _ref11.length; _n < _len5; _n++) {
                v = _ref11[_n];
                type_list.push(translate_type(v.type, ctx));
              }
              type_str = type_list.join(" * ");
              return "var " + config.op_list + " : list(operation) := list transaction((" + (arg_list.join(' * ')) + "), 0mutez, (get_contract(match_action." + config.callback_address + ") : contract(" + type_str + "))) end";
            case "@respond_append":
              type_list = [];
              _ref12 = root.arg_list;
              for (_o = 0, _len6 = _ref12.length; _o < _len6; _o++) {
                v = _ref12[_o];
                type_list.push(translate_type(v.type, ctx));
              }
              type_str = type_list.join(" * ");
              return "var " + config.op_list + " : list(operation) := cons(" + arg_list[0] + ", list transaction((" + (arg_list.slice(1).join(' * ')) + "), 0mutez, (get_contract(match_action." + config.callback_address + ") : contract(" + type_str + "))) end)";
            default:
              fn = root.fn.name;
          }
        } else {
          fn = walk(root.fn, ctx);
        }
        if (arg_list.length === 0) {
          arg_list.push("unit");
        }
        call_expr = "" + fn + "(" + (arg_list.join(', ')) + ")";
        if (!root.left_unpack || (fn === "get_contract" || fn === "transaction")) {
          return call_expr;
        } else {
          if (root.fn_decl) {
            _ref13 = root.fn_decl, returns_op_list = _ref13.returns_op_list, uses_storage = _ref13.uses_storage, modifies_storage = _ref13.modifies_storage, returns_value = _ref13.returns_value;
            type_o = root.fn_decl.type_o;
            if (root.is_fn_decl_from_using) {
              if (uses_storage) {
                shift_self = arg_list.shift();
              }
              arg_list.unshift(field_access_translation);
              if (uses_storage) {
                arg_list.unshift(shift_self);
              }
              call_expr = "" + root.fn_name_using + "(" + (arg_list.join(', ')) + ")";
            }
          } else if (type_decl = ti_map[root.fn.name]) {
            returns_op_list = false;
            modifies_storage = false;
            returns_value = type_decl.nest_list[1].nest_list.length > 0;
            type_o = type_decl.nest_list[1];
          } else if (ctx.contract_var_map.hasOwnProperty(root.fn.name)) {
            decl = ctx.contract_var_map[root.fn.name];
            if (decl.constructor.name === "Fn_decl_multiret") {
              return call_expr;
            }
            return "" + config.contract_storage + "." + root.fn.name;
          } else {
            perr("WARNING (Translate). !root.fn_decl " + root.fn.name);
            return call_expr;
          }
          ret_types_list = [];
          _ref14 = type_o.nest_list;
          for (_p = 0, _len7 = _ref14.length; _p < _len7; _p++) {
            v = _ref14[_p];
            ret_types_list.push(translate_type(v, ctx));
          }
          if (ret_types_list.length === 0) {
            return call_expr;
          } else if (ret_types_list.length === 1 && returns_value) {
            ctx.terminate_expr_replace_fn = function() {
              perr("WARNING (Translate). " + call_expr + " was terminated with dummy variable declaration");
              tmp_var = "terminate_tmp_" + (ctx.tmp_idx++);
              return "const " + tmp_var + " : (" + (ret_types_list.join(' * ')) + ") = " + call_expr;
            };
            return ctx.terminate_expr_check = call_expr;
          } else {
            if (ret_types_list.length === 1) {
              if (returns_op_list) {
                return "" + config.op_list + " := " + call_expr;
              } else if (modifies_storage) {
                return "" + config.contract_storage + " := " + call_expr;
              } else {
                throw new Error("WTF !returns_op_list !modifies_storage");
              }
            } else {
              tmp_var = "tmp_" + (ctx.tmp_idx++);
              ctx.sink_list.push("const " + tmp_var + " : (" + (ret_types_list.join(' * ')) + ") = " + call_expr);
              arg_num = 0;
              get_tmp = function() {
                if (ret_types_list.length === 1) {
                  return tmp_var;
                } else {
                  return "" + tmp_var + "." + (arg_num++);
                }
              };
              if (returns_op_list) {
                ctx.sink_list.push("" + config.op_list + " := " + (get_tmp()));
              }
              if (modifies_storage) {
                ctx.sink_list.push("" + config.contract_storage + " := " + (get_tmp()));
              }
              return ctx.trim_expr = get_tmp();
            }
          }
        }
        break;
      case "Struct_init":
        arg_list = [];
        for (i = _q = 0, _ref15 = root.val_list.length - 1; 0 <= _ref15 ? _q <= _ref15 : _q >= _ref15; i = 0 <= _ref15 ? ++_q : --_q) {
          arg_list.push("" + root.arg_names[i] + " = " + (walk(root.val_list[i], ctx)));
        }
        return "record [ " + (arg_list.join(";\n  ")) + " ]";
      case "Type_cast":
        target_type = translate_type(root.target_type, ctx);
        t = walk(root.t, ctx);
        if (t === "" && target_type === "address") {
          return "self_address";
        }
        if (target_type === "int") {
          return "int(abs(" + t + "))";
        } else if (target_type === "nat") {
          return "abs(" + t + ")";
        } else if (target_type === "bytes" && ((_ref16 = root.t.type) != null ? _ref16.main : void 0) === "string") {
          return "bytes_pack(" + t + ")";
        } else if (target_type === "address") {
          if (+t === 0) {
            return "burn_address";
          } else if (root.t.constructor.name === "Const") {
            root.t.type = new Type("string");
            t = walk(root.t, ctx);
            return "(" + t + " : " + target_type + ")";
          } else {
            return "(" + t + " : " + target_type + ")";
          }
        } else {
          return "(" + t + " : " + target_type + ")";
        }
        break;
      case "Comment":
        if (ctx.keep_dir_structure && root.text.startsWith("#include")) {
          text = root.text.replace(".sol", ".ligo");
          return text;
        } else if (root.can_skip) {
          return "";
        } else {
          return "(* " + root.text + " *)";
        }
        break;
      case "Continue":
        return "(* `continue` statement is not supported in LIGO *)";
      case "Break":
        return "(* `break` statement is not supported in LIGO *)";
      case "Var_decl":
        name = root.name;
        type = translate_type(root.type, ctx);
        if (ctx.is_class_scope && !root.is_const) {
          if (root.special_type) {
            type = "" + ctx.current_class.name + "_" + root.type.main;
          }
          type = translate_var_name(type, ctx);
          ctx.contract_var_map[name] = root;
          return "" + name + " : " + type + ";";
        } else {
          if (root.assign_value) {
            if (((_ref17 = root.assign_value) != null ? _ref17.constructor.name : void 0) === "Struct_init") {
              type = "" + ctx.current_class.name + "_" + root.type.main;
              type = translate_var_name(type, ctx);
            }
            val = walk(root.assign_value, ctx);
            if (config.bytes_type_map.hasOwnProperty(root.type.main) && root.assign_value.type.main === "string" && root.assign_value.constructor.name === "Const") {
              val = string2bytes(root.assign_value.val);
            }
            if (config.bytes_type_map.hasOwnProperty(root.type.main) && root.assign_value.type.main === "number" && root.assign_value.constructor.name === "Const") {
              val = number2bytes(root.assign_value.val);
            }
            return "const " + name + " : " + type + " = " + val;
          } else {
            return "const " + name + " : " + type + " = " + (type2default_value(root.type, ctx));
          }
        }
        break;
      case "Var_decl_multi":
        if (root.assign_value) {
          val = walk(root.assign_value, ctx);
          tmp_var = "tmp_" + (ctx.tmp_idx++);
          jl = [];
          type_list = [];
          _ref18 = root.list;
          for (idx = _r = 0, _len8 = _ref18.length; _r < _len8; idx = ++_r) {
            _var = _ref18[idx];
            name = _var.name;
            type_list.push(type = translate_type(_var.type, ctx));
            jl.push("const " + name + " : " + type + " = " + tmp_var + "." + idx + ";");
          }
          return "const " + tmp_var + " : (" + (type_list.join(' * ')) + ") = " + val + ";\n" + (join_list(jl));
        } else {
          perr("WARNING (Translate). Var_decl_multi with no assign value should be unreachable, but something went wrong");
          module.warning_counter++;
          jl = [];
          _ref19 = root.list;
          for (_s = 0, _len9 = _ref19.length; _s < _len9; _s++) {
            _var = _ref19[_s];
            name = _var.name;
            type = translate_type(root.type, ctx);
            jl.push("const " + name + " : " + type + " = " + (type2default_value(_var.type, ctx)));
          }
          return jl.join("\n");
        }
        break;
      case "Throw":
        if (root.t) {
          t = walk(root.t, ctx);
          return "failwith(" + t + ")";
        } else {
          return 'failwith("throw")';
        }
        break;
      case "Ret_multi":
        jl = [];
        _ref20 = root.t_list;
        for (idx = _t = 0, _len10 = _ref20.length; _t < _len10; idx = ++_t) {
          v = _ref20[idx];
          jl.push(walk(v, ctx));
        }
        if (ctx.scope_root.constructor.name === "Fn_decl_multiret") {
          if (ctx.scope_root.name !== "main") {
            _ref21 = ctx.scope_root.type_o.nest_list;
            for (idx = _u = 0, _len11 = _ref21.length; _u < _len11; idx = ++_u) {
              type = _ref21[idx];
              if (!root.t_list[idx]) {
                jl.push(type2default_value(type, ctx));
              }
            }
          }
          if (jl.length === 0) {
            jl.push("unit");
          }
          return "with (" + (jl.join(', ')) + ")";
        } else {
          perr("WARNING (Translate). Return at non end-of-function position is prohibited");
          return "failwith(\"return at non end-of-function position is prohibited\")";
        }
        break;
      case "If":
        cond = walk(root.cond, ctx);
        if (!last_bracket_state) {
          cond = "(" + cond + ")";
        }
        old_scope_root = ctx.scope_root;
        ctx.scope_root = root;
        t = walk(root.t, ctx);
        f = walk(root.f, ctx);
        ctx.scope_root = old_scope_root;
        return "if " + cond + " then " + t + " else " + f + ";";
      case "While":
        cond = walk(root.cond, ctx);
        if (!last_bracket_state) {
          cond = "(" + cond + ")";
        }
        old_scope_root = ctx.scope_root;
        ctx.scope_root = root;
        scope = walk(root.scope, ctx);
        ctx.scope_root = old_scope_root;
        return "while " + cond + " " + scope + ";";
      case "PM_switch":
        cond = walk(root.cond, ctx);
        ctx = ctx.mk_nest();
        jl = [];
        _ref22 = root.scope.list;
        for (_v = 0, _len12 = _ref22.length; _v < _len12; _v++) {
          _case = _ref22[_v];
          case_scope = walk(_case.scope, ctx);
          if (/;$/.test(case_scope)) {
            case_scope = case_scope.slice(0, -1);
          }
          jl.push("| " + _case.struct_name + "(" + _case.var_decl.name + ") -> " + case_scope);
        }
        if (jl.length) {
          return "case " + cond + " of\n" + (join_list(jl, '')) + "\nend";
        } else {
          return "unit";
        }
        break;
      case "Fn_decl_multiret":
        if (root.name === "pow") {
          return "function pow (const base : nat; const exp : nat) : nat is\n  block {\n    var b : nat := base;\n    var e : nat := exp;\n    var r : nat := 1n;\n    while e > 0n block {\n      if e mod 2n = 1n then {\n        r := r * b;\n      } else skip;\n      b := b * b;\n      e := e / 2n;\n    }\n  } with r;";
        }
        orig_ctx = ctx;
        ctx = ctx.mk_nest();
        arg_jl = [];
        _ref23 = root.arg_name_list;
        for (idx = _w = 0, _len13 = _ref23.length; _w < _len13; idx = ++_w) {
          v = _ref23[idx];
          type = translate_type(root.type_i.nest_list[idx], ctx);
          arg_jl.push("const " + v + " : " + type);
        }
        if (arg_jl.length === 0) {
          arg_jl.push("const " + config.reserved + "__unit : unit");
        }
        ret_jl = [];
        _ref24 = root.type_o.nest_list;
        for (_x = 0, _len14 = _ref24.length; _x < _len14; _x++) {
          v = _ref24[_x];
          type = translate_type(v, ctx);
          ret_jl.push("" + type);
        }
        if (ret_jl.length === 0) {
          ret_jl.push("unit");
        }
        ctx.scope_root = root;
        body = walk(root.scope, ctx);
        return "function " + root.name + " (" + (arg_jl.join('; ')) + ") : (" + (ret_jl.join(' * ')) + ") is\n  " + (make_tab(body, '  '));
      case "Class_decl":
        if (root.need_skip) {
          return "";
        }
        if (root.is_interface) {
          return "";
        }
        if (root.is_contract && !root.is_last) {
          return "";
        }
        orig_ctx = ctx;
        prefix = "";
        if (ctx.parent && ctx.current_class && root.namespace_name) {
          ctx.parent.type_decl_map["" + ctx.current_class.name + "." + root.name] = root;
          prefix = ctx.current_class.name;
        }
        ctx.type_decl_map[root.name] = root;
        ctx = ctx.mk_nest();
        ctx.current_class = root;
        ctx.is_class_scope = true;
        _ref25 = root.scope.list;
        for (_y = 0, _len15 = _ref25.length; _y < _len15; _y++) {
          v = _ref25[_y];
          switch (v.constructor.name) {
            case "Enum_decl":
            case "Class_decl":
              ctx.type_decl_map[v.name] = v;
              break;
            case "PM_switch":
              _ref26 = root.scope.list;
              for (_z = 0, _len16 = _ref26.length; _z < _len16; _z++) {
                _case = _ref26[_z];
                ctx.type_decl_map[_case.var_decl.type.main] = _case.var_decl;
              }
              break;
            default:
              "skip";
          }
        }
        field_decl_jl = [];
        _ref27 = root.scope.list;
        for (_aa = 0, _len17 = _ref27.length; _aa < _len17; _aa++) {
          v = _ref27[_aa];
          switch (v.constructor.name) {
            case "Var_decl":
              if (!v.is_const) {
                field_decl_jl.push(walk(v, ctx));
              } else {
                ctx.sink_list.push(walk(v, ctx));
              }
              break;
            case "Fn_decl_multiret":
              ctx.contract_var_map[v.name] = v;
              break;
            case "Enum_decl":
              "skip";
              break;
            case "Class_decl":
              code = walk(v, ctx);
              if (code) {
                ctx.sink_list.push(code);
              }
              break;
            case "Comment":
              "skip";
              break;
            case "Event_decl":
              ctx.sink_list.push(walk(v, ctx));
              break;
            default:
              throw new Error("unknown v.constructor.name " + v.constructor.name);
          }
        }
        jl = [];
        jl.append(ctx.sink_list);
        ctx.sink_list.clear();
        _ref28 = root.scope.list;
        for (_ab = 0, _len18 = _ref28.length; _ab < _len18; _ab++) {
          v = _ref28[_ab];
          switch (v.constructor.name) {
            case "Var_decl":
              "skip";
              break;
            case "Enum_decl":
              jl.unshift(walk(v, ctx));
              break;
            case "Comment":
              jl.push(walk(v, ctx));
              break;
            case "Fn_decl_multiret":
              jl.push(walk(v, ctx));
              break;
            case "Class_decl":
            case "Event_decl":
              "skip";
              break;
            default:
              throw new Error("unknown v.constructor.name " + v.constructor.name);
          }
        }
        if (root.is_contract || root.is_library) {
          state_name = config.storage;
          if ((_base = orig_ctx.storage_sink_list)[state_name] == null) {
            _base[state_name] = [];
          }
          orig_ctx.storage_sink_list[state_name].append(field_decl_jl);
        } else {
          name = root.name;
          if (prefix) {
            name = "" + prefix + "_" + name;
          }
          name = translate_var_name(name, ctx);
          if (root.is_struct) {
            arg_list = [];
            _ref29 = root.scope.list;
            for (_ac = 0, _len19 = _ref29.length; _ac < _len19; _ac++) {
              v = _ref29[_ac];
              arg_list.push("" + v.name + " = " + (type2default_value(v.type, ctx)));
            }
            ctx.structs_default_list.push("const " + name + "_default : " + name + " = record [ " + (arg_list.join(";\n  ")) + " ];\n");
          }
          ctx.type_decl_sink_list.push({
            name: name,
            field_decl_jl: field_decl_jl
          });
        }
        return jl.join("\n\n");
      case "Enum_decl":
        jl = [];
        _ref30 = root.value_list;
        for (idx = _ad = 0, _len20 = _ref30.length; _ad < _len20; idx = ++_ad) {
          v = _ref30[idx];
          ctx.contract_var_map[v.name] = v;
          aux = "";
          if (v.type) {
            aux = " of " + (translate_var_name(v.type.main.replace(/\./g, "_", ctx)));
          }
          jl.push("| " + v.name + aux);
        }
        if (jl.length) {
          entry = join_list(jl, ' ');
        } else {
          entry = "unit";
        }
        return "type " + root.name + " is\n  " + entry + ";";
      case "Ternary":
        cond = walk(root.cond, ctx);
        t = walk(root.t, ctx);
        f = walk(root.f, ctx);
        return "(case " + cond + " of | True -> " + t + " | False -> " + f + " end)";
      case "New":
        arg_list = [];
        _ref31 = root.arg_list;
        for (_ae = 0, _len21 = _ref31.length; _ae < _len21; _ae++) {
          v = _ref31[_ae];
          arg_list.push(walk(v, ctx));
        }
        args = "" + (join_list(arg_list, ', '));
        translated_type = translate_type(root.cls, ctx);
        if (root.cls.main === "array") {
          return "map end (* args: " + args + " *)";
        } else if (translated_type === "bytes") {
          return "(\"00\": bytes) (* args: " + args + " *)";
        } else {
          return "" + translated_type + "(" + args + ")";
        }
        break;
      case "Tuple":
        arg_list = [];
        _ref32 = root.list;
        for (_af = 0, _len22 = _ref32.length; _af < _len22; _af++) {
          v = _ref32[_af];
          arg_list.push(walk(v, ctx));
        }
        return "(" + (arg_list.join(', ')) + ")";
      case "Array_init":
        arg_list = [];
        _ref33 = root.list;
        for (_ag = 0, _len23 = _ref33.length; _ag < _len23; _ag++) {
          v = _ref33[_ag];
          arg_list.push(walk(v, ctx));
        }
        if (root.type.main === "built_in_op_list") {
          return "list [" + (arg_list.join("; ")) + "]";
        } else {
          decls = [];
          for (i = _ah = 0, _len24 = arg_list.length; _ah < _len24; i = ++_ah) {
            arg = arg_list[i];
            decls.push("" + i + "n -> " + arg + ";");
          }
          return "map\n  " + (join_list(decls, '  ')) + "\nend";
        }
        break;
      case "Event_decl":
        args = [];
        _ref34 = root.arg_list;
        for (_ai = 0, _len25 = _ref34.length; _ai < _len25; _ai++) {
          arg = _ref34[_ai];
          name = arg._name;
          type = translate_type(arg, ctx);
          args.push("" + name + " : " + type);
        }
        return "(* EventDefinition " + root.name + "(" + (args.join('; ')) + ") *)";
      case "Include":
        return "#include \"" + root.path + "\"";
      default:
        if (ctx.next_gen != null) {
          return ctx.next_gen(root, ctx);
        } else {
          perr(root);
          throw new Error("Unknown root.constructor.name " + root.constructor.name);
        }
    }
  };

  this.gen = function(root, opt) {
    var ctx, ret;
    if (opt == null) {
      opt = {};
    }
    ctx = new module.Gen_context;
    ctx.next_gen = opt.next_gen;
    ctx.keep_dir_structure = opt.keep_dir_structure;
    ctx.files = {};
    ret = walk(root, ctx);
    if (opt.keep_dir_structure) {
      return ctx.files[""];
    } else {
      return ret;
    }
  };

}).call(window.require_register("./translate_ligo"));
