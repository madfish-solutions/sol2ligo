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
      _initialized : bool;
    end;
    
    function test (const contractStorage : state) : (state) is
      block {
        skip
      } with (contractStorage);
    
    function main (const contractStorage : state) : (state) is
      block {
        if (contractStorage._initialized) then block {
          case action of
          | Test(match_action) -> block {
            const tmp_0 : (state) = test(contractStorage, match_action.contractStorage);
            contractStorage := tmp_0.0;
            tmp_0.1;
          }
          end;
        } else block {
          contractStorage._initialized := True;
        };
      }
    """
    make_test text_i, text_o, router: true
  