{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"
astBuilder = require "../ast_builder"

ERC20_METHODS_TOTAL = 6
ERC721_METHODS_TOTAL = 9  # cause safeTransferFrom is overloaded twice 

walk = (root, ctx)->
  switch root.constructor.name
    when "Class_decl"
      erc20_methods_count = 0
      erc721_methods_count = 0
      for entry in root.scope.list
        if entry.constructor.name == "Fn_decl_multiret"
          if entry.scope.list.length == 0 # only replace interfaces
            switch entry.name
              when "approve",\
                  "totalSupply",\
                  "balanceOf",\ 
                  "allowance",\ 
                  "transfer",\
                  "transferFrom"
                erc20_methods_count += 1
            
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

      # replace whole class (interface) declaration if we are converting it to FA anyway
      if erc20_methods_count == ERC20_METHODS_TOTAL
        ctx.erc20_name = root.name
        ret = new ast.Include
        ret.path = "interfaces/fa1.2.ligo"
        ret
      else if erc721_methods_count == ERC721_METHODS_TOTAL
        ctx.erc721_name = root.name
        ret = new ast.Include
        ret.path = "interfaces/fa2.ligo"
        ret
      else
        ctx.next_gen root, ctx
    else
      ctx.next_gen root, ctx


@erc_detector = (root, ctx)-> 
  ctx = obj_merge ctx, {
    walk,
    next_gen: default_walk
    erc20_name: null
    erc721_name: null
  }
  root = walk root, ctx
  return {root, ctx}