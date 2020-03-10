config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section inheritance", ()->
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
    type state is unit;
    
    function one (const #{config.contract_storage} : state; const i : nat) : (list(operation) * state) is
      block {
        i := 1n;
      } with ((nil: list(operation)), #{config.contract_storage});
    
    function constructor (const #{config.contract_storage} : state) : (list(operation) * state) is
      block {
        skip
      } with ((nil: list(operation)), #{config.contract_storage});
    
    function #{config.reserved}__some (const #{config.contract_storage} : state; const i : nat) : (list(operation) * state) is
      block {
        skip
      } with ((nil: list(operation)), #{config.contract_storage});
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
    type state is unit;
    
    function ownable_constructor (const #{config.contract_storage} : state; const i : nat) : (list(operation) * state) is
      block {
        i := 1n;
      } with ((nil: list(operation)), #{config.contract_storage});
    
    function constructor (const #{config.contract_storage} : state) : (list(operation) * state) is
      block {
        ownable_constructor(self);
      } with ((nil: list(operation)), #{config.contract_storage});
    
    function #{config.reserved}__some (const #{config.contract_storage} : state; const i : nat) : (list(operation) * state) is
      block {
        skip
      } with ((nil: list(operation)), #{config.contract_storage});
    """
    make_test text_i, text_o
  