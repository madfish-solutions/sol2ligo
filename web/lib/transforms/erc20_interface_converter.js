(function() {
  var ERC20_METHODS_TOTAL, Type, ast, astBuilder, callback_tx_node, config, default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  astBuilder = require("../ast_builder");

  ERC20_METHODS_TOTAL = 6;

  callback_tx_node = function(name, root, ctx) {
    var arg_list, cb_decl, cb_name, contract_type, return_callback, return_type;
    cb_name = name.substr(0, 1).toLowerCase() + name.substr(1) + "Callback";
    contract_type = new Type("contract");
    contract_type.val = "nat";
    return_callback = astBuilder.self_entrypoint("%" + cb_name, contract_type);
    if (!ctx.callbacks_to_declare_map.has(cb_name)) {
      return_type = root.fn.type.nest_list[ast.RETURN_VALUES].nest_list[ast.INPUT_ARGS];
      cb_decl = astBuilder.callback_declaration(name, return_type);
      ctx.callbacks_to_declare_map.set(cb_name, cb_decl);
    }
    arg_list = root.arg_list;
    arg_list.push(return_callback);
    return tx_node(root.fn.t, arg_list, name, ctx);
  };

  walk = function(root, ctx) {
    var comment, contract_type, entry, erc20_methods_count, idx, is_erc20, new_scope, _i, _j, _len, _len1, _ref, _ref1;
    switch (root.constructor.name) {
      case "Class_decl":
        erc20_methods_count = 0;
        _ref = root.scope.list;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          if (entry.constructor.name === "Fn_decl_multiret") {
            if (entry.scope.list.length !== 0) {
              switch (entry.name) {
                case "approve":
                case "totalSupply":
                case "balanceOf":
                case "allowance":
                case "transfer":
                case "transferFrom":
                  erc20_methods_count += 1;
              }
            }
          }
        }
        is_erc20 = erc20_methods_count === ERC20_METHODS_TOTAL;
        new_scope = [];
        if (is_erc20) {
          _ref1 = root.scope.list;
          for (idx = _j = 0, _len1 = _ref1.length; _j < _len1; idx = ++_j) {
            entry = _ref1[idx];
            if (entry.constructor.name === "Fn_decl_multiret") {
              switch (entry.name) {
                case "approve":
                  null;
                  break;
                case "totalSupply":
                  contract_type = new Type("contract");
                  contract_type.val = "nat";
                  entry.type_i.nest_list.push(contract_type);
                  entry.arg_name_list.push("callback");
                  entry.name = "getTotalSupply";
                  comment = new ast.Comment;
                  comment.text = "in Tezos `totalSupply` method should not return a value, but perform a transaction to the passed contract callback with a needed value";
                  new_scope.push(comment);
                  break;
                case "transferFrom":
                  comment = new ast.Comment;
                  comment.text = "`transferFrom` and `transfer` methods should merged into one in Tezos' FA1.2";
                  new_scope.push(comment);
                  break;
                case "transfer":
                  entry.type_i.nest_list.unshift(new Type("address"));
                  entry.arg_name_list.unshift("from");
                  break;
                case "balanceOf":
                  contract_type = new Type("contract");
                  contract_type.val = "nat";
                  entry.type_i.nest_list.push(contract_type);
                  entry.arg_name_list.push("callback");
                  entry.name = "getBalance";
                  comment = new ast.Comment;
                  comment.text = "in Tezos `balanceOf` method should not return a value, but perform a transaction to the passed contract callback with a needed value";
                  new_scope.push(comment);
                  break;
                case "allowance":
                  contract_type = new Type("contract");
                  contract_type.val = "nat";
                  entry.type_i.nest_list.push(contract_type);
                  entry.arg_name_list.push("callback");
                  entry.name = "getAllowance";
                  comment = new ast.Comment;
                  comment.text = "in Tezos `allowance` method should not return a value, but perform a transaction to the passed contract callback with a needed value";
                  new_scope.push(comment);
              }
            }
            new_scope.push(entry);
          }
        }
        if (new_scope.length) {
          root.scope.list = new_scope;
        }
        return ctx.next_gen(root, ctx);
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.erc20_interface_converter = function(root, ctx) {
    var init_ctx;
    init_ctx = {
      walk: walk,
      next_gen: default_walk
    };
    return walk(root, obj_merge(init_ctx, ctx));
  };

}).call(window.require_register("./transforms/erc20_interface_converter"));
