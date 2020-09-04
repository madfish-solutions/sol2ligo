(function() {
  var ERC20_METHODS_TOTAL, ERC721_METHODS_TOTAL, Type, ast, astBuilder, config, default_walk, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  astBuilder = require("../ast_builder");

  ERC20_METHODS_TOTAL = 6;

  ERC721_METHODS_TOTAL = 9;

  walk = function(root, ctx) {
    var entry, erc20_methods_count, erc721_methods_count, ret, _i, _len, _ref;
    switch (root.constructor.name) {
      case "Class_decl":
        erc20_methods_count = 0;
        erc721_methods_count = 0;
        _ref = root.scope.list;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          if (entry.constructor.name === "Fn_decl_multiret") {
            if (entry.scope.list.length === 0) {
              switch (entry.name) {
                case "approve":
                case "totalSupply":
                case "balanceOf":
                case "allowance":
                case "transfer":
                case "transferFrom":
                  erc20_methods_count += 1;
              }
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
        if (erc20_methods_count === ERC20_METHODS_TOTAL) {
          ctx.erc20_name = root.name;
          ret = new ast.Include;
          ret.path = "interfaces/fa1.2.ligo";
          return ret;
        } else if (erc721_methods_count === ERC721_METHODS_TOTAL) {
          ctx.erc721_name = root.name;
          ret = new ast.Include;
          ret.path = "interfaces/fa2.ligo";
          return ret;
        } else {
          return ctx.next_gen(root, ctx);
        }
        break;
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.erc_detector = function(root, ctx) {
    ctx = obj_merge(ctx, {
      walk: walk,
      next_gen: default_walk,
      erc20_name: null,
      erc721_name: null
    });
    root = walk(root, ctx);
    return {
      root: root,
      ctx: ctx
    };
  };

}).call(window.require_register("./transforms/erc_detector"));
