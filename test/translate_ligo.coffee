config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
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
      value_bool : bool;
      value_int : int;
      value_uint : nat;
      value_int8 : int;
      value_uint8 : nat;
      value_address : address;
      value_string : string;
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
  
  it "default values", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Default_values {
      function test() public {
        bool    value_bool  ;
        int     value_int   ;
        uint    value_uint  ;
        address value_address;
        string  memory value_string;
      }
    }
    """
    text_o = """
    type state is record
      reserved__empty_state : int;
    end;
    
    function test (const contractStorage : state) : (state) is
      block {
        const value_bool : bool = False;
        const value_int : int = 0;
        const value_uint : nat = 0n;
        const value_address : address = ("tz1iTHHGZSFAEDmk4bt7EqgBjw5Hj7vQjL7b" : address);
        const value_string : string = "";
      } with (contractStorage);
    
    """#"
    make_test text_i, text_o
  
  it "int8/uint8 default value"
  it "true/false"
  it "string escaping"
  
  it "globals", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Globals {
      address public sender;
      uint public value;
      uint public time;
      
      function test() public payable {
        sender = msg.sender;
        value = msg.value;
        time = now;
      }
    }
    """
    text_o = """
    type state is record
      reserved__sender : address;
      value : nat;
      time : nat;
    end;
    
    function test (const contractStorage : state) : (state) is
      block {
        contractStorage.reserved__sender := sender;
        contractStorage.value := nat(amount);
        contractStorage.time := abs(now - (\"1970-01-01T00:00:00Z\": timestamp));
      } with (contractStorage);
    
    """#"
    make_test text_i, text_o
  
  it "contractStorage conflict local", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Globals {
      function test() public payable {
        uint #{config.contract_storage} = 1;
        uint a = #{config.contract_storage};
      }
    }
    """
    text_o = """
    type state is record
      reserved__empty_state : int;
    end;
    
    function test (const contractStorage : state) : (state) is
      block {
        const reserved__#{config.contract_storage} : nat = 1n;
        const a : nat = reserved__#{config.contract_storage};
      } with (contractStorage);
    
    """#"
    make_test text_i, text_o
  
  it "contractStorage conflict arg", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Globals {
      function test(uint #{config.contract_storage}) public payable {
        uint a = #{config.contract_storage};
      }
    }
    """
    text_o = """
    type state is record
      reserved__empty_state : int;
    end;
    
    function test (const contractStorage : state; const reserved__#{config.contract_storage} : nat) : (state) is
      block {
        const a : nat = reserved__#{config.contract_storage};
      } with (contractStorage);
    
    """#"
    make_test text_i, text_o
  
  it "contractStorage conflict state", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Globals {
      uint #{config.contract_storage};
      function test() public payable {
        uint a = #{config.contract_storage};
      }
    }
    """
    text_o = """
    type state is record
      reserved__#{config.contract_storage} : nat;
    end;
    
    function test (const contractStorage : state) : (state) is
      block {
        const a : nat = contractStorage.reserved__#{config.contract_storage};
      } with (contractStorage);
    
    """#"
    make_test text_i, text_o
  
  it "_ at start of id in solidity", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Globals {
      uint _hi;
    }
    """
    text_o = """
    type state is record
      fix_underscore__hi : nat;
    end;
    """#"
    make_test text_i, text_o
  
  it "address(this).balance"
  it "blockhash(block.number - 1)"
  
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
        value : nat;
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
        value : int;
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
        value : nat;
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
        } with (contractStorage, 0n);
      
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
        value : nat;
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
        } with (contractStorage, 0n);
      
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
      balances : map(address, nat);
    end;
    
    function expr (const contractStorage : state; const owner : address) : (state * nat) is
      block {
        skip
      } with (contractStorage, (case contractStorage.balances[owner] of | None -> 0n | Some(x) -> x end));
    """
    make_test text_i, text_o
  
  it "structs", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Structure {
      struct SampleStruct {
        uint data;
      }
    }
    """#"
    text_o = """
    type state is record
      reserved__empty_state : int;
    end;
    
    type SampleStruct is record
      data : nat;
    end;
    
    """
    make_test text_i, text_o

    
  it "enums", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Enumeration {
      enum SomeData {DEFAULT,ONE,TWO}
    }
    """#"
    # please note that enum name should become lowercase!
    text_o = """
    type state is record
      reserved__empty_state : int;
    end;
    
    type SomeData is
      | DEFAULT
      | ONE
      | TWO;
    """
    make_test text_i, text_o

  it "ternary", ()->
    text_i = """
    pragma solidity ^0.5.0;

    contract Ternary {
      function ternary() public returns (int) {
        int i = 5;
        return i < 5 ? 7 : i;
      }
    }
    """#"
    # please note that enum name should become lowercase!
    text_o = """
    type state is record
      reserved__empty_state : int;
    end;
    
    function ternary (const contractStorage : state) : (state * int) is
      block {
        const i : int = 5;
      } with (contractStorage, (case (i < 5) of | True -> 7 | False -> i end));
    """
    make_test text_i, text_o
    