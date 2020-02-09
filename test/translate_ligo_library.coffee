config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
  @timeout 10000
  # ###################################################################################################
  #    library
  # ###################################################################################################
  # NOTE no space between Class_decl is BUG
  it "library libname.method (no using)", ()->
    text_i = """
    pragma solidity ^0.4.22;
    
    library ExactMath {
      function exactAdd(uint self, uint other) internal returns (uint sum) {
        sum = self + other;
        require(sum >= self);
      }
    }
    
    contract MathExamples {
      // Add exact uints example.
      function uintExactAddOverflowExample() public {
        var n = uint(~0);
        ExactMath.exactAdd(n,1);
      }
    }
    """
    text_o = """
    type state is record
      #{config.empty_state} : int;
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
  
  it "library (no using) + pure", ()->
    text_i = """
    pragma solidity ^0.4.22;
    
    library ExactMath {
      function exactAdd(uint self, uint other) internal pure returns (uint sum) {
        sum = self + other;
        require(sum >= self);
      }
    }
    
    contract Pure_test {
      function test() public pure returns (uint) {
        var n = uint(~0);
        ExactMath.exactAdd(n,1);
        return 0;
      }
    }
    """
    text_o = """
    type test_args is record
      callbackAddress : address;
    end;
    
    type state is record
      #{config.initialized} : bool;
    end;
    
    function exactMath_exactAdd (const self : nat; const other : nat) : (nat) is
      block {
        const sum : nat = 0n;
        sum := (self + other);
        if (sum >= self) then {skip} else failwith("require fail");
      } with (sum);
    function test (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const n : nat = abs(not (0));
        const tmp_0 : nat = exactMath_exactAdd(n, 1n);
      } with (0n);
    
    type router_enum is
      | Test of test_args;
    
    function main (const action : router_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        if (contractStorage.#{config.initialized}) then block {
          case action of
          | Test(match_action) -> block {
            const tmp_0 : nat = test(unit);
            opList := cons(transaction(tmp_0, 0mutez, (get_contract(match_action.callbackAddress) : contract(nat))), opList);
          }
          end;
        } else block {
          contractStorage.#{config.initialized} := True;
        };
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o, router: true
  
  it "library call from library", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    library Bytes {
      function fromBytes(bytes memory bts) internal pure returns (uint addr) {
        
      }
      
      function concat(bytes memory self, bytes memory other) {
        var src = fromBytes(self);
      }
    }
    
    contract Main {
      function main(bytes memory self, bytes memory other) {
        var src = Bytes.fromBytes(self);
      }
    }
    """
    text_o = """
    type main_args is record
      self : bytes;
      other : bytes;
    end;
    
    type state is record
      #{config.initialized} : bool;
    end;
    
    function bytes_fromBytes (const bts : bytes) : (nat) is
      block {
        const addr : nat = 0n;
      } with (addr);
    
    function #{config.reserved}__bytes_concat (const opList : list(operation); const contractStorage : state; const self : bytes; const other : bytes) : (list(operation) * state) is
      block {
        const tmp_0 : nat = bytes_fromBytes(self);
        const src : nat = tmp_0;
      } with (opList, contractStorage);
    function main (const opList : list(operation); const contractStorage : state; const self : bytes; const other : bytes) : (list(operation) * state) is
      block {
        const tmp_0 : nat = bytes_fromBytes(self);
        const src : nat = tmp_0;
      } with (opList, contractStorage);
    
    type router_enum is
      | Main of main_args;
    
    function main (const action : router_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        if (contractStorage.#{config.initialized}) then block {
          case action of
          | Main(match_action) -> block {
            const tmp_0 : (list(operation) * state) = main(opList, contractStorage, match_action.self, match_action.other);
            opList := tmp_0.0;
            contractStorage := tmp_0.1;
          }
          end;
        } else block {
          contractStorage.#{config.initialized} := True;
        };
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o, router: true
  
