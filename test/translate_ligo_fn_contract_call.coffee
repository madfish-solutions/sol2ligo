config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
  @timeout 10000
  it "cast from address and call", ()->
    text_i = """
    pragma solidity >=0.5.0 <0.6.0;
    
    contract Other {
      function call_me() public {
        
      }
    }
    
    contract Main {
      function test(address t) public {
        Other target = Other(t);
        target.call_me();
      }
    }
    """
    text_o = """
    type other_call_me_args is record
      #{config.reserved}__empty_state : int;
    end;
    
    type main_test_args is record
      t : address;
    end;
    
    type state is record
      #{config.reserved}__initialized : bool;
    end;
    
    type other_enum is
      | Call_me of other_call_me_args;
    
    type main_enum is
      | Test of main_test_args;
    
    
    function test (const opList : list(operation); const contractStorage : state; const t : address) : (list(operation) * state) is
      block {
        const target : contract(other_enum) = (get_contract(t) : contract(other_enum));
        opList := cons(transaction(Call_me(record [ #{config.reserved}__empty_state = 0; ]), 0mutez, target), opList);
      } with (opList, contractStorage);
    
    function main (const action : main_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        case action of
        | Test(match_action) -> block {
          if contractStorage.#{config.reserved}__initialized then {skip} else failwith("can't call this method on non-initialized contract");
          const tmp_0 : (list(operation) * state) = test(opList, contractStorage, match_action.t);
          opList := tmp_0.0;
          contractStorage := tmp_0.1;
        }
        end;
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o, router : true