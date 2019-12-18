assert = require 'assert'
ast_gen = require '../src/ast_gen'
fs_tree = require './walk_fs_tree'
fs = require 'fs'

describe 'ast_gen section', ()->
  it 'test contract 1', ()->
    ast_gen """
    pragma solidity ^0.5.11;
    
    contract Summator {
      uint public value;
      
      function sum() public returns (uint yourMom) {
        uint x = 5;
        return value + x;
      }
    }
    """, silent:true
  
  it 'test contract 1', ()->
    ast_gen """
    pragma solidity ^0.5.11;
    
    contract Summator {
      uint public value;
      
      function sum() public returns (uint yourMom) {
        uint x = 5;
        return value + x;
      }
    }
    """, silent:true
  
  it 'test bad contract', ()->
    assert.throws ()->
      ast_gen """
      pragma solidity ^0.5.11;
      
      contract Summator {
        uint public value;
        
        function sum() public returns (uint yourMom) {
          qwer
          return value + x;
        }
      }
      """, silent:true
  
  describe 'solidity samples', ()->
    fs_tree.walk "solidity_samples", (path)->
      # strip all imports for now
      code = fs.readFileSync path, 'utf-8'
      return if /import/.test code
      code = code.replace('pragma experimental "v0.5.0";', '')
      it path, ()->
        @timeout 10000
        ast_gen code, {
          silent : true
          suggest_solc_version : '0.4.26'
          debug : true
        }
  