(function() {
  var Type, array_side_unpack, ast, default_walk, flatten, ret_select;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  Type = window.Type;

  flatten = function(list) {
    var res_list, v, _i, _len;
    res_list = [];
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      v = list[_i];
      if (v instanceof Array) {
        res_list.append(flatten(v));
      } else {
        res_list.push(v);
      }
    }
    return res_list;
  };

  array_side_unpack = function(res_list, t) {
    var ret;
    if (t instanceof Array) {
      ret = t.pop();
      res_list.append(t);
      return ret;
    }
    return t;
  };

  ret_select = function(root, res_list) {
    if (res_list.length === 0) {
      return root;
    }
    res_list.push(root);
    return res_list;
  };

  (function(_this) {
    return (function() {
      var walk;
      walk = function(root, ctx) {
        var ctx_b, idx, is_left_to_right, res, res_list, v, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
        walk = ctx.walk;
        switch (root.constructor.name) {
          case "Scope":
            _ref = root.list;
            for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
              v = _ref[idx];
              root.list[idx] = walk(v, ctx);
            }
            root.list = flatten(root.list);
            return root;
          case "Un_op":
            res_list = [];
            root.a = array_side_unpack(res_list, walk(root.a, ctx));
            return ret_select(root, res_list);
          case "Bin_op":
            res_list = [];
            is_left_to_right = !((_ref1 = root.op) === "ASSIGN");
            if (root.op === "ASSIGN") {
              ctx_b = clone(ctx);
              ctx_b.rvalue = true;
            } else {
              ctx_b = ctx;
            }
            if (is_left_to_right) {
              root.a = array_side_unpack(res_list, walk(root.a, ctx));
              root.b = array_side_unpack(res_list, walk(root.b, ctx_b));
            } else {
              root.b = array_side_unpack(res_list, walk(root.b, ctx_b));
              root.a = array_side_unpack(res_list, walk(root.a, ctx));
            }
            if (root.op === "ASSIGN" && ctx.rvalue) {
              res_list.push(root);
              root = root.a;
            }
            return ret_select(root, res_list);
          case "Var_decl":
          case "Var_decl_multi":
            res_list = [];
            if (root.assign_value) {
              ctx = clone(ctx);
              ctx.rvalue = true;
              root.assign_value = array_side_unpack(res_list, walk(root.assign_value, ctx));
            }
            return ret_select(root, res_list);
          case "Field_access":
          case "Throw":
          case "Type_cast":
            res_list = [];
            if (root.t) {
              root.t = array_side_unpack(res_list, walk(root.t, ctx));
            }
            return ret_select(root, res_list);
          case "Fn_call":
            res_list = [];
            root.fn = array_side_unpack(res_list, walk(root.fn, ctx));
            _ref2 = root.arg_list;
            for (idx = _j = 0, _len1 = _ref2.length; _j < _len1; idx = ++_j) {
              v = _ref2[idx];
              root.arg_list[idx] = array_side_unpack(res_list, walk(v, ctx));
            }
            return ret_select(root, res_list);
          case "Struct_init":
            res_list = [];
            _ref3 = root.val_list;
            for (idx = _k = 0, _len2 = _ref3.length; _k < _len2; idx = ++_k) {
              v = _ref3[idx];
              root.val_list[idx] = array_side_unpack(res_list, walk(v, ctx));
            }
            return ret_select(root, res_list);
          case "New":
            res_list = [];
            _ref4 = root.arg_list;
            for (idx = _l = 0, _len3 = _ref4.length; _l < _len3; idx = ++_l) {
              v = _ref4[idx];
              root.arg_list[idx] = array_side_unpack(res_list, walk(v, ctx));
            }
            return ret_select(root, res_list);
          case "Ret_multi":
            res_list = [];
            _ref5 = root.t_list;
            for (idx = _m = 0, _len4 = _ref5.length; _m < _len4; idx = ++_m) {
              v = _ref5[idx];
              root.t_list[idx] = array_side_unpack(res_list, walk(v, ctx));
            }
            return ret_select(root, res_list);
          case "If":
          case "Ternary":
            res_list = [];
            root.cond = array_side_unpack(res_list, walk(root.cond, ctx));
            root.t = array_side_unpack(res_list, walk(root.t, ctx));
            root.f = array_side_unpack(res_list, walk(root.f, ctx));
            return ret_select(root, res_list);
          case "While":
            res_list = [];
            root.cond = array_side_unpack(res_list, walk(root.cond, ctx));
            root.scope = array_side_unpack(res_list, walk(root.scope, ctx));
            return ret_select(root, res_list);
          case "For3":
            res_list = [];
            if (root.init) {
              root.init = array_side_unpack(res_list, walk(root.init, ctx));
            }
            if (root.cond) {
              res = walk(root.cond, ctx);
              if (res instanceof Array) {
                perr("WARNING (AST transform). Chained assignment in a for condition is not supported; prevent_deploy flag raised.");
                ctx.need_prevent_deploy_obj.value = true;
              } else {
                root.cond = res;
              }
            }
            if (root.iter) {
              res = walk(root.iter, ctx);
              if (res instanceof Array) {
                perr("WARNING (AST transform). Chained assignment in a for iterator is not supported; prevent_deploy flag raised.");
                ctx.need_prevent_deploy_obj.value = true;
              } else {
                root.iter = res;
              }
            }
            root.scope = walk(root.scope, ctx);
            return ret_select(root, res_list);
          case "Tuple":
          case "Array_init":
            res_list = [];
            _ref6 = root.list;
            for (idx = _n = 0, _len5 = _ref6.length; _n < _len5; idx = ++_n) {
              v = _ref6[idx];
              root.list[idx] = array_side_unpack(res_list, walk(v, ctx));
            }
            return ret_select(root, res_list);
          default:
            return ctx.next_gen(root, ctx);
        }
      };
      return _this.split_chain_assignment = function(root) {
        var ctx;
        ctx = {
          walk: walk,
          next_gen: default_walk,
          need_prevent_deploy_obj: {
            value: false
          }
        };
        walk(root, ctx);
        if (ctx.need_prevent_deploy_obj.value) {
          root.need_prevent_deploy = true;
        }
        return root;
      };
    });
  })(this)();

}).call(window.require_register("./transforms/split_chain_assignment"));
