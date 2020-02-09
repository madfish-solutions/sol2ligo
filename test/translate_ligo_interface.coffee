{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
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
    type state is record
      reserved__empty_state : int;
    end;
    
    function sample (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function one (const opList : list(operation); const contractStorage : state; const i : nat) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o
  