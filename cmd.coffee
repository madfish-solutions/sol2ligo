#!/usr/bin/env iced
### !pragma coverage-skip-block ###
require "fy"
fs = require "fs"
path = require "path"
import_resolver = require "./src/import_resolver"
ast_gen         = require "./src/ast_gen"
ast_transform   = require("./src/ast_transform")
type_inference  = require("./src/type_inference").gen
translate       = require("./src/translate_ligo").gen
translate_ds    = require("./src/translate_ligo_default_state").gen
{execSync}      = require "child_process"
# ###################################################################################################
argv = require("minimist")(process.argv.slice(2))
argv.router ?= true
argv.silent ?= false
argv.contract ?= false
argv.solc   ?= "0.4.26"
argv["solc-force"] ?= false
argv.ds     ?= false
argv.test   ?= false
argv.disable_enums_to_nat ?= false
argv.prefer_erc721 ?= false
argv.print_solidity_ast ?= false
argv.outfile ?= null
argv.dir ?= null
# ###################################################################################################

walkSync = (dir, filelist = []) -> 
  files = fs.readdirSync(dir)
  filelist = filelist || []
  files.forEach (file) ->
    p = path.join(dir, file)
    if fs.statSync(p).isDirectory()
      filelist = walkSync p, filelist
    else
      filelist.push(p)
  filelist

process_file = (file)->
  code = import_resolver file
  ast = ast_gen code,
    auto_version          : !argv["solc-force"]
    suggest_solc_version  : argv.solc
    silent                : argv.silent
    allow_download        : true

  if argv.print_solidity_ast
    puts ast
  
  solidity_to_ast4gen = require("./src/solidity_to_ast4gen").gen
  new_ast = solidity_to_ast4gen ast
  
  if new_ast.need_prevent_deploy
    puts "WARNING. Generated code is not correct. DO NOT deploy it without prior thorough checking!"
  
  outfile = path.parse(argv.outfile) if argv.outfile

  opt = {
      router  : argv.router,
      contract : argv.contract
      replace_enums_by_nats: not argv.disable_enums_to_nat
      prefer_erc721: argv.prefer_erc721
      keep_dir_structure: argv.dir != null
  }
  new_ast = ast_transform.pre_ti new_ast, opt
  new_ast = type_inference new_ast, opt
  new_ast = ast_transform.post_ti new_ast, opt

  code = translate new_ast, opt
  code += """\n (* this code is generated from #{file} by sol2ligo transpiler *)"""
  if argv.outfile
    name = outfile.name
    if outfile.ext
      name += outfile.ext
    else
      name += ".ligo"
    name = path.join outfile.dir, name
    if outfile.dir
      execSync "mkdir -p #{outfile.dir}"
    
    fs.writeFileSync name, code
  else
    puts code

  
  if argv.ds or argv.outfile
    ds_code = translate_ds new_ast
    if argv.outfile
      filepath = path.join outfile.dir, outfile.name + ".storage"
      fs.writeFileSync filepath, ds_code
    else
      puts """
        ----- BEGIN DEFAULT STATE -----
        #{ds_code}
        -----  END DEFAULT STATE  -----
        """
  
  if argv.test
    code = code.replace /\(\* EmitStatement \*\);/g, ""
    fs.writeFileSync "test.ligo", code
    if fs.existsSync "ligo_tmp.log"
      fs.unlinkSync "ligo_tmp.log"
    try
      execSync "ligo compile-contract test.ligo main > ./ligo_tmp.log", {stdio: "inherit"}
    catch err
      puts "ERROR"
      puts fs.readFileSync "./ligo_tmp.log", "utf-8"
  
  if new_ast.need_prevent_deploy
    puts "WARNING. Generated code is not correct. DO NOT deploy it without prior thorough checking!"
  
  return

if !(file = argv._[0])? and !(file = argv.file) and !(argv.dir)
  puts """
    usage ./cmd.coffee <file.sol>
      --router                generate router                                                  default: 1
      --silent                suppress errors                                                  default: false
      --solc                  suggested solc version if pragma is not specified                default: 0.4.26
      --solc-force            override solc version in pragma                                  default: false
      --ds                    print    default state. You need it for deploy                   default: false
      --test                  test compile with ligo (must be installed)                       default: false
      --disable_enums_to_nat  Do not transform enums to number constants                       default: false
      --prefer_erc721         Treat token interface as ERC721 over ERC20                       default: false
      --print_solidity_ast    Print parsed Solidity AST before transpiling                     default: false
      --keep_dir_structure    Preserve directory structure of original contracts               default: false
      --contract  <name>      Name of contract to generate router for                          default: <last contract>
      --outfile <name>        Name for output file. Adds `.ligo` if no extension specified     default: <prints to stdout>
      --dir <path>         Keep original directory structure and yield multiple ligo files  default: <single file to stdout>
        see test.ligo, test.pp.ligo and ligo_tmp.log
    """
  process.exit()

if argv.dir
  files = walkSync argv.dir
  dirname = path.basename argv.dir

  for file in files
    rel = path.relative argv.dir, file
    filepath = path.parse rel
    argv.outfile = path.join filepath.dir, filepath.name
    process_file file
else
  process_file file
