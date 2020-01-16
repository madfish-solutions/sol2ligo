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
    type Router_enum is
      | test_args is test_args;
    
    function main (const contractStorage : state; const action : Router_enum) : (state) is
      block {
        if (contractStorage.reserved__initialized) then block {
          case action of
          | test_args(match_action) -> block {
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
  