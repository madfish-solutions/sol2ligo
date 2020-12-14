ast_gen         = require "./ast_gen"
ast_transform   = require "./ast_transform"
type_inference  = require("./type_inference").gen
translate       = require("./translate_ligo").gen
translate_ds    = require("./translate_ligo_default_state").gen

solidity_to_ast4gen = require("./solidity_to_ast4gen").gen

compile = (sol_code, opt = {}) ->
  error = ligo_code = default_state = ""
  perr_orig = perr
  global.perr = (e) ->
    error += JSON.stringify(e) + '\n'
  try
    ast = ast_gen sol_code, opt
    ast = solidity_to_ast4gen ast
    ast = ast_transform.pre_ti ast, opt
    ast = type_inference ast, opt
    ast = ast_transform.post_ti ast, opt
    ligo_code = translate ast, opt
    default_state = translate_ds ast
  catch e
    # do nothing
  global.perr = perr_orig
  return {
    error
    ligo_code
    default_state
    prevent_deploy: ast.need_prevent_deploy
  }

module.exports = { compile }
