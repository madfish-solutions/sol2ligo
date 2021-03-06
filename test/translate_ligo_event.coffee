config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section emit", ()->
  @timeout 10000
  it "emit", ()->
    text_i = """
    pragma solidity ^0.4.22;
    
    contract Secondary {
      event PrimaryTransferred(
        address recipient
      );
      function transferPrimary(address recipient) public{
        emit PrimaryTransferred(recipient);
      }
    }
    """
    text_o = """
    type state is unit;
    
    (* EventDefinition PrimaryTransferred(recipient : address) *)
    
    function transferPrimary (const recipient : address) : (unit) is
      block {
        (* EmitStatement PrimaryTransferred(recipient) *)
      } with (unit);
    """#"
    make_test text_i, text_o
  
  it "call event no emit", ()->
    text_i = """
    pragma solidity ^0.4.22;
    
    contract Secondary {
      event PrimaryTransferred(
        address recipient
      );
      function transferPrimary(address recipient) public{
        PrimaryTransferred(recipient);
      }
    }
    """
    text_o = """
    type state is unit;
    
    (* EventDefinition PrimaryTransferred(recipient : address) *)
    
    function transferPrimary (const recipient : address) : (unit) is
      block {
        (* EmitStatement PrimaryTransferred(recipient) *)
      } with (unit);
    """#"
    make_test text_i, text_o
  