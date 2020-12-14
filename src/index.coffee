ast_gen         = require "./ast_gen"
ast_transform   = require "./ast_transform"
type_inference  = require("./type_inference").gen
translate       = require("./translate_ligo").gen
translate_ds    = require("./translate_ligo_default_state").gen

solidity_to_ast4gen = require("./solidity_to_ast4gen").gen

compile = (sol_code, opt = {}) ->
  ast = ast_gen sol_code, opt
  ast = solidity_to_ast4gen ast
  ast = ast_transform.pre_ti ast, opt
  ast = type_inference ast, opt
  ast = ast_transform.post_ti ast, opt
  ligo_code = translate ast, opt
  ligo_code

module.exports = { compile }
