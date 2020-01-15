assert              = require "assert"
ast_gen             = require("../src/ast_gen")
solidity_to_ast4gen = require("../src/solidity_to_ast4gen").gen
ast_transform       = require("../src/ast_transform")
type_inference      = require("../src/type_inference").gen
translate           = require("../src/translate_ligo").gen

@translate_ligo_make_test = (text_i, text_o_expected)->
  solidity_ast = ast_gen text_i, silent:true
  ast = solidity_to_ast4gen solidity_ast
  assert !ast.need_prevent_deploy
  ast = ast_transform.ligo_pack ast
  ast = type_inference ast
  text_o_real     = translate ast,
    router : false
  text_o_expected = text_o_expected.trim()
  text_o_real     = text_o_real.trim()
  assert.strictEqual text_o_real, text_o_expected
