(function() {
  var Type, ast, config, default_walk, func2args_struct, func2struct, translate_var_name, walk;

  default_walk = require("./default_walk").default_walk;

  translate_var_name = require("../translate_var_name").translate_var_name;

  ast = require("../ast");

  Type = window.Type;

  config = require("../config");

  func2args_struct = function(name) {
    name = name + "_args";
    name = translate_var_name(name, null);
    return name;
  };

  func2struct = function(name) {
    var new_name;
    name = translate_var_name(name, null);
    name = name.capitalize();
    if (name.length > 31) {
      new_name = name.substr(0, 31);
      perr("WARNING (AST transform). Entrypoint names longer than 31 character are not supported in LIGO. We trimmed " + name + " to " + new_name + ". Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#name-length-for-types");
      name = new_name;
    }
    return name;
  };

  walk = function(root, ctx) {
    var access_gen, arg, arg_name, arg_num, call, comment, decl, func, idx, match_shoulder, ops_extract, proxy_call, record, ret, ret_tuple, ret_val, start, tmp, value, var_tmp, _case, _enum, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _main, _ref, _ref1, _ref2, _ref3, _ref4, _switch, _var;
    walk = ctx.walk;
    switch (root.constructor.name) {
      case "Class_decl":
        if (root.is_contract && root.is_last) {
          if (ctx.contract && root.name !== ctx.contract) {
            return ctx.next_gen(root, ctx);
          }
          _ref = ctx.router_func_list;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            func = _ref[_i];
            root.scope.list.push(record = new ast.Class_decl);
            record.name = func2args_struct(func.name);
            record.namespace_name = false;
            start = 0;
            if (func.uses_storage) {
              start++;
            }
            if (func.returns_op_list) {
              start++;
            }
            _ref1 = func.arg_name_list.slice(start);
            for (idx = _j = 0, _len1 = _ref1.length; _j < _len1; idx = ++_j) {
              value = _ref1[idx];
              record.scope.list.push(arg = new ast.Var_decl);
              arg.name = value;
              arg.type = func.type_i.nest_list[start + idx];
            }
            if (func.returns_value) {
              record.scope.list.push(arg = new ast.Var_decl);
              arg.name = config.callback_address;
              arg.type = new Type("address");
            }
          }
          root.scope.list.push(_enum = new ast.Enum_decl);
          _enum.name = config.router_enum;
          _ref2 = ctx.router_func_list;
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            func = _ref2[_k];
            _enum.value_list.push(decl = new ast.Var_decl);
            decl.name = func2struct(func.name);
            decl.type = new Type(func2args_struct(func.name));
          }
          root.scope.list.push(_main = new ast.Fn_decl_multiret);
          _main.name = "main";
          _main.type_i = new Type("function");
          _main.type_o = new Type("function");
          _main.arg_name_list.push("action");
          _main.type_i.nest_list.push(new Type(config.router_enum));
          _main.arg_name_list.push(config.contract_storage);
          _main.type_i.nest_list.push(new Type(config.storage));
          _main.type_o.nest_list.push(new Type("built_in_op_list"));
          _main.type_o.nest_list.push(new Type(config.storage));
          _main.scope.need_nest = false;
          _main.scope.list.push(ret = new ast.Tuple);
          ret.list.push(_switch = new ast.PM_switch);
          _switch.cond = new ast.Var;
          _switch.cond.name = "action";
          _switch.cond.type = new Type("string");
          _ref3 = ctx.router_func_list;
          for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
            func = _ref3[_l];
            _switch.scope.list.push(_case = new ast.PM_case);
            _case.struct_name = func2struct(func.name);
            _case.var_decl.name = "match_action";
            _case.var_decl.type = new Type(_case.struct_name);
            call = new ast.Fn_call;
            call.left_unpack = false;
            call.fn = new ast.Var;
            call.fn.name = func.name;
            call.fn.type = new Type("function2");
            call.fn.type.nest_list[0] = func.type_i;
            call.fn.type.nest_list[1] = func.type_o;
            _ref4 = func.arg_name_list;
            for (idx = _m = 0, _len4 = _ref4.length; _m < _len4; idx = ++_m) {
              arg_name = _ref4[idx];
              switch (arg_name) {
                case config.contract_storage:
                  arg = new ast.Var;
                  arg.name = arg_name;
                  arg.type = new Type(config.storage);
                  arg.name_translate = false;
                  call.arg_list.push(arg);
                  break;
                case config.op_list:
                  arg = new ast.Const;
                  arg.type = new Type("built_in_op_list");
                  call.arg_list.push(arg);
                  break;
                default:
                  arg = new ast.Var;
                  arg.name = _case.var_decl.name;
                  arg.type = _case.var_decl.type;
                  call.arg_list.push(match_shoulder = new ast.Field_access);
                  match_shoulder.name = arg_name;
                  match_shoulder.t = arg;
              }
            }
            if (!func.returns_value && (func.returns_op_list || func.modifies_storage)) {
              _case.scope.need_nest = false;
              if (func.returns_op_list && func.modifies_storage) {
                _case.scope.list.push(call);
              } else {
                _case.scope.list.push(ret_tuple = new ast.Tuple);
                if (!func.returns_op_list) {
                  ret_tuple.list.push(_var = new ast.Const);
                  _var.type = new Type("built_in_op_list");
                }
                ret_tuple.list.push(call);
                if (!func.modifies_storage) {
                  ret_tuple.list.push(_var = new ast.Var);
                  _var.type = new Type(config.storage);
                  _var.name = config.contract_storage;
                  _var.name_translate = false;
                }
              }
            } else {
              _case.scope.need_nest = true;
              if (!func.returns_value) {
                _case.scope.list.push(comment = new ast.Comment);
                comment.text = "This function does nothing, but it's present in router";
                perr("WARNING (AST transform). Function named " + func.name + " does nothing, but we put it in the router nonetheless");
              }
              _case.scope.list.push(tmp = new ast.Var_decl);
              tmp.name = "tmp";
              tmp.assign_value = call;
              tmp.type = func.type_o.clone();
              tmp.type.main = "tuple";
              ret_tuple = new ast.Tuple;
              arg_num = 0;
              access_gen = function() {
                var tmp_access, var_tmp;
                tmp_access = new ast.Field_access;
                tmp_access.type = tmp.type.nest_list[arg_num];
                tmp_access.name = arg_num.toString();
                arg_num++;
                tmp_access.t = var_tmp = new ast.Var;
                var_tmp.name = "tmp";
                return tmp_access;
              };
              if (+func.returns_op_list + +func.modifies_storage + +func.returns_value === 1) {
                access_gen = function() {
                  var var_tmp;
                  var_tmp = new ast.Var;
                  var_tmp.name = "tmp";
                  var_tmp.type = tmp.type.nest_list[0];
                  return var_tmp;
                };
              }
              if (func.returns_op_list) {
                ret_tuple.list.push(access_gen());
              } else {
                if (func.returns_value) {
                  ret_tuple.list.push(_var = new ast.Var);
                  _var.name = config.op_list;
                } else {
                  ret_tuple.list.push(_var = new ast.Const);
                  _var.type = new Type("built_in_op_list");
                }
              }
              if (func.modifies_storage) {
                ret_tuple.list.push(access_gen());
              } else {
                ret_tuple.list.push(_var = new ast.Var);
                _var.type = new Type(config.storage);
                _var.name = config.contract_storage;
                _var.name_translate = false;
              }
              arg_num = 0;
              ret_val = access_gen();
              if (func.returns_value) {
                _case.scope.list.push(proxy_call = new ast.Fn_call);
                proxy_call.fn = new ast.Var;
                if (func.returns_op_list) {
                  ops_extract = new ast.Field_access;
                  ops_extract.name = "0";
                  ops_extract.t = var_tmp = new ast.Var;
                  var_tmp.name = "tmp";
                  var_tmp.type = tmp.type.clone();
                  ops_extract.type = tmp.type.nest_list[0].clone();
                  proxy_call.fn.name = "@respond_append";
                  proxy_call.arg_list = [ops_extract, ret_val];
                } else {
                  proxy_call.fn.name = "@respond";
                  proxy_call.arg_list = [ret_val];
                }
              }
              _case.scope.list.push(ret = new ast.Ret_multi);
              ret.t_list.push(ret_tuple);
            }
          }
          return root;
        } else {
          return ctx.next_gen(root, ctx);
        }
        break;
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.add_router = function(root, ctx) {
    return walk(root, obj_merge({
      walk: walk,
      next_gen: default_walk
    }, ctx));
  };

}).call(window.require_register("./transforms/add_router"));
