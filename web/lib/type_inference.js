(function() {
  var Ti_context, stage1, stage2;

  Ti_context = require("./type_inference/common").Ti_context;

  stage1 = require("./type_inference/stage1");

  stage2 = require("./type_inference/stage2");

  this.gen = function(ast_tree, opt) {
    var ctx, i, _i;
    ctx = new Ti_context;
    ctx.walk = stage1.walk;
    stage1.walk(ast_tree, ctx);
    for (i = _i = 0; _i < 100; i = ++_i) {
      ctx = new Ti_context;
      ctx.first_stage_walk = stage1.walk;
      ctx.walk = stage2.walk;
      stage2.walk(ast_tree, ctx);
      if (ctx.change_count === 0) {
        break;
      }
    }
    return ast_tree;
  };

}).call(window.require_register("./type_inference"));
