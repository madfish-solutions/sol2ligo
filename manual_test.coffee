#!/usr/bin/env iced
### !pragma coverage-skip-block ###
require 'fy'
fs = require 'fs'
import_resolver = require './src/import_resolver'
ast_gen = require './src/ast_gen'
argv = require('minimist')(process.argv.slice(2))

process_file = (file)->
  code = import_resolver file
  if argv.dump
    p code
    process.exit()
  
  ast = ast_gen code,
    suggest_solc_version : '0.4.26'
    silent: true
  if argv.ast_trans
    solidity_to_ast4gen = require './src/solidity_to_ast4gen'
    new_ast = solidity_to_ast4gen ast
    if new_ast.need_prevent_deploy
      p "FLAG need_prevent_deploy"
  
  return


if argv.all
  fs_tree = require './test/walk_fs_tree'
  fs_tree.walk "solidity_samples", (path)->
    puts path
    process_file path
else
  if !(file = argv._[0])? and !(file = argv.file)
    puts "usage ./manual_test.coffee <file.sol>"
    process.exit()
  
  process_file file
