config = require "./config"
Type = require "type"
module = @

# Прим. Это система типов eth
# каждый язык, который хочет транслироваться должен сам решать как он будет преобразовывать эти типы в свои
@default_var_hash_gen = ()->
  {
    msg : (()->
      ret = new Type "struct"
      ret.field_hash["sender"] = new Type "address"
      # отдельная специальная олимпиада после type_inference делать еще один ast transform
      # найти всех использующих этот тип, и перевести каскадно на tez
      # ret.field_hash["value"] = new Type "tez"
      ret.field_hash["value"] = new Type "uint"
      ret
    )()
    now : new Type "uint"
    require : (()->
      # TODO new Type "function2<function<bool>,function<>>"
      ret = new Type "function2"
      ret.nest_list.push type_i = new Type "function"
      ret.nest_list.push type_o = new Type "function"
      type_i.nest_list.push "bool"
      ret
    )()
  }

array_field_hash =
  "length": new Type "uint"
  "push"  : (type)->
    ret = new Type "function2<function<>,function<>>"
    ret.nest_list[0].nest_list.push type
    ret

@default_type_hash_gen = ()->
  {
    bool    : true
    int     : true
    uint    : true
    array   : true
    string  : true
    address : true
  }

@bin_op_ret_type_hash_list = {}
@un_op_ret_type_hash_list = {
  MINUS : [
    ["int", "int"]
  ]
}
# ###################################################################################################
#    type table
# ###################################################################################################
for v in "ADD SUB MUL POW".split  /\s+/g
  @bin_op_ret_type_hash_list[v] = [
    ["uint", "uint", "uint"]
  ]
for v in "EQ NE GT LT GTE LTE".split  /\s+/g
  @bin_op_ret_type_hash_list[v] = [
    ["int", "int", "bool"]
    ["uint", "uint", "bool"]
  ]
# ###################################################################################################

class Ti_context
  parent    : null
  parent_fn : null
  var_hash  : {}
  type_hash : {}
  
  constructor:()->
    @var_hash = module.default_var_hash_gen()
    @type_hash= module.default_type_hash_gen()
  
  mk_nest : ()->
    ret = new Ti_context
    ret.parent = @
    ret.parent_fn = @parent_fn
    ret
  
  check_id : (id)->
    return ret if ret = @var_hash[id]
    if state_class = @type_hash[config.storage]
      return ret if ret = state_class._prepared_field2type[id]
      
    if @parent
      return @parent.check_id id
    throw new Error "can't find decl for id '#{id}'"
  
  check_type : (_type)->
    return ret if ret = @type_hash[_type]
    if @parent
      return @parent.check_type _type
    throw new Error "can't find type '#{_type}'"

class_prepare = (ctx, root)->
  ctx.type_hash[root.name] = root
  for v in root.scope.list
    switch v.constructor.name
      when "Var_decl"
        root._prepared_field2type[v.name] = v.type
      when "Fn_decl"
        # BUG внутри scope уже есть this и ему нужен тип...
        root._prepared_field2type[v.name] = v.type
  return

is_not_a_type = (type)->
  !type or type.main == "number"

@gen = (ast_tree, opt)->
  # phase 1 bottom-to-top walk + type reference
  walk = (root, ctx)->
    switch root.constructor.name
      # ###################################################################################################
      #    expr
      # ###################################################################################################
      when "Var"
        root.type = ctx.check_id root.name
      
      when "Const"
        root.type
      
      when "Bin_op"
        list = module.bin_op_ret_type_hash_list[root.op]
        a = (walk(root.a, ctx) or "").toString()
        b = (walk(root.b, ctx) or "").toString()
        
        found = false
        if list
          for tuple in list
            continue if tuple[0] != a
            continue if tuple[1] != b
            found = true
            root.type = new Type tuple[2]
        
        # extra cases
        if !found
          # may produce invalid result
          if root.op == "ASSIGN"
            root.type = root.a.type
            found = true
          else if root.op in ["EQ", "NE"]
            root.type = new Type "bool"
            found = true
          else if root.op == "INDEX_ACCESS"
            switch root.a.type.main
              when "string"
                root.type = new Type "string"
                found = true
              
              when "map"
                key = root.a.type.nest_list[0]
                if is_not_a_type root.b.type
                  root.b.type = key
                else if !key.cmp root.b.type
                  throw new Error("bad index access to '#{root.a.type}' with index '#{root.b.type}'")
                root.type = root.a.type.nest_list[1]
                found = true
              
              when "array"
                root.type = root.a.type.nest_list[0]
                found = true
              
              # when "hash"
                # root.type = root.a.type.nest_list[0]
                # found = true
              # when "hash_int"
                # root.type = root.a.type.nest_list[0]
                # found = true
        
        # NOTE only fire warning on bruteforce fail
        # if !found
          # perr "unknown bin_op=#{root.op} a=#{a} b=#{b}"
          # throw new Error "unknown bin_op=#{root.op} a=#{a} b=#{b}"
        root.type
      
      when "Un_op"
        list = module.un_op_ret_type_hash_list[root.op]
        a = (walk(root.a, ctx) or "").toString()
        found = false
        if list
          for tuple in list
            continue if tuple[0] != a
            found = true
            root.type = new Type tuple[1]
        if !found
          if root.op == "DELETE"
            if root.a.constructor.name == "Bin_op"
              if root.a.op == "INDEX_ACCESS"
                if root.a.a.type?.main == "array"
                  return
                if root.a.a.type?.main == "map"
                  return
        if !found
          throw new Error "unknown un_op=#{root.op} a=#{a}"
        root.type
      
      when "Field_access"
        root_type = walk(root.t, ctx)
        
        switch root_type.main
          when "array"
            field_hash = array_field_hash
          
          when "struct"
            field_hash = root_type.field_hash
          
          else
            class_decl = ctx.check_type root_type.main
            field_hash = class_decl._prepared_field2type
        
        if !field_type = field_hash[root.name]
          throw new Error "unknown field. '#{root.name}' at type '#{root_type}'. Allowed fields [#{Object.keys(field_hash).join ', '}]"
        
        # Я не понял зачем это
        # field_type = ast.type_actualize field_type, root.t.type
        if typeof field_type == "function"
          field_type = field_type root.t
        root.type = field_type
        root.type
      
      when "Fn_call"
        root_type = walk root.fn, ctx
        for arg in root.arg_list
          walk arg, ctx
        root.type = root_type.nest_list[0].nest_list[0]
      
      # ###################################################################################################
      #    stmt
      # ###################################################################################################
      when "Comment"
        null
      
      when "Var_decl"
        if root.assign_value
          walk root.assign_value, ctx
        ctx.var_hash[root.name] = root.type
        null
      
      when "Scope"
        ctx_nest = ctx.mk_nest()
        for v in root.list
          if v.constructor.name == "Class_decl"
            class_prepare ctx, v
        for v in root.list
          walk v, ctx_nest
        
        null
      
      when "Ret_multi"
        for v,idx in root.t_list
          if is_not_a_type v.type
            v.type = ctx.parent_fn.type_o.nest_list[idx]
          else
            expected = ctx.parent_fn.type_o.nest_list[idx]
            real = v.type
            if !expected.cmp real
              throw new Error "Ret_multi type mismatch expected=#{expected} real=#{real} @fn=#{ctx.parent_fn.name}"
          
          walk v, ctx
        null
      
      when "Class_decl"
        class_prepare ctx, root
        
        ctx_nest = ctx.mk_nest()
        # ctx_nest.var_hash["this"] = new Type root.name
        walk root.scope, ctx_nest
        root.type
      
      when "Fn_decl_multiret"
        complex_type = new Type "function2"
        complex_type.nest_list.push root.type_i
        complex_type.nest_list.push root.type_o
        ctx.var_hash[root.name] = complex_type
        ctx_nest = ctx.mk_nest()
        ctx_nest.parent_fn = root
        for name,k in root.arg_name_list
          type = root.type_i.nest_list[k]
          ctx_nest.var_hash[name] = type
        walk root.scope, ctx_nest
        root.type
      
      when "PM_switch"
        null
      
      # ###################################################################################################
      #    control flow
      # ###################################################################################################
      when "If"
        walk(root.cond, ctx)
        walk(root.t, ctx.mk_nest())
        walk(root.f, ctx.mk_nest())
        null
      
      when "While"
        walk root.cond, ctx.mk_nest()
        walk root.scope, ctx.mk_nest()
        null

      when "Enum_decl"
        null

      when "Type_cast"
        root.type
      
      when "Ternary"
        root.type
        
      else
        ### !pragma coverage-skip-block ###
        puts root
        throw new Error "ti phase 1 unknown node '#{root.constructor.name}'"
  walk ast_tree, new Ti_context
  
  # phase 2
  # iterable
  
  # TODO refactor. Stage 2 should reuse code from stage 1 but override some branches
  # Прим. спорно. В этом случае надо будет как-то информировать что это phase 2 иначе будет непонятно что привело к этому
  # возможно копипастить меньшее зло, чем потом дебажить непонятно как (т.к. сейчас p можно поставить на stage 1 и stage 2 раздельно)
  change_count = 0
  walk = (root, ctx)->
    switch root.constructor.name
      # ###################################################################################################
      #    expr
      # ###################################################################################################
      when "Var"
        root.type = ctx.check_id root.name
      
      when "Const"
        root.type
      
      when "Bin_op"
        bruteforce_a = is_not_a_type root.a.type
        bruteforce_b = is_not_a_type root.b.type
        if bruteforce_a or bruteforce_b
          list = module.bin_op_ret_type_hash_list[root.op]
          can_bruteforce = root.type?
          can_bruteforce and= bruteforce_a or bruteforce_b
          can_bruteforce and= list?
          
          switch root.op
            when "ASSIGN"
              if bruteforce_a and !bruteforce_b
                change_count++
                root.a.type = root.b.type
              else if !bruteforce_a and bruteforce_b
                change_count++
                root.b.type = root.a.type
            
            when "INDEX_ACCESS"
              # NOTE we can't infer type of a for now
              if !bruteforce_a and bruteforce_b
                switch root.a.type?.main
                  when "array"
                    root.b.type = new Type "uint"
                  
                  when "map"
                    root.b.type = root.a.type.nest_list[0]
                  
                  else
                    perr "can't type inference INDEX_ACCESS for #{root.a.type}"
            
            else
              if !list?
                perr "can't type inference bin_op='#{root.op}'"
          
          if can_bruteforce
            a_type_list = if bruteforce_a then [] else [root.a.type.toString()]
            b_type_list = if bruteforce_b then [] else [root.b.type.toString()]
            
            refined_list = []
            cmp_ret_type = root.type.toString()
            for v in list
              continue if cmp_ret_type != v[2]
              a_type_list.push v[0] if bruteforce_a
              b_type_list.push v[1] if bruteforce_b
              refined_list.push v
            
            candidate_list = []
            for a_type in a_type_list
              for b_type in b_type_list
                for pair in refined_list
                  [cmp_a_type, cmp_b_type] = pair
                  continue if a_type != cmp_a_type
                  continue if b_type != cmp_b_type
                  candidate_list.push pair
            if candidate_list.length == 1
              change_count++
              [a_type, b_type] = candidate_list[0]
              root.a.type = new Type a_type
              root.b.type = new Type b_type
            # else
              # p "candidate_list=#{candidate_list.length}"
        
        walk(root.a, ctx)
        walk(root.b, ctx)
        root.type
      
      when "Un_op"
        # TODO bruteforce
        walk(root.a, ctx)
        root.type
      
      when "Field_access"
        root_type = walk(root.t, ctx)
        
        
        switch root_type.main
          when "array"
            field_hash = array_field_hash
          
          when "struct"
            field_hash = root_type.field_hash
          
          else
            class_decl = ctx.check_type root_type.main
            field_hash = class_decl._prepared_field2type
        
        if !field_type = field_hash[root.name]
          throw new Error "unknown field. '#{root.name}' at type '#{root_type}'. Allowed fields [#{Object.keys(field_hash).join ', '}]"
        
        # Я не понял зачем это
        # field_type = ast.type_actualize field_type, root.t.type
        if typeof field_type == "function"
          field_type = field_type root.t
        root.type = field_type
        root.type
      
      when "Fn_call"
        root_type = walk root.fn, ctx
        for arg,i in root.arg_list
          walk arg, ctx
          expected_type = root.fn.type.nest_list[0].nest_list[i]
          if is_not_a_type arg.type
            change_count++
            arg.type = expected_type
        root.type = root_type.nest_list[0].nest_list[0]
      
      # ###################################################################################################
      #    stmt
      # ###################################################################################################
      when "Comment"
        null
      
      when "Var_decl"
        if root.assign_value
          if is_not_a_type root.assign_value.type
            change_count++
            root.assign_value.type = root.type
          walk root.assign_value, ctx
        ctx.var_hash[root.name] = root.type
        null
      
      when "Scope"
        ctx_nest = ctx.mk_nest()
        for v in root.list
          walk v, ctx_nest
        
        null
      
      when "Ret_multi"
        # TODO match return type
        for v in root.t_list
          walk v, ctx
        null
      
      when "Class_decl"
        class_prepare ctx, root
        
        ctx_nest = ctx.mk_nest()
        # ctx_nest.var_hash["this"] = new Type root.name
        walk root.scope, ctx_nest
        root.type
      
      when "Fn_decl_multiret"
        complex_type = new Type "function2"
        complex_type.nest_list.push root.type_i
        complex_type.nest_list.push root.type_o
        ctx.var_hash[root.name] = complex_type
        ctx_nest = ctx.mk_nest()
        for name,k in root.arg_name_list
          type = root.type_i.nest_list[k]
          ctx_nest.var_hash[name] = type
        walk root.scope, ctx_nest
        root.type
      
      when "PM_switch"
        null
      
      # ###################################################################################################
      #    control flow
      # ###################################################################################################
      when "If"
        walk(root.cond, ctx)
        walk(root.t, ctx.mk_nest())
        walk(root.f, ctx.mk_nest())
        null
      
      when "While"
        walk root.cond, ctx.mk_nest()
        walk root.scope, ctx.mk_nest()
        null

      when "Enum_decl"
        null

      when "Type_cast"
        root.type
      when "Ternary"
        root.type

      
      else
        ### !pragma coverage-skip-block ###
        puts root
        throw new Error "ti phase 2 unknown node '#{root.constructor.name}'"
  
  for i in [0 ... 100] # prevent infinite
    walk ast_tree, new Ti_context
    # p "phase 2 ti change_count=#{change_count}" # DEBUG
    break if change_count == 0
    change_count = 0
  
  ast_tree
