assert = require "assert"
sol2ligo = require "../src"

sol_code = """
  pragma solidity ^0.5.0;
  
  contract FooBarContract {
    function foo(uint number) internal returns (int) {
      string[2] memory arr = ["hello", "world"];
      bool isEven = number % 2 == 0;
      int result = 42 * 42;
      return isEven ? -1 : result;
    }
  }
"""

ligo_code = """
type test_storage is unit;

function foo (const number : nat) : (int) is
  block {
    const arr : map(nat, string) = map
      0n -> "hello";
      1n -> "world";
    end;
    const isEven : bool = ((number mod 2n) = 0n);
    const result : int = (42 * 42);
  } with ((case isEven of | True -> -(1) | False -> result end));
"""

default_state = """
	record
	  reserved__empty_state = 0n;
	end
"""

describe "sol2ligo-as-a-module section", ()->
  it "works with no router", ()->
  	compiled = sol2ligo.compile sol_code, router: false
  	assert.strictEqual compiled.ligo_code, ligo_code
  	assert.strictEqual compiled.default_state, default_state
