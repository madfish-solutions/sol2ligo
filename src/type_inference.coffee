{ Ti_context } = require "./type_inference/common.coffee"

stage1 = require "./type_inference/stage1"
stage2 = require "./type_inference/stage2"

@gen = (ast_tree, opt)->
  stage1.walk ast_tree, new Ti_context
  
  for i in [0 ... 100] # prevent infinite
    ctx = new Ti_context
    stage2.walk ast_tree, ctx
    break if ctx.change_count == 0

  ast_tree
  # first_stage_walk : null
  # change_count : 0