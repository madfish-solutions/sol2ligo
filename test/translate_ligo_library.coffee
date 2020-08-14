config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section library", ()->
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
    type state is unit;
    
    function exactMath_exactAdd (const test_reserved_long___self : nat; const other : nat) : (nat) is
      block {
        const sum : nat = 0n;
        sum := (test_reserved_long___self + other);
        assert((sum >= test_reserved_long___self));
      } with (sum);
    function uintExactAddOverflowExample (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const n : nat = abs(not (0));
        const terminate_tmp_0 : (nat) = exactMath_exactAdd(n, 1n);
      } with (unit);
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
    
    type state is unit;
    
    function exactMath_exactAdd (const test_reserved_long___self : nat; const other : nat) : (nat) is
      block {
        const sum : nat = 0n;
        sum := (test_reserved_long___self + other);
        assert((sum >= test_reserved_long___self));
      } with (sum);
    type router_enum is
      | Test of test_args;
    
    function test (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const n : nat = abs(not (0));
        const terminate_tmp_0 : (nat) = exactMath_exactAdd(n, 1n);
      } with (0n);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Test(match_action) -> block {
        const tmp : (nat) = test(unit);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(nat))) end;
      } with ((opList, contract_storage))
      end);
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
    type test_reserved_long___main_args is record
      test_reserved_long___self : bytes;
      other : bytes;
    end;
    
    type state is unit;
    
    function bytes_fromBytes (const bts : bytes) : (nat) is
      block {
        const addr : nat = 0n;
      } with (addr);
    
    function #{config.reserved}__bytes_concat (const test_reserved_long___self : bytes; const other : bytes) : (unit) is
      block {
        const src : nat = bytes_fromBytes(test_reserved_long___self);
      } with (unit);
    type router_enum is
      | #{config.reserved[0].toUpperCase() + config.reserved.slice(1)}__main of test_reserved_long___main_args;
    
    function #{config.reserved}__main (const test_reserved_long___self : bytes; const other : bytes) : (unit) is
      block {
        const src : nat = bytes_fromBytes(test_reserved_long___self);
      } with (unit);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Test_reserved_long___main(match_action) -> block {
        (* This function does nothing, but it's present in router *)
        const tmp : unit = test_reserved_long___main(match_action.test_reserved_long___self, match_action.other);
      } with (((nil: list(operation)), contract_storage))
      end);
    """#"
    make_test text_i, text_o, router: true
  
  it "library struct use from contract", ()->
    text_i = """
    pragma solidity ^0.5.0;
    
    library Roles {
      struct Role {
        mapping (address => bool) bearer;
      }
    }
    
    contract PauserRole {
      Roles.Role private _pausers;
      
      function _addPauser(address account) internal {
        _pausers.bearer[account] = true;
      }
    }
    """
    text_o = """
    type roles_Role is record
      bearer : map(address, bool);
    end;
    
    type state is record
      pausers_ : roles_Role;
    end;
    
    const roles_Role_default : roles_Role = record [ bearer = (map end : map(address, bool)) ];
    
    function addPauser_ (const contract_storage : state; const account : address) : (state) is
      block {
        contract_storage.pausers_.bearer[account] := True;
      } with (contract_storage);
    """#"
    make_test text_i, text_o
  # ###################################################################################################
  #    using
  # ###################################################################################################
  it "library libname.method (using)", ()->
    text_i = """
    pragma solidity ^0.4.22;
    
    library ExactMath {
      function exactAdd(uint self, uint other) internal returns (uint sum) {
        sum = self + other;
        require(sum >= self);
      }
    }
    
    contract MathExamples {
      using ExactMath for uint;
      // Add exact uints example.
      function uintExactAddOverflowExample() public {
        var n = uint(~0);
        n.exactAdd(1);
      }
    }
    """
    text_o = """
    type state is unit;
    
    function exactMath_exactAdd (const test_reserved_long___self : nat; const other : nat) : (nat) is
      block {
        const sum : nat = 0n;
        sum := (test_reserved_long___self + other);
        assert((sum >= test_reserved_long___self));
      } with (sum);
    (* UsingForDirective *)
    
    function uintExactAddOverflowExample (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const n : nat = abs(not (0));
        const terminate_tmp_0 : (nat) = exactMath_exactAdd(n, 1n);
      } with (unit);
    """#"
    make_test text_i, text_o
  
  it "library (using) + pure", ()->
    text_i = """
    pragma solidity ^0.4.22;
    
    library ExactMath {
      function exactAdd(uint self, uint other) internal pure returns (uint sum) {
        sum = self + other;
        require(sum >= self);
      }
    }
    
    contract Pure_test {
      using ExactMath for uint;
      function test() public pure returns (uint) {
        var n = uint(~0);
        n.exactAdd(1);
        return 0;
      }
    }
    """
    text_o = """
    type test_args is record
      callbackAddress : address;
    end;
    
    type state is unit;
    
    function exactMath_exactAdd (const test_reserved_long___self : nat; const other : nat) : (nat) is
      block {
        const sum : nat = 0n;
        sum := (test_reserved_long___self + other);
        assert((sum >= test_reserved_long___self));
      } with (sum);
    type router_enum is
      | Test of test_args;
    
    (* UsingForDirective *)
    
    function test (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const n : nat = abs(not (0));
        const terminate_tmp_0 : (nat) = exactMath_exactAdd(n, 1n);
      } with (0n);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Test(match_action) -> block {
        const tmp : (nat) = test(unit);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(nat))) end;
      } with ((opList, contract_storage))
      end);
    """#"
    make_test text_i, text_o, router: true
  
  it "using changes storage", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    library Bits {
    
        uint constant internal const_ONE = uint(1);
        uint constant internal const_ONES = uint(~0);
    
        // Sets the bit at the given 'index' in 'tmp_self' to '1'.
        // Returns the modified value.
        function setBit(uint tmp_self, uint8 index) internal pure returns (uint) {
            return tmp_self | const_ONE << index;
        }
    }
    
    contract BitsExamples {
      using Bits for uint;
    
      // Set bits
      function setBitExample() public pure {
        uint n = 0;
        n = n.setBit(0); // Set the 0th bit.
        assert(n == 1);  // 1
      }
    }
    """
    text_o = """
    type setBitExample_args is unit;
    type state is unit;
    
    const const_ONE : nat = abs(1)
    
    const const_ONES : nat = abs(not (0))
    
    function bits_setBit (const tmp_self : nat; const index : nat) : (nat) is
      block {
        skip
      } with (bitwise_or(tmp_self, bitwise_lsl(const_ONE, index)));
    type router_enum is
      | SetBitExample of setBitExample_args;
    
    (* UsingForDirective *)
    
    function setBitExample (const test_reserved_long___unit : unit) : (unit) is
      block {
        const n : nat = 0n;
        n := bits_setBit(n, 0n);
        assert((n = 1n));
      } with (unit);
    
    function main (const action : router_enum; const test_self : state) : (list(operation) * state) is
      (case action of
      | SetBitExample(match_action) -> block {
        (* This function does nothing, but it's present in router *)
        const tmp : unit = setBitExample(unit);
      } with (((nil: list(operation)), test_self))
      end);
    """
    make_test text_i, text_o, router: true
  
  it "library libname.method (using for *)", ()->
    text_i = """
    pragma solidity ^0.4.22;
    
    library ExactMath {
      function exactAdd(uint self, uint other) internal returns (uint sum) {
        sum = self + other;
        require(sum >= self);
      }
    }
    
    contract MathExamples {
      using ExactMath for *;
      // Add exact uints example.
      function uintExactAddOverflowExample() public {
        var n = uint(~0);
        n.exactAdd(1);
      }
    }
    """
    text_o = """
    type state is unit;
    
    function exactMath_exactAdd (const test_reserved_long___self : nat; const other : nat) : (nat) is
      block {
        const sum : nat = 0n;
        sum := (test_reserved_long___self + other);
        assert((sum >= test_reserved_long___self));
      } with (sum);
    (* UsingForDirective *)
    
    function uintExactAddOverflowExample (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const n : nat = abs(not (0));
        const terminate_tmp_0 : (nat) = exactMath_exactAdd(n, 1n);
      } with (unit);
    """#"
    make_test text_i, text_o
  