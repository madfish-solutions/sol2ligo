config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
  @timeout 10000
  # ###################################################################################################
  #    basic
  # ###################################################################################################
  it "hello world", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    contract DSAuth {
      function setAuthority() public auth {
        
      }
      
      modifier auth {
        _;
      }
    }
    """
    text_o = """
    type state is record
      #{config.empty_state} : int;
    end;
    
    (* modifier auth inlined *)
    
    function setAuthority (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    """
    make_test text_i, text_o
  