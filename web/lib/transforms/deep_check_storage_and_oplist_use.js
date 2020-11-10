(function() {
  var Type, ast, config, default_walk, translate_type, translate_var_name, walk;

  default_walk = require("./default_walk").default_walk;

  config = require("../config");

  Type = window.Type;

  ast = require("../ast");

  translate_type = require("../translate_ligo").translate_type;

  translate_var_name = require("../translate_var_name").translate_var_name;

  walk = function(root, ctx) {
    var ctx_lvalue, found, idx, nest_fn, prev_class, synthetic_name, using, using_list, v, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _ref4, _type;
    switch (root.constructor.name) {
      case "Un_op":
        switch (root.op) {
          case "RET_INC":
          case "RET_DEC":
          case "INC_RET":
          case "DEC_RET":
            ctx_lvalue = clone(ctx);
            ctx_lvalue.lvalue = true;
            root.a = walk(root.a, ctx_lvalue);
            break;
          case "DELETE":
            if (root.a.constructor.name === "Bin_op" && root.a.op === "INDEX_ACCESS") {
              ctx_lvalue = clone(ctx);
              ctx_lvalue.lvalue = true;
              root.a.a = walk(root.a.a, ctx_lvalue);
            } else {
              perr("WARNING (AST transform). DELETE without INDEX_ACCESS can be handled improperly (extra state pass + return)");
              root.a = walk(root.a, ctx_lvalue);
            }
            break;
          default:
            root.a = walk(root.a, ctx);
        }
        return root;
      case "Bin_op":
        if (/^ASS/.test(root.op)) {
          ctx_lvalue = clone(ctx);
          ctx_lvalue.lvalue = true;
          root.a = walk(root.a, ctx_lvalue);
        } else {
          root.a = walk(root.a, ctx);
        }
        root.b = walk(root.b, ctx);
        return root;
      case "Var_decl":
        if (!ctx.loc_var_decl && !root.is_enum_decl && !root.is_const) {
          ctx.global_var_decl_map.set(root.name, true);
        }
        if (root.assign_value != null) {
          walk(root.assign_value, ctx);
        }
        return root;
      case "Var_decl_multi":
        if (!ctx.loc_var_decl && !root.is_enum_decl) {
          _ref = root.list;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            v = _ref[_i];
            ctx.global_var_decl_map.set(v.name, true);
          }
        }
        if (root.assign_value != null) {
          walk(root.assign_value, ctx);
        }
        return root;
      case "Var":
        if (ctx.global_var_decl_map.has(root.name)) {
          if (ctx.lvalue) {
            if (!ctx.modifies_storage.val) {
              ctx.modifies_storage.val = true;
              ctx.change_count.val++;
            }
          }
          if (!ctx.uses_storage.val) {
            ctx.uses_storage.val = true;
            ctx.change_count.val++;
          }
        }
        return root;
      case "Class_decl":
        prev_class = ctx.current_class;
        ctx.current_class = root;
        _ref1 = root.scope.list;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          v = _ref1[_j];
          walk(v, ctx);
        }
        ctx.current_class = prev_class;
        return root;
      case "Fn_call":
        if ((_ref2 = root.fn.name) === "transfer" || _ref2 === "send" || _ref2 === "call" || _ref2 === "built_in_pure_callback" || _ref2 === "delegatecall" || _ref2 === "transaction") {
          if (!ctx.returns_op_list.val) {
            ctx.returns_op_list.val = true;
            ctx.change_count.val++;
          }
        } else {
          switch (root.fn.constructor.name) {
            case "Var":
              if (nest_fn = ctx.fn_decl_map.get(root.fn.name)) {
                if (nest_fn.returns_op_list && !ctx.returns_op_list.val) {
                  ctx.returns_op_list.val = true;
                  ctx.change_count.val++;
                }
                if (nest_fn.uses_storage && !ctx.uses_storage.val) {
                  ctx.uses_storage.val = true;
                  ctx.change_count.val++;
                }
                if (nest_fn.modifies_storage && !ctx.modifies_storage.val) {
                  ctx.modifies_storage.val = true;
                  ctx.change_count.val++;
                }
                root.fn_decl = nest_fn;
              }
              break;
            case "Field_access":
              if (root.fn.t.constructor.name === "Var" && root.fn.t.name === "this") {
                if (nest_fn = ctx.fn_decl_map.get(root.fn.name)) {
                  if (nest_fn.returns_op_list && !ctx.returns_op_list.val) {
                    ctx.returns_op_list.val = true;
                    ctx.change_count.val++;
                  }
                  if (nest_fn.uses_storage && !ctx.uses_storage.val) {
                    ctx.uses_storage.val = true;
                    ctx.change_count.val++;
                  }
                  if (nest_fn.modifies_storage && !ctx.modifies_storage.val) {
                    ctx.modifies_storage.val = true;
                    ctx.change_count.val++;
                  }
                  root.fn_decl = nest_fn;
                } else if (ctx.global_var_decl_map.has(root.fn.name)) {
                  if (ctx.lvalue) {
                    if (!ctx.modifies_storage.val) {
                      ctx.modifies_storage.val = true;
                      ctx.change_count.val++;
                    }
                  }
                  if (!ctx.uses_storage.val) {
                    ctx.uses_storage.val = true;
                    ctx.change_count.val++;
                  }
                }
              } else if (root.fn.name === "push") {
                ctx_lvalue = clone(ctx);
                ctx_lvalue.lvalue = true;
                root.fn = walk(root.fn, ctx_lvalue);
              } else {
                found = false;
                _ref3 = ctx.current_class.using_map;
                for (_type in _ref3) {
                  using_list = _ref3[_type];
                  for (_k = 0, _len2 = using_list.length; _k < _len2; _k++) {
                    using = using_list[_k];
                    synthetic_name = translate_var_name("" + using + "_" + root.fn.name, null);
                    if (nest_fn = ctx.fn_decl_map.get(synthetic_name)) {
                      if (nest_fn.returns_op_list && !ctx.returns_op_list.val) {
                        ctx.returns_op_list.val = true;
                        ctx.change_count.val++;
                      }
                      if (nest_fn.uses_storage && !ctx.uses_storage.val) {
                        ctx.uses_storage.val = true;
                        ctx.change_count.val++;
                      }
                      if (nest_fn.modifies_storage && !ctx.modifies_storage.val) {
                        ctx.modifies_storage.val = true;
                        ctx.change_count.val++;
                      }
                      root.fn_decl = nest_fn;
                      root.is_fn_decl_from_using = true;
                      root.fn_name_using = synthetic_name;
                      found = true;
                      break;
                    }
                  }
                  if (found) {
                    break;
                  }
                }
              }
          }
        }
        _ref4 = root.arg_list;
        for (idx = _l = 0, _len3 = _ref4.length; _l < _len3; idx = ++_l) {
          v = _ref4[idx];
          root.arg_list[idx] = walk(v, ctx);
        }
        root.fn = walk(root.fn, ctx);
        return root;
      case "Fn_decl_multiret":
        ctx.fn_decl_map.set(root.name, root);
        ctx.returns_op_list = {
          val: root.returns_op_list
        };
        ctx.uses_storage = {
          val: root.uses_storage
        };
        ctx.modifies_storage = {
          val: root.modifies_storage
        };
        ctx.loc_var_decl = true;
        root.scope = walk(root.scope, ctx);
        root.returns_op_list = ctx.returns_op_list.val;
        root.uses_storage = ctx.uses_storage.val;
        root.modifies_storage = ctx.modifies_storage.val;
        root.returns_value = root.type_o.nest_list.length > 0;
        ctx.loc_var_decl = false;
        return root;
      default:
        return ctx.next_gen(root, ctx);
    }
  };

  this.deep_check_storage_and_oplist_use = function(root, ctx) {
    var prevent_loop, _i;
    ctx = {
      walk: walk,
      next_gen: default_walk,
      change_count: {
        val: 1
      },
      global_var_decl_map: new Map,
      fn_decl_map: new Map,
      current_class: null
    };
    for (prevent_loop = _i = 0; _i < 100; prevent_loop = ++_i) {
      if (ctx.change_count.val === 0) {
        break;
      }
      ctx.change_count.val = 0;
      root = walk(root, ctx);
    }
    if (ctx.change_count.val) {
      perr("WARNING (AST transform). prevent infinite loop trigger catched. Please notify developer about it with code example. Generated code can be invalid");
    }
    return root;
  };

}).call(window.require_register("./transforms/deep_check_storage_and_oplist_use"));
