(function() {
  var Type, ast, astBuilder, config, declare_callback, default_walk, tx_node, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  astBuilder = require("../ast_builder");

  declare_callback = function(name, arg_type, ctx) {
    var cb_decl;
    if (!ctx.callbacks_to_declare_map.has(name)) {
      cb_decl = astBuilder.callback_declaration(name, arg_type);
      return ctx.callbacks_to_declare_map.set(name, cb_decl);
    }
  };

  tx_node = function(address_expr, arg_list, ctx) {
    var entrypoint, tx;
    address_expr = astBuilder.contract_addr_transform(address_expr);
    entrypoint = astBuilder.foreign_entrypoint(address_expr, "fa2_entry_points");
    tx = astBuilder.transaction(arg_list, entrypoint);
    return tx;
  };

  walk = function(root, ctx) {
    var action, action_enum, action_list, add, add_list, arg_type, args, block, call, comment, contract_type, dst, entry, name, param, request, ret, right_comb_action, right_comb_add, token_and_dst, transfer, transfers, tx, update, _i, _len, _ref, _ref1;
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
                ret.path = "interfaces/fa2.ligo";
                return ret;
            }
          }
        }
        ctx.callbacks_to_declare_map = new Map;
        root = ctx.next_gen(root, ctx);
        ctx.callbacks_to_declare_map.forEach(function(decl) {
          return root.scope.list.unshift(decl);
        });
        return root;
      case "Fn_decl_multiret":
        ctx.current_scope_ops_count = 0;
        return ctx.next_gen(root, ctx);
      case "Fn_call":
        if ((_ref1 = root.fn.t) != null ? _ref1.type : void 0) {
          switch (root.fn.t.type.main) {
            case "struct":
              switch (root.fn.name) {
                case "transferFrom":
                case "safeTransferFrom":
                  args = root.arg_list;
                  dst = new ast.Tuple;
                  dst.list.push(astBuilder.cast_to_address(args[1]));
                  dst.list.push(astBuilder.nat_literal(1));
                  token_and_dst = new ast.Tuple;
                  token_and_dst.list.push(args[2]);
                  token_and_dst.list.push(dst);
                  transfer = new ast.Tuple;
                  transfer.list.push(astBuilder.list_init([token_and_dst]));
                  transfer.list.push(astBuilder.cast_to_address(args[0]));
                  transfers = astBuilder.list_init([transfer]);
                  call = astBuilder.enum_val("@Transfer", [transfers]);
                  tx = tx_node(root.fn.t, [call], ctx);
                  if (root.fn.name === "safeTransferFrom") {
                    block = new ast.Scope;
                    block.need_nest = false;
                    block.list.push(root);
                    block.list.push(comment = new ast.Comment);
                    comment.text = "^ " + root.fn.name + " is not supported in LIGO. Read more https://git.io/JJFij ^";
                    return block;
                  } else {
                    return tx;
                  }
                  break;
                case "balanceOf":
                  name = "Balance_of";
                  args = root.arg_list;
                  param = new ast.Tuple;
                  param.list.push(astBuilder.nat_literal(0));
                  param.list.push(astBuilder.cast_to_address(args[0]));
                  arg_type = new Type("list<>");
                  arg_type.nest_list[0] = new Type("@balance_of_response_michelson");
                  contract_type = new Type("contract");
                  contract_type.nest_list.push(arg_type);
                  request = new ast.Tuple;
                  request.list.push(astBuilder.list_init([param]));
                  request.list.push(astBuilder.self_entrypoint("%" + name + "Callback", contract_type));
                  declare_callback(name, arg_type, ctx);
                  call = astBuilder.enum_val("@Balance_of", [request]);
                  return tx_node(root.fn.t, [call], ctx);
                case "approve":
                  param = new ast.Tuple;
                  param.list.push(astBuilder.tezos_var("sender"));
                  param.list.push(astBuilder.cast_to_address(root.arg_list[0]));
                  add = astBuilder.enum_val("@Add_operator", [param]);
                  right_comb_add = astBuilder.to_right_comb([add]);
                  add_list = astBuilder.list_init([right_comb_add]);
                  update = astBuilder.enum_val("@Update_operators", [add_list]);
                  return tx_node(root.fn.t, [update], ctx);
                case "setApprovalForAll":
                  args = root.arg_list;
                  param = new ast.Tuple;
                  param.list.push(astBuilder.tezos_var("sender"));
                  param.list.push(astBuilder.cast_to_address(root.arg_list[0]));
                  if (args[1].val === 'true') {
                    action = "@Add_operator";
                  } else {
                    action = "@Remove_operator";
                  }
                  action_enum = astBuilder.enum_val(action, [param]);
                  right_comb_action = astBuilder.to_right_comb([action_enum]);
                  action_list = astBuilder.list_init([right_comb_action]);
                  update = astBuilder.enum_val("@Update_operators", [action_list]);
                  return tx_node(root.fn.t, [update], ctx);
                case "isApprovedForAll":
                case "getApproved":
                  block = new ast.Scope;
                  block.need_nest = false;
                  block.list.push(root);
                  block.list.push(comment = new ast.Comment);
                  comment.text = "^ " + root.fn.name + " is not supported in LIGO. Read more https://git.io/JJFij ^";
                  return block;
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
