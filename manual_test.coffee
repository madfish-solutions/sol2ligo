#!/usr/bin/env iced
### !pragma coverage-skip-block ###
require "fy"
fs = require "fs"
import_resolver = require "./src/import_resolver"
ast_gen         = require "./src/ast_gen"
ast_transform   = require("./src/ast_transform")
type_inference  = require("./src/type_inference").gen
translate       = require("./src/translate_ligo").gen
translate_ds    = require("./src/translate_ligo_default_state").gen
{execSync}      = require "child_process"
argv = require("minimist")(process.argv.slice(2))
argv.router ?= true

process_file = (file)->
  code = import_resolver file
  if argv.dump
    p code
    process.exit()
  
  ast = ast_gen code,
    suggest_solc_version : "0.4.26"
    silent: true
  
  if argv.ast_trans or argv.full
    solidity_to_ast4gen = require("./src/solidity_to_ast4gen").gen
    new_ast = solidity_to_ast4gen ast
    
    if new_ast.need_prevent_deploy
      p "FLAG need_prevent_deploy"
  
  if argv.full
    new_ast = ast_transform.ligo_pack new_ast, {
      router  : argv.router
      op_list : argv.router
    }
    new_ast = type_inference new_ast
    code = translate new_ast, {
      op_list : argv.router
    }
    if argv.print
      puts code
    
    if argv.ds or argv.default_state
      ds_code = translate_ds new_ast
      if argv.print
        puts "default state:"
        puts ds_code
    
    if argv.ligo
      fs.writeFileSync "test.ligo", code+"WTF"
      if fs.existsSync "ligo_tmp_log"
        fs.unlinkSync "ligo_tmp_log"
      try
        execSync "ligo compile-contract test.ligo main > ./ligo_tmp_log", {stdio: "inherit"}
      catch err
        puts "ERROR"
        puts fs.readFileSync "./ligo_tmp_log", "utf-8"
  
  return


if argv.all
  fs_tree = require "./test/walk_fs_tree"
  fs_tree.walk "solidity_samples", (path)->
    puts path
    process_file path
else
  if !(file = argv._[0])? and !(file = argv.file)
    puts "usage ./manual_test.coffee <file.sol>"
    process.exit()
  
  process_file file
