assert              = require "assert"
ast_gen             = require("../src/ast_gen")
solidity_to_ast4gen = require("../src/solidity_to_ast4gen").gen
ast_transform       = require("../src/ast_transform")
type_inference      = require("../src/type_inference").gen
translate           = require("../src/translate_ligo").gen
fs                  = require "fs"
{execSync}          = require("child_process")

@translate_ligo_make_test = (text_i, text_o_expected, opt={})->
  opt.router ?= false
  solidity_ast = ast_gen text_i, silent:true
  ast = solidity_to_ast4gen solidity_ast
  assert !ast.need_prevent_deploy
  ast = ast_transform.ligo_pack ast, opt
  ast = type_inference ast
  text_o_real     = translate ast, opt
  text_o_expected = text_o_expected.trim()
  text_o_real     = text_o_real.trim()
  assert.strictEqual text_o_real, text_o_expected
  if process.argv.has "--ext_compiler"
    # strip known non-working code
    text_o_real = text_o_real.replace /\(\* EmitStatement \*\);/g, ""
    
    if opt.router
      fs.writeFileSync "test.ligo", text_o_real
    else
      fs.writeFileSync "test.ligo", """
      #{text_o_real}
      function main (const action : nat; const contractStorage : state) : (list(operation) * state) is
        block {
          const opList : list(operation) = (nil: list(operation));
        } with (opList, contractStorage);
      
      """
    
    if fs.existsSync "ligo_tmp_log"
      fs.unlinkSync "ligo_tmp_log"
    try
      execSync "ligo compile-contract test.ligo main > ./ligo_tmp_log", {stdio: "inherit"}
    catch err
      perr text_o_real
      perr fs.readFileSync "./ligo_tmp_log", "utf-8"
      throw err
      
  return
