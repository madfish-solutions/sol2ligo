assert = require "assert"
ast_gen = require "../src/ast_gen"
import_resolver = require "../src/import_resolver"
fs_tree = require "./walk_fs_tree"
fs = require "fs"

describe "ast_gen section", ()->
  it "test contract 1", ()->
    @timeout 10000
    ast_gen """
    pragma solidity ^0.5.11;
    
    contract Summator {
      uint public value;
      
      function sum() public returns (uint) {
        uint x = 5;
        return value + x;
      }
    }
    """, silent:true
  
  it "test bad contract", ()->
    assert.throws ()->
      ast_gen """
      pragma solidity ^0.5.11;
      
      contract Summator {
        uint public value;
        
        function sum() public returns (uint) {
          qwer
          return value + x;
        }
      }
      """, silent:true
  
  if !process.argv.has "--skip_solc"
    describe "solidity samples", ()->
      global.solidity_source_to_ast_hash = {}
      fs_tree.walk "solidity_samples", (path)->
        global.solidity_source_to_ast_hash[path] = null
        it path, ()->
          # reasons for too long
          # 10 sec foc compiler load
          # 20 sec foc http(s) downloads
          @timeout 30000
          code = import_resolver path
          ast = ast_gen code, {
            silent : true
            suggest_solc_version : "0.4.26"
            debug : true
          }
          global.solidity_source_to_ast_hash[path] = ast
  