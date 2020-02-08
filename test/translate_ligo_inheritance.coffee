config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
  @timeout 10000
  it "basic", ()->
    text_i = """
    pragma solidity ^0.4.26;
    
    contract Ownable {
      function one(uint i) {
        i = 1;
      }
    }
    
    contract Sample is Ownable {
      function Sample() {
        
      }
      
      function some(uint i) {
      
      }
    }
    """
    text_o = """
    type state is record
      #{config.empty_state} : int;
    end;
    
    function one (const opList : list(operation); const contractStorage : state; const i : nat) : (list(operation) * state) is
      block {
        i := 1n;
      } with (opList, contractStorage);
    
    function sample (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function #{config.reserved}__some (const opList : list(operation); const contractStorage : state; const i : nat) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    """
    make_test text_i, text_o
  
  it "With args THIS TEST IS WRONG. NO CONSTRUCTOR BODY", ()->
    text_i = """
    pragma solidity ^0.4.26;
    
    contract Ownable {
      function Ownable(uint i) {
        i = 1;
      }
    }
    
    contract Sample is Ownable(0) {
      function Sample() {
        
      }
      
      function some(uint i) {
      
      }
    }
    """
    text_o = """
    type state is record
      #{config.empty_state} : int;
    end;
    
    function ownable (const opList : list(operation); const contractStorage : state; const i : nat) : (list(operation) * state) is
      block {
        i := 1n;
      } with (opList, contractStorage);
    
    function sample (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function #{config.reserved}__some (const opList : list(operation); const contractStorage : state; const i : nat) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    """
    make_test text_i, text_o
  