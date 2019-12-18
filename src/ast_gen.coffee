require 'fy'
setupMethods = require 'solc/wrapper'
release_hash = require("../solc-bin/bin/list.js").releases

solc_hash = {}


module.exports = (code, opt={})->
  {
    solc_version
    auto_version
  } = opt
  
  solc_full_name = null
  auto_version ?= true
  
  pick_version = (candidate_version)->
    if full_name = release_hash[candidate_version]
      solc_full_name = full_name
    else
      perr "unknown release version of solc #{candidate_version}; will take latest"
  
  if auto_version and !solc_version?
    # HACKY WAY
    header = code.split('\n')[0].trim()
    if reg_ret = /^pragma solidity \^?([.0-9]+);/.exec header
      pick_version reg_ret[1]
  else if solc_version
    pick_version solc_version
  
  solc_full_name ?= "soljson-latest.js"
  
  if !(solc = solc_hash[solc_full_name])?
    puts "loading solc #{solc_full_name}"
    solc_hash[solc_full_name] = solc = setupMethods(require("../solc-bin/bin/#{solc_full_name}"))
  
  input = {
      language: 'Solidity',
      sources: {
          'test.sol': {
              content: code
          }
      },
      settings: {
          
          outputSelection: {
              '*': {
                  '*': [ '*' ]
                  '' : ['ast']
              }
          }
      }
  }
  
  output = JSON.parse(solc.compile(JSON.stringify(input)))
  
  is_ok = true
  for error in output.errors or []
    if error.type == 'Warning'
      unless opt.silent
        p "WARNING", error
      continue
    is_ok = false
    perr error
  
  if !is_ok
    err = new Error "solc compiler error"
    err.__inject_error_list = output.errors
    throw err

  res = output.sources['test.sol'].ast
  if !res
    ### !pragma coverage-skip-block ###
    throw new Error "!res"
  res
