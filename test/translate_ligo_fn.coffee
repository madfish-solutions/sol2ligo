config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section fn", ()->
  @timeout 10000
  # ###################################################################################################
  #    basic
  # ###################################################################################################
  it "hello world", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Hello_world {
      uint public value;
      
      function test() public {
        value = 1;
      }
    }
    """
    text_o = """
    type state is record
      value : nat;
    end;
    
    function test (const contract_storage : state) : (state) is
      block {
        contract_storage.value := 1n;
      } with (contract_storage);
    
    """
    make_test text_i, text_o
  
  # ###################################################################################################
  #    fn decl special abilities
  # ###################################################################################################
  it "named ret val", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Expr {
      uint public value;
      
      function expr() public returns (int c) {
        int a = 0;
        c = a;
        return c;
      }
    }
    """
    text_o = """
    type state is record
      value : nat;
    end;
    
    function expr (const #{config.reserved}__unit : unit) : (int) is
      block {
        const c : int = 0;
        const a : int = 0;
        c := a;
      } with (c);
    """
    make_test text_i, text_o

  it "main test", ()->
    text_i = """
    pragma solidity ^0.4.16;

    contract UnOpTest {
        function main(bool b0) internal {
            bool b1 = !!!!!b0;
        }
    }
    """
    text_o = """
    type state is unit;

    function #{config.reserved}__main (const b0 : bool) : (unit) is
      block {
        const b1 : bool = not (not (not (not (not (b0)))));
      } with (unit);
    """
    make_test text_i, text_o
  
  it "named ret val no return", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Expr {
      uint public value;
      
      function expr() public returns (int c) {
        int a = 0;
        c = a;
      }
    }
    """
    text_o = """
    type state is record
      value : nat;
    end;
    
    function expr (const #{config.reserved}__unit : unit) : (int) is
      block {
        const c : int = 0;
        const a : int = 0;
        c := a;
      } with (c);
    """
    make_test text_i, text_o
  
  # ###################################################################################################
  #    fn call
  # ###################################################################################################
  it "fn decl, ret", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Call {
      function test() public returns (uint) {
        return 0;
      }
    }
    """#"
    text_o = """
    type state is unit;
    
    function test (const #{config.reserved}__unit : unit) : (nat) is
      block {
        skip
      } with (0n);
    """
    make_test text_i, text_o
  
  it "fn call", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Call {
      function call_me(int a) public returns (int) {
        return a;
      }
      function test(int a) public returns (int) {
        return call_me(a);
      }
    }
    """#"
    text_o = """
    type state is unit;
    
    function call_me (const a : int) : (int) is
      block {
        skip
      } with (a);
    
    function test (const a : int) : (int) is
      block {
        skip
      } with (call_me(a));
    """
    make_test text_i, text_o
  
  it "fn call in expr", ()->
    text_i = """
    pragma solidity ^0.5.0;
    
    contract Ownable {
      function _msgSender() internal view returns (address payable) {
        return msg.sender;
      }
      address private _owner;
      
      function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
      }
    }
    """#"
    text_o = """
    type state is record
      owner_ : address;
    end;
    
    function msgSender_ (const #{config.reserved}__unit : unit) : (address) is
      block {
        skip
      } with (Tezos.sender);
    
    function isOwner (const contract_storage : state) : (bool) is
      block {
        skip
      } with ((msgSender_(unit) = contract_storage.owner_));
    """
    make_test text_i, text_o
  
  it "fn call and after decl", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Call {
      function test(int a) public returns (int) {
        return call_me(a);
      }
      function call_me(int a) public returns (int) {
        return a;
      }
    }
    """#"
    text_o = """
    type state is unit;
    
    function call_me (const a : int) : (int) is
      block {
        skip
      } with (a);
    
    function test (const a : int) : (int) is
      block {
        skip
      } with (call_me(a));
    """
    make_test text_i, text_o
  
  # ###################################################################################################
  #    pure
  # ###################################################################################################
  it "pure decl + router", ()->
    text_i = """
    pragma solidity ^0.4.22;
    
    contract Pure_test {
      function test() public pure returns (uint) {
        return 0;
      }
    }
    """#"
    text_o = """
    type test_args is record
      callbackAddress : address;
    end;
    
    type state is unit;
    
    type router_enum is
      | Test of test_args;
    
    function test (const #{config.reserved}__unit : unit) : (nat) is
      block {
        skip
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
  
  it "pure call + router", ()->
    text_i = """
    pragma solidity ^0.4.22;
    
    contract Pure_test {
      function exactAdd(uint self, uint other) internal pure returns (uint sum) {
        sum = self + other;
        require(sum >= self);
      }
      function test() public pure returns (uint) {
        var n = uint(~0);
        exactAdd(n,1);
        return 0;
      }
    }
    """#"
    text_o = """
    type test_args is record
      callbackAddress : address;
    end;
    
    type state is unit;
    
    type router_enum is
      | Test of test_args;
    
    function exactAdd (const test_reserved_long___self : nat; const other : nat) : (nat) is
      block {
        const sum : nat = 0n;
        sum := (test_reserved_long___self + other);
        assert((sum >= test_reserved_long___self));
      } with (sum);
    
    function test (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const n : nat = abs(not (0));
        const terminate_tmp_0 : (nat) = exactAdd(n, 1n);
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
  
  