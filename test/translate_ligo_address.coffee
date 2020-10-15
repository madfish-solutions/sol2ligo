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
    
    function test (const opList : list(operation); const target : address) : (list(operation)) is
      block {
        const op0 : operation = transaction((unit), (1n * 1mutez), (get_contract(target) : contract(unit)));
      } with (list [op0]);
    """
    make_test text_i, text_o
  
  it "convert var assign", ()->
    text_i = """
    pragma solidity ^0.4.26;
    
    contract Transfer_test {
      
      function test() public {
        address addressVar = 0x0000000000000000000000000000000000000000;
      }
    }
    """
    text_o = """
    type state is unit;
    
    const burn_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    
    function test (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const addressVar : address = burn_address;
      } with (unit);
    """
    make_test text_i, text_o
  
  it "transfer"
