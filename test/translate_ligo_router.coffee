{
  translate_ligo_make_test : make_test
} = require("./util")

describe "generate router", ()->
  @timeout 10000
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
    
    function oneArgFunction (const opList : list(operation); const contractStorage : state; const reserved__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function twoArgsFunction (const opList : list(operation); const contractStorage : state; const dest : address; const reserved__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    type router_enum is
      | OneArgFunction of oneArgFunction_args
      | TwoArgsFunction of twoArgsFunction_args;
    
    function main (const action : router_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        if (contractStorage.reserved__initialized) then block {
          case action of
          | OneArgFunction(match_action) -> block {
            const tmp_0 : (list(operation) * state) = oneArgFunction(opList, contractStorage, match_action.reserved__amount);
            opList := tmp_0.0;
            contractStorage := tmp_0.1;
          }
          | TwoArgsFunction(match_action) -> block {
            const tmp_1 : (list(operation) * state) = twoArgsFunction(opList, contractStorage, match_action.dest, match_action.reserved__amount);
            opList := tmp_1.0;
            contractStorage := tmp_1.1;
          }
          end;
        } else block {
          contractStorage.reserved__initialized := True;
        };
      } with (opList, contractStorage);
    """
    make_test text_i, text_o, {
      router: true
      op_list: true
    }
