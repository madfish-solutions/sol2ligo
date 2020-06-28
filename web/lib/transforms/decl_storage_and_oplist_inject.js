(function() {
  var Type, ast, check_external_ops, config, default_walk, translate_type, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  translate_type = require("../translate_ligo").translate_type;

  check_external_ops = function(scope) {
    var is_external_call, v, _i, _len, _ref, _ref1;
    if (scope.constructor.name === "Scope") {
      _ref = scope.list;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        v = _ref[_i];
        if (v.constructor.name === "Fn_call" && v.fn.constructor.name === "Field_access") {
          is_external_call = (_ref1 = v.fn.name) === "transfer" || _ref1 === "send" || _ref1 === "call" || _ref1 === "built_in_pure_callback" || _ref1 === "delegatecall";
          if (is_external_call) {
            return true;
          }
        }
        if (v.constructor.name === "Scope") {
          if (check_external_ops(v)) {
            return true;
          }
        }
      }
      return false;
    }
  };

  walk = function(root, ctx) {
    var contract, f, idx, inject, l, last, ret_types, should_ret_args, state_name, t, type, v, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
    walk = ctx.walk;
    switch (root.constructor.name) {
      case "Ret_multi":
        _ref = root.t_list;
        for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
          v = _ref[idx];
          root.t_list[idx] = walk(v, ctx);
        }
        if (ctx.modifies_storage) {
          root.t_list.unshift(inject = new ast.Var);
          inject.name = config.contract_storage;
          inject.name_translate = false;
        }
        if (ctx.returns_op_list) {
          root.t_list.unshift(inject = new ast.Const);
          inject.type = new Type("built_in_op_list");
          if (ctx.has_op_list_decl) {
            inject.val = config.op_list;
          }
        }
        return root;
      case "If":
        l = root.t.list.last();
        if (l && l.constructor.name === "Ret_multi") {
          l = root.t.list.pop();
          root.t.list.push(inject = new ast.Fn_call);
          inject.fn = new ast.Var;
          inject.fn.name = "@respond";
          inject.arg_list = l.t_list.slice(1);
        }
        f = root.f.list.last();
        if (f && f.constructor.name === "Ret_multi") {
          f = root.f.list.pop();
          root.f.list.push(inject = new ast.Fn_call);
          inject.fn = new ast.Var;
          inject.fn.name = "@respond";
          inject.arg_list = f.t_list.slice(1);
        }
        ctx.has_op_list_decl = true;
        return root;
      case "Fn_decl_multiret":
        ctx.state_mutability = root.state_mutability;
        should_ret_args = (((_ref1 = root.state_mutability) === 'pure' || _ref1 === 'view') && root.visibility === 'private') || root.visibility === 'internal' || (root.state_mutability === 'pure' && root.visibility === 'public');
        ctx.returns_op_list = !should_ret_args || root.visibility === 'public';
        ctx.modifies_storage = (_ref2 = root.state_mutability) !== 'pure' && _ref2 !== 'view';
        root.scope = walk(root.scope, ctx);
        ctx.has_op_list_decl = check_external_ops(root.scope);
        state_name = config.storage;
        if (ctx.contract && ctx.contract !== root.contract_name) {
          state_name = "" + state_name + "_" + root.contract_name;
        }
        if (!should_ret_args && !ctx.modifies_storage) {
          root.arg_name_list.unshift(config.receiver_name);
          root.type_i.nest_list.unshift(contract = new Type("contract"));
          ret_types = [];
          _ref3 = root.type_o.nest_list;
          for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
            t = _ref3[_j];
            ret_types.push(translate_type(t, ctx));
          }
          type = ret_types.join(' * ');
          contract.name = config.receiver_name;
          contract.val = type;
          root.type_o.nest_list = [];
          last = root.scope.list.last();
          if (last && last.constructor.name === "Ret_multi") {
            last = root.scope.list.pop();
            root.scope.list.push(inject = new ast.Fn_call);
            inject.fn = new ast.Var;
            inject.fn.name = "@respond";
            inject.arg_list = last.t_list.slice(1);
            ctx.has_op_list_decl = true;
            last = new ast.Ret_multi;
            last = walk(last, ctx);
            root.scope.list.push(last);
          }
        }
        if (ctx.state_mutability !== 'pure') {
          root.arg_name_list.unshift(config.contract_storage);
          root.type_i.nest_list.unshift(new Type(state_name));
        }
        if (ctx.modifies_storage) {
          root.type_o.nest_list.unshift(new Type(state_name));
        }
        if (ctx.returns_op_list) {
          root.type_o.nest_list.unshift(new Type("built_in_op_list"));
        }
        if (root.type_o.nest_list.length === 0) {
          root.type_o.nest_list.unshift(new Type("Unit"));
        }
        last = root.scope.list.last();
        if (!last || last.constructor.name !== "Ret_multi") {
          last = new ast.Ret_multi;
          last = walk(last, ctx);
          root.scope.list.push(last);
        }
        last = root.scope.list.last();
        if (last && last.constructor.name === "Ret_multi" && last.t_list.length !== root.type_o.nest_list.length) {
          last = root.scope.list.pop();
          while (last.t_list.length > root.type_o.nest_list.length) {
            last.t_list.pop();
          }
          while (root.type_o.nest_list.length > last.t_list.length) {
            root.type_o.nest_list.pop();
          }
          root.scope.list.push(last);
        }
        root.returns_op_list = ctx.returns_op_list;
        root.modifies_storage = ctx.modifies_storage;
        return root;
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.decl_storage_and_oplist_inject = function(root, ctx) {
    return walk(root, obj_merge({
      walk: walk,
      next_gen: default_walk
    }));
  };

}).call(window.require_register("./transforms/decl_storage_and_oplist_inject"));
