(function() {
  var Type, ast, astBuilder, config, declare_callback, default_walk, tx_node, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  astBuilder = require("../ast_builder");

  declare_callback = function(name, fn, ctx) {
    var cb_decl, return_type;
    if (!ctx.callbacks_to_declare.hasOwnProperty(name)) {
      return_type = fn.type.nest_list[ast.RETURN_VALUES].nest_list[ast.INPUT_ARGS];
      cb_decl = astBuilder.callback_declaration(name, return_type);
      return ctx.callbacks_to_declare[name] = cb_decl;
    }
  };

  tx_node = function(address_expr, arg_list, name, ctx) {
    var entrypoint, tx;
    entrypoint = astBuilder.foreign_entrypoint(address_expr, name);
    tx = astBuilder.transaction(arg_list, entrypoint);
    return tx;
  };

  walk = function(root, ctx) {
    var action, arg_list_obj, arg_record, args, balance_request, decl, entry, enum_val, list, name, ret, tx, _i, _len, _ref, _ref1, _ref2;
    switch (root.constructor.name) {
      case "Class_decl":
        _ref = root.scope.list;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          if (entry.constructor.name === "Fn_decl_multiret") {
            switch (entry.name) {
              case "balanceOf":
              case "ownerOf":
              case "safeTransferFrom":
              case "transferFrom":
              case "approve":
              case "setApprovalForAll":
              case "getApproved":
              case "isApprovedForAll":
                ret = new ast.Include;
                ret.path = "fa2.ligo";
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
                case "transferFrom":
                  args = root.arg_list;
                  tx = astBuilder.struct_init({
                    to_: args[1],
                    token_id: args[2],
                    amount: astBuilder.nat_literal(1)
                  });
                  arg_record = astBuilder.struct_init({
                    from_: args[0],
                    txs: astBuilder.list_init([tx])
                  });
                  arg_list_obj = astBuilder.list_init([arg_record]);
                  args = root.arg_list;
                  return tx_node(root.fn.t, [arg_list_obj], "Transfer", ctx);
                case "balanceOf":
                  name = "Balance_of";
                  args = root.arg_list;
                  balance_request = astBuilder.struct_init({
                    owner: args[0],
                    token_id: root.fn.t
                  });
                  arg_record = astBuilder.struct_init({
                    requests: astBuilder.list_init([balance_request]),
                    callback: astBuilder.self_entrypoint("%" + name + "Callback")
                  });
                  declare_callback(name, root.fn, ctx);
                  return tx_node(root.fn.t, [arg_record], name, ctx);
                case "approve":
                  arg_record = astBuilder.struct_init({
                    owner: astBuilder.tezos_var("sender"),
                    operator: root.arg_list[0]
                  });
                  enum_val = astBuilder.enum_val("@Add_operator", [arg_record]);
                  list = astBuilder.list_init([enum_val]);
                  return tx_node(root.fn.t, [list], "Update_operators", ctx);
                case "setApprovalForAll":
                  args = root.arg_list;
                  arg_record = astBuilder.struct_init({
                    owner: astBuilder.tezos_var("sender"),
                    operator: args[0]
                  });
                  if (args[1].val === 'true') {
                    action = "@Add_operator";
                  } else {
                    action = "@Remove_operator";
                  }
                  enum_val = astBuilder.enum_val(action, [arg_record]);
                  list = astBuilder.list_init([enum_val]);
                  return tx_node(root.fn.t, [list], "Update_operators", ctx);
              }
          }
        }
        return ctx.next_gen(root, ctx);
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.erc721_converter = function(root, ctx) {
    return walk(root, ctx = obj_merge({
      walk: walk,
      next_gen: default_walk
    }, ctx));
  };

}).call(window.require_register("./transforms/erc721_converter"));
