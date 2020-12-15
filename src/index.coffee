ast_gen         = require "./ast_gen"
ast_transform   = require "./ast_transform"
type_inference  = require("./type_inference").gen
translate       = require("./translate_ligo").gen
translate_ds    = require("./translate_ligo_default_state").gen

solidity_to_ast4gen = require("./solidity_to_ast4gen").gen

compile = (sol_code, opt = {}) ->
  ligo_code = default_state = ""
  errors = []
  warnings = []
  perr_orig = perr
  global.perr = (e) ->
    if (e.startsWith? "WARNING") or (e.startsWith? "NOTE")
      warnings.push e
    else
      errors.push e
  try
    ast = ast_gen sol_code, opt
    ast = solidity_to_ast4gen ast
    ast = ast_transform.pre_ti ast, opt
    ast = type_inference ast, opt
    ast = ast_transform.post_ti ast, opt
    ligo_code = translate ast, opt
    default_state = translate_ds ast
  catch e
    console.error e
  global.perr = perr_orig
  return {
    errors
    warnings
    ligo_code
    default_state
    prevent_deploy: ast?.need_prevent_deploy
  }

module.exports = { compile }
