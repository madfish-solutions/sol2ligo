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
        ownable_constructor(self);
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
    
    function main (const action : router_enum; const self : state) : (list(operation) * state) is
      (case action of
      | Method(match_action) -> block {
        const tmp : (nat) = method(unit);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(nat))) end;
      } with ((opList, self))
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
    
    function main (const action : router_enum; const self : state) : (list(operation) * state) is
      (case action of
      | Method(match_action) -> block {
        const tmp : (nat) = method(unit);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(nat))) end;
      } with ((opList, self))
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
    
    function method (const self : state) : (state) is
      block {
        self.ret := (self.ret + 1n);
      } with (self);
    
    function main (const action : router_enum; const self : state) : (list(operation) * state) is
      (case action of
      | Method(match_action) -> ((nil: list(operation)), method(self))
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
    
    function method (const self : state) : (state) is
      block {
        self.ret := (self.ret + 1n);
      } with (self);
    
    function main (const action : router_enum; const self : state) : (list(operation) * state) is
      (case action of
      | Method(match_action) -> ((nil: list(operation)), method(self))
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
