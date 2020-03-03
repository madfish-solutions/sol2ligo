(function() {
  var bad_spec_id_trans_hash, config, last_bracket_state, module, number2bytes, some2nat, spec_id_trans_hash, spec_id_translate, string2bytes, translate_type, translate_var_name, type2default_value, walk, warning_once_hash;

  module = this;

  

  config = window.config

  module.warning_counter = 0;

  walk = null;

  this.bin_op_name_map = {
    ADD: "+",
    MUL: "*",
    DIV: "/",
    MOD: "mod",
    EQ: "=",
    NE: "=/=",
    GT: ">",
    LT: "<",
    GTE: ">=",
    LTE: "<=",
    POW: "LIGO_IMPLEMENT_ME_PLEASE_POW",
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
    if (type.match(/^int\d{0,3}$/)) {
      val = "abs(" + val + ")";
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
    for (i = _i = 0; 0 <= precision ? _i < precision : _i > precision; i = 0 <= precision ? ++_i : --_i) {
      hex = val & 0xFF;
      ret.push(hex.toString(16).rjust(2, "0"));
      val >>= 8;
    }
    ret.push("0x");
    ret.reverse();
    return ret.join("");
  };

  this.bin_op_name_cb_map = {
    ASSIGN: function(a, b, ctx, ast) {
      if (config.bytes_type_hash.hasOwnProperty(ast.a.type.main) && ast.b.type.main === "string" && ast.b.constructor.name === "Const") {
        b = string2bytes(ast.b.val);
      }
      return "" + a + " := " + b;
    },
    BIT_AND: function(a, b, ctx, ast) {
      a = some2nat(a, ast.a.type.main);
      b = some2nat(b, ast.b.type.main);
      return "bitwise_and(" + a + ", " + b + ")";
    },
    BIT_OR: function(a, b, ctx, ast) {
      a = some2nat(a, ast.a.type.main);
      b = some2nat(b, ast.b.type.main);
      return "bitwise_or(" + a + ", " + b + ")";
    },
    BIT_XOR: function(a, b, ctx, ast) {
      a = some2nat(a, ast.a.type.main);
      b = some2nat(b, ast.b.type.main);
      return "bitwise_xor(" + a + ", " + b + ")";
    },
    SHR: function(a, b, ctx, ast) {
      a = some2nat(a, ast.a.type.main);
      b = some2nat(b, ast.b.type.main);
      return "bitwise_lsr(" + a + ", " + b + ")";
    },
    SHL: function(a, b, ctx, ast) {
      a = some2nat(a, ast.a.type.main);
      b = some2nat(b, ast.b.type.main);
      return "bitwise_lsl(" + a + ", " + b + ")";
    },
    INDEX_ACCESS: function(a, b, ctx, ast) {
      var ret, val;
      return ret = ctx.lvalue ? "" + a + "[" + b + "]" : (val = type2default_value(ast.type, ctx), "(case " + a + "[" + b + "] of | None -> " + val + " | Some(x) -> x end)");
    },
    SUB: function(a, b, ctx, ast) {
      if (config.uint_type_hash.hasOwnProperty(ast.a.type.main) && config.uint_type_hash.hasOwnProperty(ast.b.type.main)) {
        return "abs(" + a + " - " + b + ")";
      } else {
        return "(" + a + " - " + b + ")";
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
        perr("WARNING BIT_NOT ( ~" + a + " ) translation can be incorrect");
        module.warning_counter++;
      }
      if (ast.type && config.uint_type_hash.hasOwnProperty(ast.type.main)) {
        return "abs(not (" + a + "))";
      } else {
        return "not (" + a + ")";
      }
    },
    BOOL_NOT: function(a) {
      return "not (" + a + ")";
    },
    RET_INC: function(a, ctx) {
      perr("RET_INC can have not fully correct implementation");
      module.warning_counter++;
      ctx.sink_list.push("" + a + " := " + a + " + 1");
      return ctx.trim_expr = "(" + a + " - 1)";
    },
    RET_DEC: function(a, ctx) {
      perr("RET_DEC can have not fully correct implementation");
      module.warning_counter++;
      ctx.sink_list.push("" + a + " := " + a + " - 1");
      return ctx.trim_expr = "(" + a + " + 1)";
    },
    INC_RET: function(a, ctx) {
      perr("INC_RET can have not fully correct implementation");
      module.warning_counter++;
      ctx.sink_list.push("" + a + " := " + a + " + 1");
      return ctx.trim_expr = "" + a;
    },
    DEC_RET: function(a, ctx) {
      perr("DEC_RET can have not fully correct implementation");
      module.warning_counter++;
      ctx.sink_list.push("" + a + " := " + a + " - 1");
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
    var is_enum, is_struct, key, list, name, nest, v, value, _i, _len, _ref, _ref1, _ref2, _ref3;
    switch (type.main) {
      case "bool":
        return "bool";
      case "Unit":
        return "Unit";
      case "string":
        return "string";
      case "address":
        return "address";
      case "built_in_op_list":
        return "list(operation)";
      case "array":
        nest = translate_type(type.nest_list[0], ctx);
        return "map(nat, " + nest + ")";
      case "tuple":
        list = [];
        _ref = type.nest_list;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          v = _ref[_i];
          list.push(translate_type(v, ctx));
        }
        return "(" + (list.join(' * ')) + ")";
      case "map":
        key = translate_type(type.nest_list[0], ctx);
        value = translate_type(type.nest_list[1], ctx);
        return "map(" + key + ", " + value + ")";
      case config.storage:
        return config.storage;
      case "contract":
        return "contract(" + type.val + ")";
      default:
        if ((_ref1 = ctx.type_decl_hash) != null ? _ref1.hasOwnProperty(type.main) : void 0) {
          name = type.main.replace(/\./g, "_");
          is_struct = ((ctx.current_class && ctx.type_decl_hash["" + ctx.current_class.name + "_" + name]) || ctx.type_decl_hash[name]) && ((_ref2 = ctx.type_decl_hash[name]) != null ? _ref2.constructor.name : void 0) === "Class_decl";
          is_enum = ((_ref3 = ctx.type_decl_hash[name]) != null ? _ref3.constructor.name : void 0) === "Enum_decl";
          if (ctx.current_class && is_struct) {
            name = "" + ctx.current_class.name + "_" + name;
          }
          if (name !== "router_enum" && is_enum) {
            name = "nat";
          }
          name = translate_var_name(name, ctx);
          return name;
        } else if (type.main.match(/^byte[s]?\d{0,2}$/)) {
          return "bytes";
        } else if (config.uint_type_hash.hasOwnProperty(type.main)) {
          return "nat";
        } else if (config.int_type_hash.hasOwnProperty(type.main)) {
          return "int";
        } else if (type.main.match(RegExp("^" + config.storage + "_"))) {
          return type.main;
        } else {
          perr("CRITICAL WARNING. translate_type unknown solidity type '" + type + "'");
          return "UNKNOWN_TYPE_" + type;
        }
    }
  };

  this.type2default_value = type2default_value = function(type, ctx) {
    var name, prefix, t;
    if (config.uint_type_hash.hasOwnProperty(type.main)) {
      return "0n";
    }
    if (config.int_type_hash.hasOwnProperty(type.main)) {
      return "0";
    }
    if (config.bytes_type_hash.hasOwnProperty(type.main)) {
      return "(\"00\": bytes)";
    }
    switch (type.main) {
      case "bool":
        return "False";
      case "address":
        return "(" + (JSON.stringify(config.default_address)) + " : address)";
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
        if (ctx.type_decl_hash.hasOwnProperty(type.main)) {
          t = ctx.type_decl_hash[type.main];
          if (t.constructor.name === "Enum_decl") {
            name = t.value_list[0].name;
            if (ctx.current_class.name && t.name !== "router_enum") {
              prefix = "";
              if (ctx.current_class.name) {
                prefix = "" + ctx.current_class.name + "_";
              }
              return "" + (translate_var_name(prefix + t.name)) + "_" + name;
            } else {
              return "" + name + "(unit)";
            }
          }
          if (t.constructor.name === "Class_decl") {
            name = type.main;
            if (ctx.current_class.name) {
              name = "" + ctx.current_class.name + "_" + type.main;
            }
            return "" + (translate_var_name(name)) + "_default";
          }
        }
        perr("CRITICAL WARNING. type2default_value unknown solidity type '" + type + "'");
        return "UNKNOWN_TYPE_DEFAULT_VALUE_" + type;
    }
  };

  translate_var_name = window.translate_var_name.translate_var_name;

  spec_id_trans_hash = {
    "now": "abs(now - (\"1970-01-01T00:00:00Z\": timestamp))",
    "msg.sender": "sender",
    "tx.origin": "source",
    "block.timestamp": "abs(now - (\"1970-01-01T00:00:00Z\": timestamp))",
    "msg.value": "(amount / 1mutez)",
    "abi.encodePacked": ""
  };

  bad_spec_id_trans_hash = {
    "block.coinbase": config.default_address,
    "block.difficulty": "0n",
    "block.gaslimit": "0n",
    "block.number": "0n",
    "msg.data": "(\"00\": bytes)",
    "msg.gas": "0n",
    "msg.sig": "(\"00\": bytes)",
    "tx.gasprice": "0n"
  };

  warning_once_hash = {};

  spec_id_translate = function(t, name) {
    var val;
    if (spec_id_trans_hash.hasOwnProperty(t)) {
      return spec_id_trans_hash[t];
    } else if (bad_spec_id_trans_hash.hasOwnProperty(t)) {
      val = bad_spec_id_trans_hash[t];
      if (!warning_once_hash.hasOwnProperty(t)) {
        warning_once_hash.hasOwnProperty[t] = true;
        perr("CRITICAL WARNING we don't have proper translation for ethereum '" + t + "', so it would be translated as '" + val + "'. That's incorrect");
      }
      return val;
    } else {
      return name;
    }
  };

  this.Gen_context = (function() {
    Gen_context.prototype.parent = null;

    Gen_context.prototype.next_gen = null;

    Gen_context.prototype.current_class = null;

    Gen_context.prototype.is_class_scope = false;

    Gen_context.prototype.lvalue = false;

    Gen_context.prototype.type_decl_hash = {};

    Gen_context.prototype.contract_var_hash = {};

    Gen_context.prototype.contract = false;

    Gen_context.prototype.trim_expr = "";

    Gen_context.prototype.storage_sink_list = {};

    Gen_context.prototype.sink_list = [];

    Gen_context.prototype.type_decl_sink_list = [];

    Gen_context.prototype.structs_default_list = [];

    Gen_context.prototype.enum_list = [];

    Gen_context.prototype.tmp_idx = 0;

    function Gen_context() {
      this.type_decl_hash = {};
      this.contract_var_hash = {};
      this.storage_sink_list = {};
      this.sink_list = [];
      this.type_decl_sink_list = [];
      this.structs_default_list = [];
      this.enum_list = [];
      this.contract = false;
    }

    Gen_context.prototype.mk_nest = function() {
      var t;
      t = new module.Gen_context;
      t.parent = this;
      t.current_class = this.current_class;
      obj_set(t.contract_var_hash, this.contract_var_hash);
      obj_set(t.type_decl_hash, this.type_decl_hash);
      t.type_decl_sink_list = this.type_decl_sink_list;
      t.structs_default_list = this.structs_default_list;
      t.enum_list = this.enum_list;
      t.contract = this.contract;
      return t;
    };

    return Gen_context;

  })();

  last_bracket_state = false;

  walk = function(root, ctx) {
    var a, arg, arg_jl, arg_list, args, aux, body, call_expr, case_scope, cb, chk_ret, code, cond, ctx_lvalue, decls, f, field_decl_jl, fn, i, idx, is_pure, is_state_in_main, jl, k, loc_code, msg, name, op, op_code, orig_ctx, prefix, ret, ret_jl, ret_type, scope, state_name, str, t, target_type, tmp_var, translated_type, type, type_decl, type_decl_jl, type_jl, type_list, v, val, _a, _aa, _ab, _ac, _ad, _ae, _af, _b, _base, _case, _i, _j, _k, _l, _len, _len1, _len10, _len11, _len12, _len13, _len14, _len15, _len16, _len17, _len18, _len19, _len2, _len20, _len21, _len22, _len3, _len4, _len5, _len6, _len7, _len8, _len9, _m, _n, _o, _p, _q, _r, _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref19, _ref2, _ref20, _ref21, _ref22, _ref23, _ref24, _ref25, _ref26, _ref27, _ref28, _ref29, _ref3, _ref30, _ref31, _ref32, _ref33, _ref34, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9, _s, _t, _u, _v, _var, _w, _x, _y, _z;
    last_bracket_state = false;
    switch (root.constructor.name) {
      case "Scope":
        switch (root.original_node_type) {
          case "SourceUnit":
            jl = [];
            _ref = root.list;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              v = _ref[_i];
              code = walk(v, ctx);
              if (code) {
                jl.push(code);
              }
            }
            if (ctx.structs_default_list.length) {
              jl.unshift("" + (join_list(ctx.structs_default_list)));
            }
            name = config.storage;
            jl.unshift("");
            if (Object.keys(ctx.storage_sink_list).length === 0) {
              jl.unshift("type " + name + " is unit;");
            } else {
              _ref1 = ctx.storage_sink_list;
              for (k in _ref1) {
                v = _ref1[k];
                if (v.length === 0) {
                  jl.unshift("type " + k + " is unit;");
                } else {
                  jl.unshift("type " + k + " is record\n  " + (join_list(v, '  ')) + "\nend;");
                }
              }
            }
            ctx.storage_sink_list = {};
            if (ctx.type_decl_sink_list.length) {
              type_decl_jl = [];
              _ref2 = ctx.type_decl_sink_list;
              for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
                type_decl = _ref2[_j];
                name = type_decl.name, field_decl_jl = type_decl.field_decl_jl;
                if (field_decl_jl.length === 0) {
                  type_decl_jl.push("type " + name + " is unit;");
                } else {
                  type_decl_jl.push("type " + name + " is record\n  " + (join_list(field_decl_jl, '  ')) + "\nend;\n");
                }
              }
              jl.unshift("" + (join_list(type_decl_jl)));
              if (ctx.enum_list.length) {
                jl.unshift("");
                jl.unshift("" + (join_list(ctx.enum_list)));
                ctx.enum_list = [];
              }
            }
            return join_list(jl, "");
          default:
            if (!root.original_node_type) {
              jl = [];
              _ref3 = root.list;
              for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
                v = _ref3[_k];
                code = walk(v, ctx);
                _ref4 = ctx.sink_list;
                for (_l = 0, _len3 = _ref4.length; _l < _len3; _l++) {
                  loc_code = _ref4[_l];
                  if (!/;$/.test(loc_code)) {
                    loc_code += ";";
                  }
                  jl.push(loc_code);
                }
                ctx.sink_list.clear();
                if (ctx.trim_expr === code) {
                  ctx.trim_expr = "";
                  continue;
                }
                if (code) {
                  if ((_ref5 = v.constructor.name) !== "Comment" && _ref5 !== "Scope") {
                    if (!/;$/.test(code)) {
                      code += ";";
                    }
                  }
                  jl.push(code);
                }
              }
              ret = jl.pop() || "";
              if (0 !== ret.indexOf("with")) {
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
              return "" + body + ret;
            } else {
              puts(root);
              throw new Error("Unknown root.original_node_type " + root.original_node_type);
            }
        }
        break;
      case "Var":
        name = root.name;
        if (name === "this") {
          return "";
        }
        if (root.name_translate) {
          name = translate_var_name(name, ctx);
        }
        if (ctx.contract_var_hash.hasOwnProperty(name)) {
          return "" + config.contract_storage + "." + name;
        } else {
          return spec_id_translate(root.name, name);
        }
        break;
      case "Const":
        if (!root.type) {
          puts(root);
          throw new Error("Can't type inference");
        }
        if (config.uint_type_hash.hasOwnProperty(root.type.main)) {
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
            perr("WARNING number constant passed to translation stage. That's type inference mistake");
            module.warning_counter++;
            return root.val;
          case "unsigned_number":
            return "" + root.val + "n";
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
            if (config.bytes_type_hash.hasOwnProperty(root.type.main)) {
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
                  return "bitwise_not(bitwise_xor(" + _a + ", " + _b + "))";
                case "=/=":
                  return "bitwise_xor(" + _a + ", " + _b + ")";
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
          perr("CRITICAL WARNING some of types in Field_access aren't resolved. This can cause invalid code generated");
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
              name = translate_var_name(root.name, ctx);
              if (((_ref6 = root.t) != null ? _ref6.name : void 0) !== "router_enum") {
                prefix = "";
                if (ctx.current_class.name) {
                  prefix = "" + ctx.current_class.name + "_";
                }
                return "" + (translate_var_name(prefix + root.t.name)) + "_" + root.name;
              } else {
                name = "" + (ctx.current_class.name.toUpperCase()) + "_" + name;
                return "" + name + "(unit)";
              }
          }
        }
        if (t === "") {
          return translate_var_name(root.name, ctx);
        }
        chk_ret = "" + t + "." + root.name;
        ret = "" + t + "." + (translate_var_name(root.name, ctx));
        if (root.t.constructor.name === "Var") {
          if ((_ref7 = ctx.type_decl_hash[root.t.name]) != null ? _ref7.is_library : void 0) {
            ret = translate_var_name("" + t + "_" + root.name, ctx);
          }
        }
        return spec_id_translate(chk_ret, ret);
      case "Fn_call":
        arg_list = [];
        _ref8 = root.arg_list;
        for (_m = 0, _len4 = _ref8.length; _m < _len4; _m++) {
          v = _ref8[_m];
          arg_list.push(walk(v, ctx));
        }
        if (root.fn.constructor.name === "Field_access") {
          t = walk(root.fn.t, ctx);
          if (root.fn.t.type) {
            switch (root.fn.t.type.main) {
              case "array":
                switch (root.fn.name) {
                  case "push":
                    tmp_var = "tmp_" + (ctx.tmp_idx++);
                    ctx.sink_list.push("const " + tmp_var + " : " + (translate_type(root.fn.t.type, ctx)) + " = " + t + ";");
                    return "" + tmp_var + "[size(" + tmp_var + ")] := " + arg_list[0];
                  default:
                    throw new Error("unknown array field function " + root.fn.name);
                }
                break;
              case "address":
                switch (root.fn.name) {
                  case "send":
                    perr("CRITICAL WARNING we don't check balance in send function. So runtime error will be ignored and no boolean return");
                    op_code = "transaction(unit, " + arg_list[0] + " * 1mutez, (get_contract(" + t + ") : contract(unit)))";
                    break;
                  case "transfer":
                    perr("CRITICAL WARNING we don't check balance in send function. So runtime error will be ignored and no throw");
                    op_code = "transaction(unit, " + arg_list[0] + " * 1mutez, (get_contract(" + t + ") : contract(unit)))";
                    break;
                  case "call":
                    perr("CRITICAL WARNING call function willl be conveerted into transaction, it doesn't return any value so your code may be wrong.");
                    perr("CRITICAL WARNING we don't check balance in call function. So runtime error will be ignored and no throw");
                    if (root.arg_list[0]) {
                      ret_type = translate_type(root.arg_list[0].type, ctx);
                      ret = arg_list[0];
                    } else {
                      ret_type = "Unit";
                      ret = "unit";
                    }
                    op_code = "transaction(" + ret + ", 0mutez, (get_contract(" + t + ") : contract(" + ret_type + ")))";
                    break;
                  case "delegatecall":
                    perr("CRITICAL WARNING we don't check balance in send function. So runtime error will be ignored and no throw");
                    op_code = "transaction(" + arg_list[1] + ", 1mutez, (get_contract(" + t + ") : contract(" + arg_list[0] + ")))";
                    break;
                  case "built_in_pure_callback":
                    ret_type = translate_type(root.arg_list[0].type, ctx);
                    ret = arg_list[0];
                    op_code = "transaction(" + ret + ", 0mutez, (get_contract(" + t + ") : contract(" + ret_type + ")))";
                    break;
                  default:
                    throw new Error("unknown address field " + root.fn.name);
                }
                return "var " + config.op_list + " : list(operation) := list " + op_code + " end";
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
              perr("CRITICAL WARNING " + root.fn.name + " hash function would be translated as sha_256. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#hash-functions");
              msg = arg_list[0];
              return "sha_256(" + msg + ")";
            case "selfdestruct":
              perr("CRITICAL WARNING " + root.fn.name + " is not implemented in ligo");
              msg = arg_list[0];
              return "selfdestruct(" + msg + ")";
            case "blockhash":
              msg = arg_list[0];
              perr("CRITICAL WARNING " + root.fn.name + " is not implemented in ligo. Replaced with (\"" + msg + "\" : bytes).");
              return "(\"00\" : bytes) (* Should be blockhash of " + msg + " *)";
            case "ripemd160":
              perr("CRITICAL WARNING " + root.fn.name + " hash function would be translated as blake2b. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#hash-functions");
              msg = arg_list[0];
              return "blake2b(" + msg + ")";
            case "ecrecover":
              perr("WARNING ecrecover function is not present in LIGO. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#hash-functions");
              fn = "ecrecover";
              break;
            case "@respond":
              perr("CRITICAL WARNING we don't check balance in send function. So runtime error will be ignored and no throw");
              return "var " + config.op_list + " : list(operation) := list transaction((" + (arg_list.join(' * ')) + "), 0mutez, " + config.receiver_name + ") end";
            default:
              name = root.fn.name;
              if (((_ref9 = ctx.current_class) != null ? _ref9.is_library : void 0) && ctx.current_class._prepared_field2type[name]) {
                name = "" + ctx.current_class.name + "_" + name;
                name = translate_var_name(name, ctx);
              } else {
                if (root.fn.name_translate) {
                  name = translate_var_name(name, ctx);
                }
              }
              fn = spec_id_translate(root.fn.name, name);
          }
        } else {
          fn = walk(root.fn, ctx);
        }
        if (((_ref10 = root.fn.type) != null ? _ref10.main : void 0) === "struct") {
          msg = "address contract to type_cast is not supported yet (we need enum action type for each contract)";
          perr("CRITICAL WARNING " + msg);
          fn = "(* LIGO unsupported *)" + fn;
        }
        is_pure = ((_ref11 = root.fn.type) != null ? _ref11.main : void 0) === "function2_pure";
        if (!is_pure) {
          arg_list.unshift(config.contract_storage);
        }
        if (arg_list.length === 0) {
          arg_list.push("unit");
        }
        type_jl = [];
        _ref14 = ((_ref12 = root.fn.type) != null ? (_ref13 = _ref12.nest_list[1]) != null ? _ref13.nest_list : void 0 : void 0) || [];
        for (_n = 0, _len5 = _ref14.length; _n < _len5; _n++) {
          v = _ref14[_n];
          type_jl.push(translate_type(v, ctx));
        }
        tmp_var = "tmp_" + (ctx.tmp_idx++);
        call_expr = "" + fn + "(" + (arg_list.join(', ')) + ")";
        if (is_pure && type_jl.length === 0) {
          perr("Bad call of pure function that returns nothing");
          type_jl.push("unit");
        }
        if (!root.left_unpack) {
          return "" + call_expr;
        } else {
          if (type_jl.length === 1) {
            return ctx.sink_list.push("const " + tmp_var + " : " + type_jl[0] + " = " + call_expr);
          } else {
            return ctx.sink_list.push("const " + tmp_var + " : (" + (type_jl.join(' * ')) + ") = " + call_expr);
          }
        }
        break;
      case "Struct_init":
        arg_list = [];
        for (i = _o = 0, _ref15 = root.val_list.length - 1; 0 <= _ref15 ? _o <= _ref15 : _o >= _ref15; i = 0 <= _ref15 ? ++_o : --_o) {
          arg_list.push("" + root.arg_names[i] + " = " + (walk(root.val_list[i], ctx)));
        }
        return "record [ " + (arg_list.join(";\n\t")) + " ]";
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
        } else if (target_type === "address" && t === "0") {
          return type2default_value(root.target_type, ctx);
        } else if (target_type === "bytes" && ((_ref16 = root.t.type) != null ? _ref16.main : void 0) === "string") {
          return "bytes_pack(" + t + ")";
        } else if (target_type === "address" && (t === "0x0" || t === "0")) {
          return "(" + (JSON.stringify(config.default_address)) + " : " + target_type + ")";
        } else {
          return "(" + t + " : " + target_type + ")";
        }
        break;
      case "Comment":
        if (root.can_skip) {
          return "";
        } else {
          return "(* " + root.text + " *)";
        }
        break;
      case "Continue":
        return "(* CRITICAL WARNING continue is not supported *)";
      case "Break":
        return "(* CRITICAL WARNING break is not supported *)";
      case "Var_decl":
        name = root.name;
        if (root.name_translate) {
          name = translate_var_name(name, ctx);
        }
        type = translate_type(root.type, ctx);
        prefix = "";
        if (ctx.is_class_scope) {
          if (root.special_type) {
            type = "" + ctx.current_class.name + "_" + root.type.main;
          }
          type = translate_var_name(type, ctx);
          ctx.contract_var_hash[name] = root;
          return "" + name + " : " + type + ";";
        } else {
          if (root.assign_value) {
            if (((_ref17 = root.assign_value) != null ? _ref17.constructor.name : void 0) === "Struct_init") {
              type = "" + ctx.current_class.name + "_" + root.type.main;
              type = translate_var_name(type, ctx);
            }
            val = walk(root.assign_value, ctx);
            if (config.bytes_type_hash.hasOwnProperty(root.type.main) && root.assign_value.type.main === "string" && root.assign_value.constructor.name === "Const") {
              val = string2bytes(root.assign_value.val);
            }
            if (config.bytes_type_hash.hasOwnProperty(root.type.main) && root.assign_value.type.main === "number" && root.assign_value.constructor.name === "Const") {
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
          for (idx = _p = 0, _len6 = _ref18.length; _p < _len6; idx = ++_p) {
            _var = _ref18[idx];
            name = _var.name;
            name = translate_var_name(name, ctx);
            type_list.push(type = translate_type(_var.type, ctx));
            jl.push("const " + name + " : " + type + " = " + tmp_var + "." + idx + ";");
          }
          return "const " + tmp_var + " : (" + (type_list.join(' * ')) + ") = " + val + ";\n" + (join_list(jl));
        } else {
          perr("CRITICAL WARNING Var_decl_multi with no assign value should be unreachable, but something goes wrong");
          perr("CRITICAL WARNING We can't guarantee that smart contract would work at all");
          module.warning_counter++;
          jl = [];
          _ref19 = root.list;
          for (_q = 0, _len7 = _ref19.length; _q < _len7; _q++) {
            _var = _ref19[_q];
            name = _var.name;
            name = translate_var_name(name, ctx);
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
        for (idx = _r = 0, _len8 = _ref20.length; _r < _len8; idx = ++_r) {
          v = _ref20[idx];
          jl.push(walk(v, ctx));
        }
        return "with (" + (jl.join(', ')) + ")";
      case "If":
        cond = walk(root.cond, ctx);
        if (!last_bracket_state) {
          cond = "(" + cond + ")";
        }
        t = walk(root.t, ctx);
        f = walk(root.f, ctx);
        return "if " + cond + " then " + t + " else " + f + ";";
      case "While":
        cond = walk(root.cond, ctx);
        if (!last_bracket_state) {
          cond = "(" + cond + ")";
        }
        scope = walk(root.scope, ctx);
        return "while " + cond + " " + scope + ";";
      case "PM_switch":
        cond = walk(root.cond, ctx);
        ctx = ctx.mk_nest();
        jl = [];
        _ref21 = root.scope.list;
        for (_s = 0, _len9 = _ref21.length; _s < _len9; _s++) {
          _case = _ref21[_s];
          case_scope = walk(_case.scope, ctx);
          if (/;$/.test(case_scope)) {
            case_scope = case_scope.slice(0, -1);
          }
          jl.push("| " + _case.struct_name + "(" + _case.var_decl.name + ") -> " + case_scope);
        }
        return "case " + cond + " of\n" + (join_list(jl, '')) + "\nend";
      case "Fn_decl_multiret":
        orig_ctx = ctx;
        ctx = ctx.mk_nest();
        arg_jl = [];
        _ref22 = root.arg_name_list;
        for (idx = _t = 0, _len10 = _ref22.length; _t < _len10; idx = ++_t) {
          v = _ref22[idx];
          is_state_in_main = root.name === "@main" && idx === 1;
          if (root.visibility !== 'pure' && idx > 0 && !is_state_in_main) {
            v = translate_var_name(v, ctx);
          }
          type = translate_type(root.type_i.nest_list[idx], ctx);
          arg_jl.push("const " + v + " : " + type);
        }
        if (arg_jl.length === 0) {
          arg_jl.push("const " + config.reserved + "__unit : unit");
        }
        ret_jl = [];
        _ref23 = root.type_o.nest_list;
        for (_u = 0, _len11 = _ref23.length; _u < _len11; _u++) {
          v = _ref23[_u];
          type = translate_type(v, ctx);
          ret_jl.push("" + type);
        }
        name = root.name;
        if ((_ref24 = orig_ctx.current_class) != null ? _ref24.is_library : void 0) {
          name = "" + orig_ctx.current_class.name + "_" + name;
        }
        name = translate_var_name(name, ctx);
        body = walk(root.scope, ctx);
        return "function " + name + " (" + (arg_jl.join('; ')) + ") : (" + (ret_jl.join(' * ')) + ") is\n  " + (make_tab(body, '  '));
      case "Class_decl":
        if (root.need_skip) {
          return "";
        }
        if (root.is_interface) {
          return "";
        }
        orig_ctx = ctx;
        prefix = "";
        if (ctx.parent && ctx.current_class && root.namespace_name) {
          ctx.parent.type_decl_hash["" + ctx.current_class.name + "." + root.name] = root;
          prefix = ctx.current_class.name;
        }
        ctx = ctx.mk_nest();
        ctx.current_class = root;
        ctx.is_class_scope = true;
        _ref25 = root.scope.list;
        for (_v = 0, _len12 = _ref25.length; _v < _len12; _v++) {
          v = _ref25[_v];
          switch (v.constructor.name) {
            case "Enum_decl":
            case "Class_decl":
              ctx.type_decl_hash[v.name] = v;
              break;
            case "PM_switch":
              _ref26 = root.scope.list;
              for (_w = 0, _len13 = _ref26.length; _w < _len13; _w++) {
                _case = _ref26[_w];
                ctx.type_decl_hash[_case.var_decl.type.main] = _case.var_decl;
              }
              break;
            default:
              "skip";
          }
        }
        field_decl_jl = [];
        _ref27 = root.scope.list;
        for (_x = 0, _len14 = _ref27.length; _x < _len14; _x++) {
          v = _ref27[_x];
          switch (v.constructor.name) {
            case "Var_decl":
              field_decl_jl.push(walk(v, ctx));
              break;
            case "Fn_decl_multiret":
              ctx.contract_var_hash[v.name] = v;
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
              ctx.sink_list.push(walk(v, ctx));
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
        for (_y = 0, _len15 = _ref28.length; _y < _len15; _y++) {
          v = _ref28[_y];
          switch (v.constructor.name) {
            case "Var_decl":
              "skip";
              break;
            case "Enum_decl":
              if (v.name !== "router_enum") {
                ctx.enum_list.push(walk(v, ctx));
              } else {
                jl.unshift(walk(v, ctx));
              }
              break;
            case "Fn_decl_multiret":
              jl.push(walk(v, ctx));
              break;
            case "Class_decl":
            case "Comment":
            case "Event_decl":
              "skip";
              break;
            default:
              throw new Error("unknown v.constructor.name " + v.constructor.name);
          }
        }
        if (root.is_contract || root.is_library) {
          state_name = config.storage;
          if (ctx.contract && ctx.contract !== root.name) {
            state_name = "" + state_name + "_" + root.name;
          }
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
            for (_z = 0, _len16 = _ref29.length; _z < _len16; _z++) {
              v = _ref29[_z];
              arg_list.push("" + v.name + " = " + (type2default_value(v.type, ctx)));
            }
            ctx.structs_default_list.push("const " + name + "_default : " + name + " = record [ " + (arg_list.join(";\n\t")) + " ];\n");
          }
          ctx.type_decl_sink_list.push({
            name: name,
            field_decl_jl: field_decl_jl
          });
        }
        return jl.join("\n\n");
      case "Enum_decl":
        jl = [];
        prefix = "";
        if (ctx.current_class.name && root.int_type) {
          prefix = "" + ctx.current_class.name + "_";
        }
        _ref30 = root.value_list;
        for (idx = _aa = 0, _len17 = _ref30.length; _aa < _len17; idx = ++_aa) {
          v = _ref30[idx];
          ctx.contract_var_hash[v.name] = v;
          aux = "";
          if (root.int_type) {
            if (v.type) {
              type = translate_type(v.type, ctx);
              aux = "" + (translate_var_name(type, ctx));
            }
            jl.push("const " + (translate_var_name(prefix + root.name)) + "_" + v.name + aux + " : nat = " + idx + "n;");
          } else {
            if (v.type) {
              aux = " of " + (translate_var_name(v.type.main.replace(/\./g, "_", ctx)));
            }
            jl.push("| " + (prefix.toUpperCase()) + v.name + aux);
          }
        }
        if (root.int_type) {
          return "" + (join_list(jl));
        } else {
          return "type " + (translate_var_name(prefix + root.name, ctx)) + " is\n  " + (join_list(jl, '  ')) + ";";
        }
        break;
      case "Ternary":
        cond = walk(root.cond, ctx);
        t = walk(root.t, ctx);
        f = walk(root.f, ctx);
        return "(case " + cond + " of | True -> " + t + " | False -> " + f + " end)";
      case "New":
        arg_list = [];
        _ref31 = root.arg_list;
        for (_ab = 0, _len18 = _ref31.length; _ab < _len18; _ab++) {
          v = _ref31[_ab];
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
        for (_ac = 0, _len19 = _ref32.length; _ac < _len19; _ac++) {
          v = _ref32[_ac];
          arg_list.push(walk(v, ctx));
        }
        return "(" + (arg_list.join(', ')) + ")";
      case "Array_init":
        arg_list = [];
        _ref33 = root.list;
        for (_ad = 0, _len20 = _ref33.length; _ad < _len20; _ad++) {
          v = _ref33[_ad];
          arg_list.push(walk(v, ctx));
        }
        decls = [];
        for (i = _ae = 0, _len21 = arg_list.length; _ae < _len21; i = ++_ae) {
          arg = arg_list[i];
          decls.push("" + i + "n -> " + arg + ";");
        }
        return "map\n  " + (join_list(decls, '  ')) + "\nend";
      case "Event_decl":
        args = [];
        _ref34 = root.arg_list;
        for (_af = 0, _len22 = _ref34.length; _af < _len22; _af++) {
          arg = _ref34[_af];
          name = translate_var_name(arg._name, ctx);
          type = translate_type(arg, ctx);
          args.push("" + name + " : " + type);
        }
        return "(* EventDefinition " + root.name + "(" + (args.join('; ')) + ") *)";
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
    var ctx;
    if (opt == null) {
      opt = {};
    }
    ctx = new module.Gen_context;
    ctx.next_gen = opt.next_gen;
    if (opt.contract) {
      ctx.contract = opt.contract;
    }
    return walk(root, ctx);
  };

}).call(window.translate_ligo = {});
