ast_gen         = require "./ast_gen"
ast_transform   = require "./ast_transform"
type_inference  = require("./type_inference").gen
translate       = require("./translate_ligo").gen
translate_ds    = require("./translate_ligo_default_state").gen

import_resolver     = require "./import_resolver"
solidity_to_ast4gen = require("./solidity_to_ast4gen").gen

compile = (sol_code) ->
  ast = ast_gen sol_code
  ast = solidity_to_ast4gen ast
  ast = ast_transform.pre_ti ast
  ast = type_inference ast
  ast = ast_transform.post_ti ast
  ligo_code = translate ast
  ligo_code

module.exports = { compile }
