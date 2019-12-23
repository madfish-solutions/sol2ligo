#!/usr/bin/env iced
### !pragma coverage-skip-block ###
require 'fy'
fs = require 'fs'
import_resolver = require './src/import_resolver'
ast_gen = require './src/ast_gen'
argv = require('minimist')(process.argv.slice(2))

if !(file = argv._[0])?
  puts "usage ./manual_test.coffee <file.sol>"
  process.exit()

code = import_resolver file
if argv.dump
  p code
  process.exit()

ast_gen code, silent: true
