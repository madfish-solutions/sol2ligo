{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
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
    type state is record
      reserved__empty_state : int;
    end;
    
    (* EventDefinition PrimaryTransferred *)
    
    function transferPrimary (const opList : list(operation); const contractStorage : state; const recipient : address) : (list(operation) * state) is
      block {
        (* EmitStatement *);
      } with (opList, contractStorage);
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
    type state is record
      reserved__empty_state : int;
    end;
    
    (* EventDefinition PrimaryTransferred *)
    
    function transferPrimary (const opList : list(operation); const contractStorage : state; const recipient : address) : (list(operation) * state) is
      block {
        (* EmitStatement *);
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o
  