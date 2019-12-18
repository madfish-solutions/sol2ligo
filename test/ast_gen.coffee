assert = require 'assert'
ast_gen = require '../src/ast_gen'
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
