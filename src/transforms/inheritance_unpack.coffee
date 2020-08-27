{ default_walk } = require "./default_walk"
Type = require "type"
ast = require "../ast"

walk = (root, ctx)->
  switch root.constructor.name
    when "Fn_call"
      if root.fn.constructor.name == "Field_access"
        if root.fn.t.constructor.name == "Var"
          if root.fn.t.name == "super"
            if new_name = ctx.fn_dedupe_translate_map.get root.fn.name
              root.fn.name = new_name
      root
    
    when "Class_decl"
      ctx.fn_dedupe_translate_map = new Map() # old_name -> new_name
      is_constructor_name = (name)->
        name == "constructor" or name == root.name
      
      root = ctx.next_gen root, ctx
      ctx.class_map[root.name] = root # store unmodified
      return root if !root.inheritance_list.length # for coverage purposes
      
      # reverse order
      # near first
      # https://habr.com/ru/company/dsec/blog/347110/
      inheritance_apply_list = []
      inheritance_list = root.inheritance_list
      while inheritance_list.length
        need_lookup_list = []
        for i in [inheritance_list.length-1 .. 0] by -1
          v = inheritance_list[i]
          if !ctx.class_map.hasOwnProperty v.name
            throw new Error "can't find parent class #{v.name}"
          class_decl = ctx.class_map[v.name]
          
          class_decl.need_skip = true
          inheritance_apply_list.push v
          
          need_lookup_list.append class_decl.inheritance_list
        
        inheritance_list = need_lookup_list
      
      # keep unmodified stored in ctx.class_decl
      root = root.clone()
      fn_decl_set = new Set()
      pick_name = (start_name)->
        for i in [1 ... Infinity]
          try_name = "#{start_name}_#{i}"
          return try_name if !fn_decl_set.has try_name
        throw new Error "unreachable"
      
      add_fn_decl = (v)->
        if fn_decl_set.has v.name
          if ctx.fn_dedupe_translate_map.has v.name
            perr "WARNING (AST transform). Only 1 level of shadowing is allowed. Translated code will be not functional"
          else
            new_name = pick_name v.name
            ctx.fn_dedupe_translate_map.set v.name, new_name
            v.visibility = "internal"
            v.name = new_name
        else
          fn_decl_set.add v.name
        
        return
      
      for v in root.scope.list
        continue if v.constructor.name != "Fn_decl_multiret"
        add_fn_decl v
      
      class_set = new Set
      
      for parent in inheritance_apply_list
        if !ctx.class_map.hasOwnProperty parent.name
          throw new Error "can't find parent class #{parent.name}"
        class_decl = ctx.class_map[parent.name]
        
        continue if class_set.has parent.name
        class_set.add parent.name
        
        continue if class_decl.is_interface
        look_list = class_decl.scope.list
        
        need_constuctor = null
        # import all fn except constructor (rename constructor)
        for v in look_list
          continue if v.constructor.name != "Fn_decl_multiret"
          v = v.clone()
          if is_constructor_name v.name
            v.name = "#{parent.name}_constructor"
            v.visibility = "internal"
            need_constuctor = v
          
          add_fn_decl v
          root.scope.list.unshift v
          for old in root.scope.list
            walk old, ctx
        
        # import all vars (on top of fn)
        for v in look_list
          continue if v.constructor.name != "Var_decl"
          root.scope.list.unshift v.clone()
        
        # inject constructor call on top of my constructor (create my constructor if not exists)
        continue if !need_constuctor
        
        found_constructor = null
        for v in root.scope.list
          continue if v.constructor.name != "Fn_decl_multiret"
          continue if !is_constructor_name v.name
          found_constructor = v
          break
        
        # inject constructor call on top of my constructor (create my constructor if not exists)
        
        if !found_constructor
          root.scope.list.push found_constructor = new ast.Fn_decl_multiret
          found_constructor.name = "constructor"
          found_constructor.type_i = new Type "function"
          found_constructor.type_o = new Type "function"
        
        found_constructor.scope.list.unshift fn_call = new ast.Fn_call
        fn_call.fn = new ast.Var
        fn_call.fn.name = need_constuctor.name
        # TODO LATER use arg_list for calling parent constructor
        
      root
    else
      ctx.next_gen root, ctx
  

@inheritance_unpack = (root)->
  walk root, {walk, next_gen: default_walk, class_map: {}}