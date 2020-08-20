{ Ti_context } = require "./type_inference/common"

# type inference is split into two stages
# first one infers immediately obvious types
# second one brute forces the rest of them

stage1 = require "./type_inference/stage1"
stage2 = require "./type_inference/stage2"

@gen = (ast_tree, opt)->
  # I'm not a fan of passing `walk` into ctx, but can't come up with a better solution to make a singular call to first stage and immediately return back to stage 2 walk from there
  ctx = new Ti_context
  ctx.walk = stage1.walk
  stage1.walk ast_tree, ctx
  
  for i in [0 ... 100] # prevent infinite
    ctx = new Ti_context
    ctx.first_stage_walk = stage1.walk
    ctx.walk = stage2.walk
    stage2.walk ast_tree, ctx
    break if ctx.change_count == 0

  ast_tree