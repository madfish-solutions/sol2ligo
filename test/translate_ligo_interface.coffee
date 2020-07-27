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
    
    function constructor (const #{config.reserved}__unit : unit) : (unit) is
      block {
        skip
      } with (unit);
    
    function one (const i : nat) : (unit) is
      block {
        skip
      } with (unit);
    """#"
    make_test text_i, text_o
  