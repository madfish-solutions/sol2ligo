#!/usr/bin/env iced
### !pragma coverage-skip-block ###
require "fy"
fs = require "fs"
import_resolver = require "./src/import_resolver"
ast_gen         = require "./src/ast_gen"
ast_transform   = require("./src/ast_transform")
ast_transform_smartpy = require("./src/ast_transform_smartpy")
type_inference  = require("./src/type_inference").gen
translate       = require("./src/translate_ligo").gen
translate_smartpy = require("./src/translate_smartpy").gen
translate_ds    = require("./src/translate_ligo_default_state").gen
translate_ds_smartpy    = require("./src/translate_smartpy_default_state").gen
{execSync}      = require "child_process"
shell_escape    = require "shell-escape"
argv = require("minimist")(process.argv.slice(2))
argv.router ?= true
argv.contract ?= false
argv.disable_enums_to_nat ?= false

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
  
  if argv.full and !argv.smartpy
    opt = {
      router  : argv.router,
      contract : argv.contract
      replace_enums_by_nats: not argv.disable_enums_to_nat
    }
    new_ast = ast_transform.pre_ti new_ast, opt
    new_ast = type_inference new_ast
    new_ast = ast_transform.post_ti new_ast, opt
    code = translate new_ast, opt
    if argv.print
      puts code
    
    if argv.ds or argv.default_state
      ds_code = translate_ds new_ast
      if argv.print
        puts "default state:"
        puts ds_code
    
    # argv.ligo is old-style and deprecated
    if argv.ligo or argv.compile
      code = code.replace /\(\* EmitStatement \*\);/g, ""
      fs.writeFileSync "test.ligo", code
      if fs.existsSync "ligo_tmp.log"
        fs.unlinkSync "ligo_tmp.log"
      try
        execSync "ligo compile-contract test.ligo main > ./ligo_tmp.log", {stdio: "inherit"}
      catch err
        puts "ERROR"
        puts fs.readFileSync "./ligo_tmp.log", "utf-8"
  
  if argv.full and argv.smartpy
    new_ast = ast_transform_smartpy.pre_ti new_ast, opt
    new_ast = type_inference new_ast
    new_ast = ast_transform_smartpy.post_ti new_ast, opt
    code = translate_smartpy new_ast, opt
    if argv.print
      puts code 
    
    if argv.ds or argv.default_state or argv.compile
      ds_code = translate_ds_smartpy new_ast
      if argv.print
        puts "default state:"
        puts ds_code
    
    if argv.compile
      fs.writeFileSync "test.py", code
      if fs.existsSync "smartpy_tmp.log"
        fs.unlinkSync "smartpy_tmp.log"
      
      last_contract_name = "Main"
      for v in new_ast.list
        if v.constructor.name == "Class_decl" and v.is_last
          last_contract_name = v.name
      
      try
        execSync "~/smartpy-cli/SmartPy.sh compile test.py #{shell_escape [ds_code]} tmp > ./smartpy_tmp.log", {stdio: "inherit"}
      catch err
        puts "ERROR"
        puts fs.readFileSync "./smartpy_tmp.log", "utf-8"
    
  
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
