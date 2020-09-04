(function() {
  var collect_fn_call, default_walk;

  default_walk = require("./default_walk").default_walk;

  collect_fn_call = require("./collect_fn_call").collect_fn_call;

  (function(_this) {
    return (function() {
      var walk;
      walk = function(root, ctx) {
        var change_count, clone_fn_dep_map_map, fn, fn_decl, fn_dep_map_map, fn_left_name_list, fn_list, fn_map, fn_move_list, fn_name, fn_use_map, fn_use_refined_map, i, idx, k, min_idx, move_entity, name, old_idx, retry_count, use_list, v, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n, _o, _p, _ref;
        walk = ctx.walk;
        switch (root.constructor.name) {
          case "Class_decl":
            for (retry_count = _i = 0; _i < 5; retry_count = ++_i) {
              if (retry_count) {
                perr("NOTE method reorder requires additional attempt retry_count=" + retry_count + ". That's not good, but we try resolve that");
              }
              fn_list = [];
              _ref = root.scope.list;
              for (_j = 0, _len = _ref.length; _j < _len; _j++) {
                v = _ref[_j];
                if (v.constructor.name !== "Fn_decl_multiret") {
                  continue;
                }
                fn_list.push(v);
              }
              fn_map = {};
              for (_k = 0, _len1 = fn_list.length; _k < _len1; _k++) {
                fn = fn_list[_k];
                fn_map[fn.name] = fn;
              }
              fn_dep_map_map = {};
              for (_l = 0, _len2 = fn_list.length; _l < _len2; _l++) {
                fn = fn_list[_l];
                fn_use_map = collect_fn_call(fn);
                fn_use_refined_map = {};
                for (k in fn_use_map) {
                  v = fn_use_map[k];
                  if (!fn_map.hasOwnProperty(k)) {
                    continue;
                  }
                  fn_use_refined_map[k] = v;
                }
                if (fn_use_refined_map.hasOwnProperty(fn.name)) {
                  delete fn_use_refined_map[fn.name];
                  perr("WARNING (AST transform). We found that function " + fn.name + " has self recursion. This will produce uncompilable target. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#self-recursion--function-calls");
                }
                fn_dep_map_map[fn.name] = fn_use_refined_map;
              }
              clone_fn_dep_map_map = deep_clone(fn_dep_map_map);
              fn_move_list = [];
              for (i = _m = 0; _m < 100; i = ++_m) {
                change_count = 0;
                fn_left_name_list = Object.keys(clone_fn_dep_map_map);
                for (_n = 0, _len3 = fn_left_name_list.length; _n < _len3; _n++) {
                  fn_name = fn_left_name_list[_n];
                  if (0 === h_count(clone_fn_dep_map_map[fn_name])) {
                    change_count++;
                    use_list = [];
                    delete clone_fn_dep_map_map[fn_name];
                    for (k in clone_fn_dep_map_map) {
                      v = clone_fn_dep_map_map[k];
                      if (v[fn_name]) {
                        delete v[fn_name];
                        use_list.push(k);
                      }
                    }
                    if (use_list.length) {
                      fn_move_list.push({
                        fn_name: fn_name,
                        use_list: use_list
                      });
                    }
                  }
                }
                if (change_count === 0) {
                  break;
                }
              }
              if (0 !== h_count(clone_fn_dep_map_map)) {
                perr(clone_fn_dep_map_map);
                perr("WARNING (AST transform). Can't reorder methods. Loop detected. This will produce uncompilable target. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#self-recursion--function-calls");
                break;
              }
              if (fn_move_list.length === 0) {
                break;
              }
              fn_move_list.reverse();
              change_count = 0;
              for (_o = 0, _len4 = fn_move_list.length; _o < _len4; _o++) {
                move_entity = fn_move_list[_o];
                fn_name = move_entity.fn_name, use_list = move_entity.use_list;
                min_idx = Infinity;
                for (_p = 0, _len5 = use_list.length; _p < _len5; _p++) {
                  name = use_list[_p];
                  fn = fn_map[name];
                  idx = root.scope.list.idx(fn);
                  min_idx = Math.min(min_idx, idx);
                }
                fn_decl = fn_map[fn_name];
                old_idx = root.scope.list.idx(fn_decl);
                if (old_idx > min_idx) {
                  change_count++;
                  root.scope.list.remove_idx(old_idx);
                  root.scope.list.insert_after(min_idx - 1, fn_decl);
                }
              }
              if (change_count === 0) {
                break;
              }
            }
            return ctx.next_gen(root, ctx);
          default:
            return ctx.next_gen(root, ctx);
        }
      };
      return _this.fix_modifier_order = function(root) {
        return walk(root, {
          walk: walk,
          next_gen: default_walk
        });
      };
    });
  })(this)();

}).call(window.require_register("./transforms/fix_modifier_order"));
