(function() {
  var Type, ast, astBuilder, callback_declaration, callback_tx_node, config, default_walk, tx_node, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  astBuilder = require("../ast_builder");

  callback_declaration = function(name, arg_type) {
    var cb_decl, hint;
    cb_decl = new ast.Fn_decl_multiret;
    cb_decl.name = name + "Callback";
    cb_decl.type_i = new Type("function");
    cb_decl.type_o = new Type("function");
    cb_decl.arg_name_list.push("arg");
    cb_decl.type_i.nest_list.push(arg_type);
    hint = new ast.Comment;
    hint.text = "This method should handle return value of " + name + " of foreign contract. Read more at https://git.io/JfDxR";
    cb_decl.scope.list.push(hint);
    return cb_decl;
  };

  tx_node = function(address_expr, arg_list, name, ctx) {
    var entrypoint, tx;
    entrypoint = astBuilder.foreign_entrypoint(address_expr, name);
    tx = astBuilder.transaction(arg_list, entrypoint);
    return tx;
  };

  callback_tx_node = function(name, root, ctx) {
    var address_expr, arg_list, cb_decl, cb_name, entrypoint, return_callback, return_type, tx;
    cb_name = name + "Callback";
    return_callback = astBuilder.self_entrypoint("%" + cb_name);
    if (!ctx.callbacks_to_declare.hasOwnProperty(cb_name)) {
      return_type = root.fn.type.nest_list[ast.RETURN_VALUES].nest_list[ast.INPUT_ARGS];
      cb_decl = callback_declaration(name, return_type);
      ctx.callbacks_to_declare[cb_name] = cb_decl;
    }
    arg_list = root.arg_list;
    arg_list.push(return_callback);
    address_expr = root.fn.t;
    entrypoint = astBuilder.foreign_entrypoint(address_expr, name);
    tx = astBuilder.transaction(arg_list, entrypoint);
    return tx;
  };

  walk = function(root, ctx) {
    var arg_list, decl, entry, name, ret, sender, _i, _len, _ref, _ref1, _ref2;
    switch (root.constructor.name) {
      case "Class_decl":
        _ref = root.scope.list;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          if (entry.constructor.name === "Fn_decl_multiret") {
            switch (entry.name) {
              case "approve":
              case "totalSupply":
              case "balanceOf":
              case "allowance":
              case "transfer":
              case "transferFrom":
                ret = new ast.Include;
                ret.path = "fa1.2.ligo";
                return ret;
            }
          }
        }
        ctx.callbacks_to_declare = {};
        root = ctx.next_gen(root, ctx);
        _ref1 = ctx.callbacks_to_declare;
        for (name in _ref1) {
          decl = _ref1[name];
          root.scope.list.unshift(decl);
        }
        return root;
      case "Fn_decl_multiret":
        ctx.current_scope_ops_count = 0;
        return ctx.next_gen(root, ctx);
      case "Fn_call":
        if ((_ref2 = root.fn.t) != null ? _ref2.type : void 0) {
          switch (root.fn.t.type.main) {
            case "struct":
              switch (root.fn.name) {
                case "transfer":
                  sender = astBuilder.tezos_var("sender");
                  arg_list = root.arg_list;
                  arg_list.unshift(sender);
                  return tx_node(root.fn.t, arg_list, "Transfer", ctx);
                case "approve":
                  return tx_node(root.fn.t, root.arg_list, "Approve", ctx);
                case "transferFrom":
                  return tx_node(root.fn.t, root.arg_list, "Transfer", ctx);
                case "allowance":
                  return callback_tx_node("GetAllowance", root, ctx);
                case "balanceOf":
                  return callback_tx_node("GetBalance", root, ctx);
                case "totalSupply":
                  return callback_tx_node("GetTotalSupply", root, ctx);
              }
          }
        }
        return ctx.next_gen(root, ctx);
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.erc20_converter = function(root, ctx) {
    return walk(root, ctx = obj_merge({
      walk: walk,
      next_gen: default_walk
    }, ctx));
  };

}).call(window.require_register("./transforms/erc20_converter"));
