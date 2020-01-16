{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
  it "router test", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Router_test {
      function test() public payable {
      }
    }
    """

    text_o = """
    type state is record
      reserved__initialized : bool;
    end;
    type test_args is record
      
    end;
    
    function test (const contractStorage : state) : (state) is
      block {
        skip
      } with (contractStorage);
    type router_enum is
      | TestArgs of test_args;
    
    function main (const contractStorage : state; const action : router_enum) : (state) is
      block {
        if (contractStorage.reserved__initialized) then block {
          case action of
          | TestArgs(match_action) -> block {
            const tmp_0 : (state) = test(contractStorage);
            contractStorage := tmp_0.0;
            tmp_0.1;
          }
          end;
        } else block {
          contractStorage.reserved__initialized := True;
        };
      }
    """
    make_test text_i, text_o, router: true
  

describe "generate router", ()->
  it "router with args", ()->
    text_i = """
    pragma solidity >=0.5.0 <0.6.0;

    contract Router {
      function oneArgFunction(uint amount) public {  }
      function twoArgsFunction(address dest, uint amount) public {  }
    }
    """#"
    text_o = """
    type state is record
      reserved__initialized : bool;
    end;
    type oneArgFunction_args is record
      reserved__amount : nat;
    end;
    type twoArgsFunction_args is record
      dest : address;
      reserved__amount : nat;
    end;

    function oneArgFunction (const contractStorage : state; const args_ : oneArgFunction_args) : (list(operation) * state) is
      block {
        skip
      } with ((nil: list(operation)), contractStorage)

    function twoArgsFunction (const contractStorage : state; const args_ : twoArgsFunction_args) : (list(operation) * state) is
      block {
        skip
      } with ((nil: list(operation)), contractStorage)

    type router_enum is
      | OneArgFunction of oneArgFunction_args
      | TwoArgsFunction of twoArgsFunction_args;

    function main (const action : router_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        if (contractStorage.reserved__initialized) then block {
          case action of
          | OneArgFunction(match_action) -> block {
            const tmp_0 : (list(operation) * state) = oneArgFunction(contractStorage, match_action);
            contractStorage := tmp_0.1;
          }
          | TwoArgsFunction(match_action) -> block {
            const tmp_1 : (list(operation) * state) = twoArgsFunction(contractStorage, match_action);
            contractStorage := tmp_1.1;
          }
          end;
        } else block {
          contractStorage.reserved__initialized := True;
        };
      } with ((nil: list(operation)), contractStorage)
      """

    make_test text_i, text_o, router: true
