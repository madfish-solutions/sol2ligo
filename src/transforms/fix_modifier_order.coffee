{ default_walk } = require "./default_walk"
{ collect_fn_call } = require "./collect_fn_call"

do() =>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Class_decl"
        # phase 1 collect all functions (incl modifiers)
        # phase 2 collect usage: modifiers, just Fn_call
        # phase 3 check no loops
        # phase 4 perform reorder. Move declarations before usages
        
        for retry_count in [0 ... 5]
          if retry_count
            perr "NOTE method reorder requires additional attempt retry_count=#{retry_count}. That's not good, but we try resolve that"
          # phase 1 collect all functions (incl modifiers)
          fn_list = []
          for v in root.scope.list
            continue if  v.constructor.name != "Fn_decl_multiret"
            fn_list.push v
          
          fn_map = {}
          for fn in fn_list
            fn_map[fn.name] = fn
          
          # phase 2 collect usage: modifiers, just Fn_call
          fn_dep_map_map = {}
          for fn in fn_list
            fn_use_map = collect_fn_call fn
            fn_use_refined_map = {}
            for k,v of fn_use_map
              continue if !fn_map.hasOwnProperty k
              fn_use_refined_map[k] = v
            
            if fn_use_refined_map.hasOwnProperty fn.name
              delete fn_use_refined_map[fn.name]
              perr "WARNING (AST transform). We found that function #{fn.name} has self recursion. This will produce uncompilable target. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#self-recursion--function-calls"
            fn_dep_map_map[fn.name] = fn_use_refined_map
          
          # phase 3 check no loops
          # remove empty usage until nothing to remove left
          clone_fn_dep_map_map = deep_clone fn_dep_map_map
          fn_move_list = []
          for i in [0 ... 100] # hang protection
            change_count = 0
            
            fn_left_name_list = Object.keys clone_fn_dep_map_map
            for fn_name in fn_left_name_list
              if 0 == h_count clone_fn_dep_map_map[fn_name]
                change_count++
                use_list = []
                delete clone_fn_dep_map_map[fn_name]
                for k,v of clone_fn_dep_map_map
                  if v[fn_name]
                    delete v[fn_name]
                    use_list.push k
                
                if use_list.length
                  fn_move_list.push {
                    fn_name
                    use_list
                  }
            
            break if change_count == 0
          
          if 0 != h_count clone_fn_dep_map_map
            perr clone_fn_dep_map_map
            perr "WARNING (AST transform). Can't reorder methods. Loop detected. This will produce uncompilable target. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#self-recursion--function-calls"
            break
          
          break if fn_move_list.length == 0
          
          fn_move_list.reverse()
          
          change_count = 0
          # phase 4 perform reorder. Move declarations before usages
          for move_entity in fn_move_list
            {
              fn_name
              use_list
            } = move_entity
            min_idx = Infinity
            for name in use_list
              fn = fn_map[name]
              idx = root.scope.list.idx fn
              min_idx = Math.min min_idx, idx
            
            fn_decl = fn_map[fn_name]
            old_idx = root.scope.list.idx fn_decl
            if old_idx > min_idx
              # p "move #{fn_name} before #{root.scope.list[min_idx].name} #{old_idx} -> #{min_idx}" # DEBUG
              change_count++
              root.scope.list.remove_idx old_idx
              root.scope.list.insert_after min_idx-1, fn_decl
          break if change_count == 0
        
        ctx.next_gen root, ctx
      
      else
        ctx.next_gen root, ctx
    

  @fix_modifier_order = (root)->
    walk root, {walk, next_gen: default_walk}