{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate section", ()->
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
      value: nat;
    end;
    
    function test (const contractStorage : state) : (state) is
      block {
        contractStorage.value := 1n;
      } with (contractStorage);
    
    """
    make_test text_i, text_o
  
  it "basic types", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Basic_types {
      bool  public value_bool  ;
      int   public value_int   ;
      uint  public value_uint  ;
      int8  public value_int8  ;
      uint8 public value_uint8 ;
      address public value_address;
      string  public value_string;
      
      function test() public {}
    }
    """
    text_o = """
    type state is record
      value_bool: bool;
      value_int: int;
      value_uint: nat;
      value_int8: int;
      value_uint8: nat;
      value_address: address;
      value_string: string;
    end;
    
    function test (const contractStorage : state) : (state) is
      block {
        skip
      } with (contractStorage);
    
    """
    make_test text_i, text_o
    # extended types for later...
    ###
    bytes1  public value_bytes1;
    bytes2  public value_bytes2;
    
    function test(function (uint, uint) pure returns (uint) fn) public {
      uint[] memory a = new uint[](7);
    }
    ###
  
  # ###################################################################################################
  #    expr
  # ###################################################################################################
  it "uint ops", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Expr {
      uint public value;
      
      function expr() public returns (uint) {
        uint a = 0;
        uint b = 0;
        uint c = 0;
        c = a + b;
        c = a - b;
        c = a * b;
        c = a / b;
        c = a % b;
        c = a & b;
        c = a | b;
        c = a ^ b;
        c += b;
        c -= b;
        c *= b;
        c /= b;
        c %= b;
        c &= b;
        c |= b;
        c ^= b;
        return c;
      }
    }
    """#"
    text_o = """
      type state is record
        value: nat;
      end;
      
      function expr (const contractStorage : state) : (state * nat) is
        block {
          const a : nat = 0n;
          const b : nat = 0n;
          const c : nat = 0n;
          c := (a + b);
          c := abs(a - b);
          c := (a * b);
          c := (a / b);
          c := (a mod b);
          c := bitwise_and(a, b);
          c := bitwise_or(a, b);
          c := bitwise_xor(a, b);
          c := (c + b);
          c := abs(c - b);
          c := (c * b);
          c := (c / b);
          c := (c mod b);
          c := bitwise_and(c, b);
          c := bitwise_or(c, b);
          c := bitwise_xor(c, b);
        } with (contractStorage, c);
      
    """
    make_test text_i, text_o
  
  it "int ops", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Expr {
      int public value;
      
      function expr() public returns (int) {
        int a = 0;
        int b = 0;
        int c = 0;
        c = -c;
        c = a + b;
        c = a - b;
        c = a * b;
        c = a / b;
        c = a % b;
        c = a & b;
        c = a | b;
        c = a ^ b;
        c += b;
        c -= b;
        c *= b;
        c /= b;
        c %= b;
        c &= b;
        c |= b;
        c ^= b;
        return c;
      }
    }
    """#"
    text_o = """
      type state is record
        value: int;
      end;
      
      function expr (const contractStorage : state) : (state * int) is
        block {
          const a : int = 0;
          const b : int = 0;
          const c : int = 0;
          c := -(c);
          c := (a + b);
          c := (a - b);
          c := (a * b);
          c := (a / b);
          c := (a mod b);
          c := bitwise_and(a, b);
          c := bitwise_or(a, b);
          c := bitwise_xor(a, b);
          c := (c + b);
          c := (c - b);
          c := (c * b);
          c := (c / b);
          c := (c mod b);
          c := bitwise_and(c, b);
          c := bitwise_or(c, b);
          c := bitwise_xor(c, b);
        } with (contractStorage, c);
      
    """
    make_test text_i, text_o
  
  it "cmp uint", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Expr {
      uint public value;
      
      function expr() public returns (uint) {
        uint a = 0;
        uint b = 0;
        bool c;
        c = a <  b;
        c = a <= b;
        c = a >  b;
        c = a >= b;
        c = a == b;
        c = a != b;
        return 0;
      }
    }
    """#"
    text_o = """
      type state is record
        value: nat;
      end;
      
      function expr (const contractStorage : state) : (state * nat) is
        block {
          const a : nat = 0n;
          const b : nat = 0n;
          const c : bool = False;
          c := (a < b);
          c := (a <= b);
          c := (a > b);
          c := (a >= b);
          c := (a = b);
          c := (a =/= b);
        } with (contractStorage, 0);
      
    """
    make_test text_i, text_o
  
  it "cmp int", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Expr {
      uint public value;
      
      function expr() public returns (uint) {
        int a = 0;
        int b = 0;
        bool c;
        c = a <  b;
        c = a <= b;
        c = a >  b;
        c = a >= b;
        c = a == b;
        c = a != b;
        return 0;
      }
    }
    """#"
    text_o = """
      type state is record
        value: nat;
      end;
      
      function expr (const contractStorage : state) : (state * nat) is
        block {
          const a : int = 0;
          const b : int = 0;
          const c : bool = False;
          c := (a < b);
          c := (a <= b);
          c := (a > b);
          c := (a >= b);
          c := (a = b);
          c := (a =/= b);
        } with (contractStorage, 0);
      
    """
    make_test text_i, text_o
  
  it "a[b]", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Expr {
      mapping (address => uint) balances;
      
      function expr(address owner) public returns (uint) {
        return balances[owner];
      }
    }
    """#"
    text_o = """
    type state is record
      balances: map(address, nat);
    end;
    
    function expr (const contractStorage : state; const owner : address) : (state * nat) is
      block {
        skip
      } with (contractStorage, (case contractStorage.balances[owner] of | None -> 0n | Some(x) -> x end));
    """
    make_test text_i, text_o
  