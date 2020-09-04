(function() {
  var Type, ast, config, default_walk, translate_type, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  translate_type = require("../translate_ligo").translate_type;

  walk = function(root, ctx) {
    var idx, inject, last, state_name, v, _i, _len, _ref;
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
          inject.val = config.op_list;
        }
        return root;
      case "Fn_decl_multiret":
        ctx.returns_op_list = root.returns_op_list;
        ctx.uses_storage = root.uses_storage;
        ctx.modifies_storage = root.modifies_storage;
        root.scope = walk(root.scope, ctx);
        state_name = config.storage;
        if (root.uses_storage) {
          root.arg_name_list.unshift(config.contract_storage);
          root.type_i.nest_list.unshift(new Type(state_name));
        }
        if (root.modifies_storage) {
          root.type_o.nest_list.unshift(new Type(state_name));
        }
        if (root.returns_op_list) {
          root.arg_name_list.unshift(config.op_list);
          root.type_i.nest_list.unshift(new Type("built_in_op_list"));
          root.type_o.nest_list.unshift(new Type("built_in_op_list"));
        }
        last = root.scope.list.last();
        if (!last || last.constructor.name !== "Ret_multi") {
          last = new ast.Ret_multi;
          last = walk(last, ctx);
          root.scope.list.push(last);
        }
        last = root.scope.list.last();
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
