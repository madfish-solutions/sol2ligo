config = require("../src/config")
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
  @timeout 10000
  # ###################################################################################################
  #    address
  # ###################################################################################################
  it "send", ()->
    text_i = """
    pragma solidity ^0.4.26;
    
    contract Transfer_test {
      
      function test(address target) public {
        target.send(1);
      }
    }
    """
    text_o = """
    type state is record
      #{config.empty_state} : int;
    end;
    
    function test (const opList : list(operation); const contractStorage : state; const target : address) : (list(operation) * state) is
      block {
        opList := cons(transaction(unit, 1n * 1mutez, (get_contract(target) : contract(unit))), opList);
      } with (opList, contractStorage);
    """
    make_test text_i, text_o
  
  it "transfer"
