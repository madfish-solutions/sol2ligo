assert              = require "assert"
config              = require "../src/config"
ast_gen             = require("../src/ast_gen")
solidity_to_ast4gen = require("../src/solidity_to_ast4gen").gen
ast_transform       = require("../src/ast_transform")
type_inference      = require("../src/type_inference").gen
translate           = require("../src/translate_ligo").gen
fs                  = require "fs"
{execSync}          = require("child_process")

cache_content_map = {}

@translate_ligo_make_test = (text_i, text_o_expected, opt={})->
  opt.router ?= false
  solidity_ast = ast_gen text_i, silent:true
  ast = solidity_to_ast4gen solidity_ast
  assert !ast.need_prevent_deploy unless opt.allow_need_prevent_deploy
  ast = ast_transform.pre_ti ast, opt
  ast = type_inference ast
  ast = ast_transform.post_ti ast, opt
  text_o_real     = translate ast, opt
  text_o_expected = text_o_expected.trim()
  text_o_real     = text_o_real.trim()
  text_o_expected = text_o_expected
    .replace /\bcontract_storage\b/g, config.contract_storage
    .replace /\bstate\b/g, config.storage
    .replace /\breceiver\b/g, config.receiver_name
    .replace /\bcallbackAddress\b/g, config.callback_address
    .replace /\btz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg\b/g, config.default_address
    .replace /\breserved__empty_state\b/g, config.empty_state
    .replace /\bopList\b/g, config.op_list
  
  # in case if we change contract_storage in future
  if config.contract_storage != "self"
    text_o_expected = text_o_expected
      .replace /\btest_reserved_long___self\b/g, "self"
    
  
  assert.strictEqual text_o_real, text_o_expected
  if process.env.EXT_COMPILER and !opt.no_ligo
    # strip known non-working code
    text_o_real = text_o_real.replace /\(\* EmitStatement \*\);/g, "const unused : nat = 0n;"
    
    if !opt.router
      text_o_real = """
      #{text_o_real}
      function main (const action : nat; const contract_storage : state) : (list(operation) * state) is
        block {
          const opList : list(operation) = (nil: list(operation));
        } with (opList, contract_storage);
      
      """
    
    if cache_content_map[text_o_real]
      puts "LIGO check skipped. Reason: content was already checked"
      return
    cache_content_map[text_o_real] = true
    
    fs.writeFileSync "test.ligo", text_o_real
    
    if fs.existsSync "ligo_tmp_.log"
      fs.unlinkSync "ligo_tmp.log"
    try
      execSync "ligo compile-contract test.ligo main > ./ligo_tmp.log", {stdio: "inherit"}
    catch err
      perr text_o_real
      perr fs.readFileSync "./ligo_tmp.log", "utf-8"
      throw err
      
  return

@translate_ligo = (text_i, opt={})->
  opt.router ?= true
  solidity_ast = ast_gen text_i, silent:true
  ast = solidity_to_ast4gen solidity_ast
  assert !ast.need_prevent_deploy unless opt.allow_need_prevent_deploy
  ast = ast_transform.pre_ti ast, opt
  ast = type_inference ast
  ast = ast_transform.post_ti ast, opt
  text_o_real = translate ast, opt
  text_o_real = text_o_real.trim()
  text_o_real

@tez_account_list = [
  "tz1NxxKP97Sv6rURCqyZN8TvfLsDaJJ1gRZL"
]

@async_assert_strict = (val_a, val_b, on_end)->
  try
    assert.strictEqual val_a, val_b
  catch err
    return on_end err
  on_end()
