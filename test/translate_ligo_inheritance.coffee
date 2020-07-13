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
