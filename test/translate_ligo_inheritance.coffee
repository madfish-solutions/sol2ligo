config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section inheritance", ()->
  @timeout 10000
  it "basic", ()->
    text_i = """
    pragma solidity ^0.4.26;
    
    contract Ownable {
      function one(uint i) {
        i = 1;
      }
    }
    
    contract Sample is Ownable {
      function Sample() {
        
      }
      
      function some(uint i) {
      
      }
    }
    """
    text_o = """
    type state is unit;
    
    function one (const i : nat) : (unit) is
      block {
        i := 1n;
      } with (unit);
    
    function constructor (const #{config.reserved}__unit : unit) : (unit) is
      block {
        skip
      } with (unit);
    
    function #{config.reserved}__some (const i : nat) : (unit) is
      block {
        skip
      } with (unit);
    """
    make_test text_i, text_o
  
  it "With args THIS TEST IS WRONG. NO CONSTRUCTOR BODY", ()->
    return # broken in peculiar way
    text_i = """
    pragma solidity ^0.4.26;
    
    contract Ownable {
      function Ownable(uint i) {
        i = 1;
      }
    }
    
    contract Sample is Ownable(0) {
      function Sample() {
        
      }
      
      function some(uint i) {
      
      }
    }
    """
    text_o = """
    type state is unit;
    
    function ownable_constructor (const i : nat) : (unit) is
      block {
        i := 1n;
      } with (unit);
    
    function constructor (const #{config.reserved}__unit : unit) : (unit) is
      block {
        ownable_constructor(contract_storage);
      } with (unit);
    
    function #{config.reserved}__some (const i : nat) : (unit) is
      block {
        skip
      } with (unit);
    """
    make_test text_i, text_o
  
  it "method collide (should shadow parent method)", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Parent {
      function method() public returns (uint ret_val) {
        ret_val = 0;
      }
    }
    
    contract Child is Parent {
      function method() public returns (uint ret_val) {
        ret_val = 1;
      }
    }
    """
    text_o = """
    type method_args is record
      callbackAddress : address;
    end;
    
    type state is unit;
    
    type router_enum is
      | Method of method_args;
    
    function method_1 (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const ret_val : nat = 0n;
        ret_val := 0n;
      } with (ret_val);
    
    function method (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const ret_val : nat = 0n;
        ret_val := 1n;
      } with (ret_val);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Method(match_action) -> block {
        const tmp : (nat) = method(unit);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(nat))) end;
      } with ((opList, contract_storage))
      end);
    """
    make_test text_i, text_o, router: true
  
  it "method collide + call (should shadow parent method)", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Parent {
      function method() public returns (uint ret_val) {
        ret_val = 0;
      }
    }
    
    contract Child is Parent {
      function method() public returns (uint ret_val) {
        ret_val = super.method();
      }
    }
    """
    text_o = """
    type method_args is record
      callbackAddress : address;
    end;
    
    type state is unit;
    
    type router_enum is
      | Method of method_args;
    
    function method_1 (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const ret_val : nat = 0n;
        ret_val := 0n;
      } with (ret_val);
    
    function method (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const ret_val : nat = 0n;
        ret_val := method_1(unit);
      } with (ret_val);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Method(match_action) -> block {
        const tmp : (nat) = method(unit);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(nat))) end;
      } with ((opList, contract_storage))
      end);
    """
    make_test text_i, text_o, router: true
  
  it "method self collide + properties self collide (class used twice in inheritance tree)", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Dupe_parent {
      uint ret;
      function method() public {
        ret += 1;
      }
    }
    
    contract Parent1 is Dupe_parent {}
    
    contract Parent2 is Dupe_parent {}
    
    contract Child is Parent1, Parent2 {}
    """
    text_o = """
    type method_args is unit;
    type state is record
      ret : nat;
    end;
    
    type router_enum is
      | Method of method_args;
    
    function method (const contract_storage : state) : (state) is
      block {
        contract_storage.ret := (contract_storage.ret + 1n);
      } with (contract_storage);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Method(match_action) -> ((nil: list(operation)), method(contract_storage))
      end);
    """
    make_test text_i, text_o, router: true
  
  it "opt.contract (no self collide)", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Dupe_parent {
      uint ret;
      function method() public {
        ret += 1;
      }
    }
    
    contract Parent1 is Dupe_parent {}
    
    contract Parent2 is Dupe_parent {
      uint should_not_pass1;
    }
    
    contract Child is Parent1, Parent2 {
      uint should_not_pass2;
    }
    """
    text_o = """
    type method_args is unit;
    type state is record
      ret : nat;
    end;
    
    type router_enum is
      | Method of method_args;
    
    function method (const contract_storage : state) : (state) is
      block {
        contract_storage.ret := (contract_storage.ret + 1n);
      } with (contract_storage);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Method(match_action) -> ((nil: list(operation)), method(contract_storage))
      end);
    """
    make_test text_i, text_o, {
      contract: "Parent1"
      router: true
    }
  
  it "opt.contract (no self collide constructor)", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Dupe_parent {
      uint ret;
      constructor() public {
        ret += 1;
      }
    }
    
    contract Parent1 is Dupe_parent {}
    
    contract Parent2 is Dupe_parent {}
    
    contract Child is Parent1, Parent2 {}
    """
    text_o = """
    type constructor_args is unit;
    type state is record
      ret : nat;
    end;
    
    type router_enum is
      | Constructor of constructor_args;
    
    function dupe_parent_constructor (const contract_storage : state) : (state) is
      block {
        contract_storage.ret := (contract_storage.ret + 1n);
      } with (contract_storage);
    
    function constructor (const contract_storage : state) : (state) is
      block {
        contract_storage := dupe_parent_constructor(contract_storage);
      } with (contract_storage);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Constructor(match_action) -> ((nil: list(operation)), constructor(contract_storage))
      end);
    """
    make_test text_i, text_o, {
      contract: "Parent1"
      router: true
    }
  
  it "super.method()", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Parent {
      function method1() public returns (uint ret_val) {
        ret_val = 0;
      }
    }
    
    contract Child is Parent {
      function method2() public returns (uint ret_val) {
        ret_val = super.method1();
      }
    }
    """
    text_o = """
    type state is unit;
    
    function method1 (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const ret_val : nat = 0n;
        ret_val := 0n;
      } with (ret_val);
    
    function method2 (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const ret_val : nat = 0n;
        ret_val := method1(unit);
      } with (ret_val);
    """
    make_test text_i, text_o
  
  it "const access", ()->
    text_i = """
    pragma solidity ^0.4.24;
    
    contract UpgradeabilityProxy {
        int constant implementation_slot = 5;
        function _implementation() {
            int slot = implementation_slot;
        }
    }
    
    contract AdminUpgradeabilityProxy is UpgradeabilityProxy {}
    """
    text_o = """
    type state is unit;
    
    const implementation_slot : int = 5
    
    function implementation_ (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const slot : int = implementation_slot;
      } with (unit);
    """
    make_test text_i, text_o

 it "opt.contract transaction mode", ()->
    text_i = """
    pragma solidity ^0.4.16;

    contract Foreign {
      function foreign(uint n, string s, bool b) public {
          n += 1;
      }
    }

    contract Local {
        function local() public returns (bool) {
            Foreign foo = Foreign(0xaaddffee22);
            foo.foreign(5, "hello", false);
            return true;
        }
    }
    """
    
    text_o = """
    type state is unit;

    function local (const opList : list(operation)) : (list(operation) * bool) is
      block {
        const foo : address = ("PLEASE_REPLACE_ETH_ADDRESS_0xaaddffee22_WITH_A_TEZOS_ADDRESS" : address);
        const op0 : operation = transaction((5n, "hello", False), 0mutez, (get_entrypoint("%foreign", foo) : contract(nat, string, bool)));
      } with (list [op0], True);
    """
    make_test text_i, text_o, {
      contract: "Parent1",
      allow_need_prevent_deploy: true # because of a foreign contract call
    }