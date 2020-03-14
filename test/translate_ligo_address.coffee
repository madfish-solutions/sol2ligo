config = require("../src/config")
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section address", ()->
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
    type state is unit;
    
    function test (const #{config.contract_storage} : state; const target : address) : (list(operation) * state) is
      block {
        var opList : list(operation) := list transaction(unit, 1n * 1mutez, (get_contract(target) : contract(unit))) end;
      } with (opList, #{config.contract_storage});
    """
    make_test text_i, text_o
  
  it "transfer"
