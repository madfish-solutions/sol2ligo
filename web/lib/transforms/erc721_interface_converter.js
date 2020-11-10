(function() {
  var ERC721_METHODS_TOTAL, Type, ast, astBuilder, callback_tx_node, config, default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  astBuilder = require("../ast_builder");

  ERC721_METHODS_TOTAL = 9;

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
    var comment, entry, erc721_methods_count, idx, is_erc721, new_scope, type, _i, _j, _len, _len1, _ref, _ref1;
    switch (root.constructor.name) {
      case "Class_decl":
        erc721_methods_count = 0;
        _ref = root.scope.list;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          if (entry.constructor.name === "Fn_decl_multiret") {
            if (entry.scope.list.length !== 0) {
              switch (entry.name) {
                case "balanceOf":
                case "ownerOf":
                case "safeTransferFrom":
                case "transferFrom":
                case "approve":
                case "setApprovalForAll":
                case "getApproved":
                case "isApprovedForAll":
                  erc721_methods_count += 1;
              }
            }
          }
        }
        is_erc721 = erc721_methods_count === ERC721_METHODS_TOTAL;
        new_scope = [];
        if (is_erc721) {
          _ref1 = root.scope.list;
          for (idx = _j = 0, _len1 = _ref1.length; _j < _len1; idx = ++_j) {
            entry = _ref1[idx];
            if (entry.constructor.name === "Fn_decl_multiret") {
              switch (entry.name) {
                case "isApprovedForAll":
                case "getApproved":
                case "ownerOf":
                  comment = new ast.Comment;
                  comment.text = "" + entry.name + " is not present in FA2. Read more https://git.io/JJFij";
                  new_scope.push(comment);
                  break;
                case "transferFrom":
                case "safeTransferFrom":
                  comment = new ast.Comment;
                  comment.text = "`safeTransferFrom` and `transferFrom` methods should be merged into one in Tezos' FA2. Read more https://git.io/JJFij";
                  new_scope.push(comment);
                  entry.type_i.nest_list = [new Type("list<@transfer_michelson>")];
                  entry.arg_name_list = ["param"];
                  entry.name = entry.name.replace("From", "");
                  break;
                case "balanceOf":
                  type = new Type("@balance_of_param_michelson");
                  entry.type_i.nest_list = [type];
                  entry.arg_name_list = ["param"];
                  entry.name = "balance_of";
                  comment = new ast.Comment;
                  comment.text = "in Tezos `balanceOf` method should not return a value, but perform a transaction to the passed contract callback with a needed value";
                  new_scope.push(comment);
                  break;
                case "setApprovalForAll":
                case "approve":
                  entry.type_i.nest_list = [new Type("list<@update_operator_michelson>")];
                  entry.arg_name_list = ["param"];
                  entry.name = "update_operators__" + entry.name;
                  comment = new ast.Comment;
                  comment.text = "in Tezos approval methods are merged into one `Update_operators` method. You ought to handle Add_operator and Remove_operator params inside of it";
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

  this.erc721_interface_converter = function(root, ctx) {
    var init_ctx;
    init_ctx = {
      walk: walk,
      next_gen: default_walk
    };
    return walk(root, obj_merge(init_ctx, ctx));
  };

}).call(window.require_register("./transforms/erc721_interface_converter"));
