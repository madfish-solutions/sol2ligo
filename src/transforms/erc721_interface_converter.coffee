{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"
astBuilder = require "../ast_builder"

ERC721_METHODS_TOTAL = 9  # cause safeTransferFrom is overloaded twice 

callback_tx_node = (name, root, ctx) ->
  cb_name = name.substr(0,1).toLowerCase() + name.substr(1) + "Callback"

  contract_type = new Type "contract"
  contract_type.val = "nat"
  return_callback = astBuilder.self_entrypoint("%" + cb_name, contract_type)

  if not ctx.callbacks_to_declare_map.has cb_name
    return_type = root.fn.type.nest_list[ast.RETURN_VALUES].nest_list[ast.INPUT_ARGS]
    cb_decl = astBuilder.callback_declaration name, return_type
    ctx.callbacks_to_declare_map.set cb_name, cb_decl

  arg_list = root.arg_list
  arg_list.push return_callback
  return tx_node(root.fn.t, arg_list, name, ctx)

walk = (root, ctx)->
  switch root.constructor.name
    when "Class_decl"
      erc721_methods_count = 0
      for entry in root.scope.list
        if entry.constructor.name == "Fn_decl_multiret"
          if entry.scope.list.length != 0 # only replace implementations
            switch entry.name
              when "balanceOf", \
                  "ownerOf", \
                  "safeTransferFrom", \
                  "transferFrom", \
                  "approve", \
                  "setApprovalForAll", \
                  "getApproved", \
                  "isApprovedForAll"
                erc721_methods_count += 1
            
      is_erc721 = erc721_methods_count == ERC721_METHODS_TOTAL
      new_scope = []
      if is_erc721
        for entry, idx in root.scope.list
          if entry.constructor.name == "Fn_decl_multiret"
            switch entry.name
              when "isApprovedForAll", \
                   "getApproved", \ 
                   "ownerOf"
                comment = new ast.Comment
                comment.text = "#{entry.name} is not present in FA2. Read more https://git.io/JJFij"
                new_scope.push comment

              when "transferFrom", "safeTransferFrom"
                comment = new ast.Comment
                comment.text = "`safeTransferFrom` and `transferFrom` methods should be merged into one in Tezos' FA2. Read more https://git.io/JJFij"
                new_scope.push comment

                entry.type_i.nest_list = [new Type "list<@transfer_michelson>"]
                entry.arg_name_list = ["param"]
                entry.name = entry.name.replace "From", ""

              when "balanceOf"
                type = new Type "@balance_of_param_michelson"
                entry.type_i.nest_list = [type]
                entry.arg_name_list = ["param"]
                entry.name = "balance_of"

                comment = new ast.Comment
                comment.text = "in Tezos `balanceOf` method should not return a value, but perform a transaction to the passed contract callback with a needed value"
                new_scope.push comment

              when "setApprovalForAll", "approve"
                entry.type_i.nest_list = [new Type "list<@update_operator_michelson>"]
                entry.arg_name_list = ["param"]
                entry.name = "update_operators__" + entry.name

                comment = new ast.Comment
                comment.text = "in Tezos approval methods are merged into one `Update_operators` method. You ought to handle Add_operator and Remove_operator params inside of it"
                new_scope.push comment


          new_scope.push entry

      if new_scope.length
        root.scope.list = new_scope

      ctx.next_gen root, ctx

    else
      ctx.next_gen root, ctx


@erc721_interface_converter = (root, ctx)-> 
  init_ctx = {
    walk,
    next_gen: default_walk,
  }
  walk root, obj_merge(init_ctx, ctx)