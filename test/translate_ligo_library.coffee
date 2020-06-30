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
    
    function exactMath_exactAdd (const self : state; const test_reserved_long___self : nat; const other : nat) : (state * nat) is
      block {
        const sum : nat = 0n;
        sum := (test_reserved_long___self + other);
        assert((sum >= test_reserved_long___self));
      } with (#{config.contract_storage}, sum);
    function uintExactAddOverflowExample (const #{config.contract_storage} : state) : (list(operation) * state) is
      block {
        const n : nat = abs(not (0));
        exactMath_exactAdd(self, n, 1n);
      } with ((nil: list(operation)), #{config.contract_storage});
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
    
    function test (const #{config.reserved}__unit : unit) : (list(operation) * nat) is
      block {
        const n : nat = abs(not (0));
        exactMath_exactAdd(n, 1n);
      } with ((nil: list(operation)), 0n);
    
    function main (const action : router_enum; const #{config.contract_storage} : state) : (list(operation) * state) is
      (case action of
      | Test(match_action) -> (test(unit), self)
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
    
    function #{config.reserved}__bytes_concat (const #{config.contract_storage} : state; const test_reserved_long___self : bytes; const other : bytes) : (list(operation) * state) is
      block {
        const src : nat = bytes_fromBytes(test_reserved_long___self);
      } with ((nil: list(operation)), #{config.contract_storage});
    type router_enum is
      | #{config.reserved[0].toUpperCase() + config.reserved.slice(1)}__main of test_reserved_long___main_args;
    
    function #{config.reserved}__main (const #{config.contract_storage} : state; const test_reserved_long___self : bytes; const other : bytes) : (list(operation) * state) is
      block {
        const src : nat = bytes_fromBytes(test_reserved_long___self);
      } with ((nil: list(operation)), #{config.contract_storage});
    
    function main (const action : router_enum; const #{config.contract_storage} : state) : (list(operation) * state) is
      (case action of
      | Test_reserved_long___main(match_action) -> test_reserved_long___main(self, match_action.test_reserved_long___self, match_action.other)
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
    
    function addPauser_ (const #{config.contract_storage} : state; const account : address) : (state) is
      block {
        #{config.contract_storage}.pausers_.bearer[account] := True;
      } with (#{config.contract_storage});
    """#"
    make_test text_i, text_o
  
