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
      perr("WARNING ligo doesn't understand id for enum longer than 31 char so we trim " + name + " to " + new_name + ". Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#name-length-for-types");
      name = new_name;
    }
    return name;
  };

  walk = function(root, ctx) {
    var arg, arg_name, call, decl, func, idx, match_shoulder, record, ret, value, _case, _enum, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _main, _ref, _ref1, _ref2, _ref3, _ref4, _switch, _var;
    walk = ctx.walk;
    switch (root.constructor.name) {
      case "Class_decl":
        if (root.is_contract) {
          if (ctx.contract && root.name !== ctx.contract) {
            return ctx.next_gen(root, ctx);
          }
          _ref = ctx.router_func_list;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            func = _ref[_i];
            root.scope.list.push(record = new ast.Class_decl);
            record.name = func2args_struct(func.name);
            record.namespace_name = false;
            _ref1 = func.arg_name_list;
            for (idx = _j = 0, _len1 = _ref1.length; _j < _len1; idx = ++_j) {
              value = _ref1[idx];
              if (func.state_mutability !== "pure") {
                if (idx < 1) {
                  continue;
                }
              }
              record.scope.list.push(arg = new ast.Var_decl);
              arg.name = value;
              arg.type = func.type_i.nest_list[idx];
            }
            if (func.state_mutability === "pure") {
              record.scope.list.push(arg = new ast.Var_decl);
              arg.name = config.callback_address;
              arg.type = new Type("address");
            }
          }
          root.scope.list.push(_enum = new ast.Enum_decl);
          _enum.name = "router_enum";
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
          _main.type_i.nest_list.push(new Type("router_enum"));
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
            call.fn = new ast.Var;
            call.fn.left_unpack = true;
            call.fn.name = func.name;
            call.fn.type = new Type("function2");
            call.fn.type.nest_list[0] = func.type_i;
            call.fn.type.nest_list[1] = func.type_o;
            _ref4 = func.arg_name_list;
            for (idx = _m = 0, _len4 = _ref4.length; _m < _len4; idx = ++_m) {
              arg_name = _ref4[idx];
              if (arg_name === "self") {
                arg = new ast.Var;
                arg.name = arg_name;
                arg.type = new Type(config.storage);
                arg.name_translate = false;
                call.arg_list.push(arg);
              } else {
                arg = new ast.Var;
                arg.name = _case.var_decl.name;
                arg.type = _case.var_decl.type;
                call.arg_list.push(match_shoulder = new ast.Field_access);
                match_shoulder.name = arg_name;
                match_shoulder.t = arg;
              }
            }
            if (!func.returns_op_list && func.modifies_storage) {
              _case.scope.need_nest = false;
              _case.scope.list.push(ret = new ast.Tuple);
              ret.list.push(_var = new ast.Const);
              _var.type = new Type("built_in_op_list");
              ret.list.push(call);
            } else if (!func.modifies_storage) {
              _case.scope.need_nest = false;
              _case.scope.list.push(ret = new ast.Tuple);
              ret.list.push(call);
              ret.list.push(_var = new ast.Var);
              _var.type = new Type(config.storage);
              _var.name = config.contract_storage;
              _var.name_translate = false;
            } else {
              _case.scope.need_nest = false;
              _case.scope.list.push(call);
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
