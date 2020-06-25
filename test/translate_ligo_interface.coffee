config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section interface", ()->
  @timeout 10000
  # ###################################################################################################
  #    interface
  # ###################################################################################################
  it "library libname.method (no using)", ()->
    text_i = """
    pragma solidity ^0.4.26;
    
    interface Ownable {
      function one(uint i);
    }
    
    contract Sample is Ownable {
      function Sample() {
        
      }
      
      function one(uint i) {
      
      }
    }
    """
    text_o = """
    type state is unit;
    
    function constructor (const #{config.contract_storage} : state) : (list(operation) * state) is
      block {
        skip
      } with (list [], #{config.contract_storage});
    
    function one (const #{config.contract_storage} : state; const i : nat) : (list(operation) * state) is
      block {
        skip
      } with (list [], #{config.contract_storage});
    """#"
    make_test text_i, text_o
  