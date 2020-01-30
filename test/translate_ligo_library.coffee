{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
  # ###################################################################################################
  #    library
  # ###################################################################################################
  # NOTE no space between Class_decl is BUG
  it "library libname.method (no using)", ()->
    text_i = """
    pragma solidity ^0.4.22;
    
    library ExactMath {
      function exactAdd(uint self, uint other) internal pure returns (uint sum) {
        sum = self + other;
        require(sum >= self);
      }
    }
    
    contract MathExamples {
      // Add exact uints example.
      function uintExactAddOverflowExample() public pure {
        var n = uint(~0);
        ExactMath.exactAdd(n,1);
      }
    }
    """
    text_o = """
    type state is record
      reserved__empty_state : int;
    end;
    
    function exactMath_exactAdd (const opList : list(operation); const contractStorage : state; const self : nat; const other : nat) : (list(operation) * state * nat) is
      block {
        const sum : nat = 0n;
        sum := (self + other);
        if (sum >= self) then {skip} else failwith("require fail");
      } with (opList, contractStorage, sum);
    function uintExactAddOverflowExample (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const n : nat = abs(not (0));
        const tmp_0 : (list(operation) * state * nat) = exactMath_exactAdd(opList, contractStorage, n, 1n);
        opList := tmp_0.0;
        contractStorage := tmp_0.1;
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o
  