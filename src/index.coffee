if window
  ast_gen       = window.ast_gen
else
  ast_gen       = require "./ast_gen"

ast_transform   = require "./ast_transform"
type_inference  = require("./type_inference").gen
translate       = require("./translate_ligo").gen
translate_ds    = require("./translate_ligo_default_state").gen
import_resolver = require "./import_resolver"

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
      errors.push if typeof e == "object" then e else message: e
  try
    ast = ast_gen sol_code, opt
    ast = solidity_to_ast4gen ast
    ast = ast_transform.pre_ti ast, opt
    ast = type_inference ast, opt
    ast = ast_transform.post_ti ast, opt
    ligo_code = translate ast, opt
    default_state = translate_ds ast
  catch e
    if window
      throw e
    else
      console.error e
  global.perr = perr_orig
  return {
    errors
    warnings
    ligo_code
    default_state
    prevent_deploy: if !ast? then true else !!ast.need_prevent_deploy
  }

# compile_for_browser = (sol_code, opt = {}) ->
#   {
#     result: "Here goes Ligo code",
#     result_default_state: "Here goes default state"
#   }

module.exports = {
  compile
  # compile_for_browser
  import_resolver
}
