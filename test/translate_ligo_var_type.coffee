config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section var type", ()->
  @timeout 10000
  # ###################################################################################################
  #    basic types
  # ###################################################################################################
  it "basic types", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Basic_types {
      bool  public value_bool  ;
      int   public value_int   ;
      uint  public value_uint  ;
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
      value_address : address;
      value_string : string;
    end;
    
    function test (const #{config.reserved}__unit : unit) : (unit) is
      block {
        skip
      } with (unit);
    
    """
    make_test text_i, text_o
  it "extended types", ()->
    text_i = """
    pragma solidity ^0.5.11;

    contract Basic_types {
        int8 public value_int8;
        int16 public value_int16;
        int160 public value_int160;
        int256 public value_int256;
        uint8 public value_uint8;
        uint16 public value_uint16;
        uint160 public value_uint160;
        uint256 public value_uint256;
        byte public value_byte;
        bytes public value_bytes;
        bytes8 public value_bytes8;
        bytes16 public value_bytes16;
        bytes32 public value_bytes32;

        function test() public {}
    }
    """
    text_o = """
    type state is record
      value_int8 : int;
      value_int16 : int;
      value_int160 : int;
      value_int256 : int;
      value_uint8 : nat;
      value_uint16 : nat;
      value_uint160 : nat;
      value_uint256 : nat;
      value_byte : bytes;
      value_bytes : bytes;
      value_bytes8 : bytes;
      value_bytes16 : bytes;
      value_bytes32 : bytes;
    end;
    
    function test (const #{config.reserved}__unit : unit) : (unit) is
      block {
        skip
      } with (unit);
    
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
    type state is unit;
    
    const burn_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    
    function test (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const value_bool : bool = False;
        const value_int : int = 0;
        const value_uint : nat = 0n;
        const value_address : address = burn_address;
        const value_string : string = "";
      } with (unit);
    
    """#"
    make_test text_i, text_o
  
  it "int8/uint8 default value"
  it "true/false"
  it "string escaping"
  # ###################################################################################################
  #    var
  # ###################################################################################################
  it "var uint", ()->
    text_i = """
    pragma solidity ^0.4.22;
    
    contract Math_example {
      function test() public {
        var n = 1;
      }
    }
    """
    text_o = """
    type state is unit;
    
    function test (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const n : nat = 1n;
      } with (unit);
    """#"
    make_test text_i, text_o
  
  it "var int", ()->
    text_i = """
    pragma solidity ^0.4.22;
    
    contract Math_example {
      function test() public {
        var n = -1;
      }
    }
    """
    text_o = """
    type state is unit;
    
    function test (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const n : int = -(1);
      } with (unit);
    """#"
    make_test text_i, text_o
  
  it "var string", ()->
    text_i = """
    pragma solidity ^0.4.22;
    
    contract Math_example {
      function test() public {
        var n = "1";
      }
    }
    """
    text_o = """
    type state is unit;
    
    function test (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const n : string = "1";
      } with (unit);
    """#"
    make_test text_i, text_o
  
  # ###################################################################################################
  
  it "globals", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Globals {
      address public sender;
      address public source;
      uint public value;
      bytes public data;
      uint public time;
      uint public timestamp;
      
      function test() public payable {
        sender = msg.sender;
        source = tx.origin;
        value = msg.value;
        data = msg.data;
        time = now;
        timestamp = block.timestamp;
      }
    }
    """
    text_o = """
    type state is record
      #{config.reserved}__sender : address;
      #{config.reserved}__source : address;
      value : nat;
      data : bytes;
      time : nat;
      timestamp : nat;
    end;
    
    function test (const contract_storage : state) : (state) is
      block {
        contract_storage.#{config.reserved}__sender := Tezos.sender;
        contract_storage.#{config.reserved}__source := Tezos.source;
        contract_storage.value := (amount / 1mutez);
        contract_storage.data := ("00": bytes);
        contract_storage.time := abs(now - (\"1970-01-01T00:00:00Z\" : timestamp));
        contract_storage.timestamp := abs(now - (\"1970-01-01T00:00:00Z\" : timestamp));
      } with (contract_storage);
    
    """#"
    make_test text_i, text_o
  
  it "self conflict local", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Globals {
      function test() public payable {
        uint self = 1;
        uint a = self;
      }
    }
    """
    text_o = """
    type state is unit;
    
    function test (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const #{config.reserved}__self : nat = 1n;
        const a : nat = #{config.reserved}__self;
      } with (unit);
    
    """#"
    make_test text_i, text_o
  
  it "self conflict arg", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Globals {
      function test(uint self) public payable {
        uint a = self;
      }
    }
    """
    text_o = """
    type state is unit;
    
    function test (const #{config.reserved}__self : nat) : (unit) is
      block {
        const a : nat = #{config.reserved}__self;
      } with (unit);
    
    """#"
    make_test text_i, text_o
  
  it "self conflict state", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Globals {
      uint self;
      function test() public payable {
        uint a = self;
      }
    }
    """
    text_o = """
    type state is record
      #{config.reserved}__self : nat;
    end;
    
    function test (const contract_storage : state) : (unit) is
      block {
        const a : nat = contract_storage.#{config.reserved}__self;
      } with (unit);
    
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
      hi_ : nat;
    end;
    """#"
    make_test text_i, text_o
  
  it "address(this).balance"
  it "blockhash(block.number - 1)"
  
  it "bytes memory", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    contract Globals {
      function test() public {
        bytes  memory bts0;
        bytes1 bts1;
      }
      
    }
    """#"
    text_o = """
    type state is unit;
    
    function test (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const bts0 : bytes = ("00": bytes);
        const bts1 : bytes = ("00": bytes);
      } with (unit);
    """#"
    make_test text_i, text_o
  
  it "bytes + string assign", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    contract Globals {
      function test() public {
        bytes  memory bts0 = hex"00010203";
        bytes1 bts1 = hex"00";
        var    bts2 = bts0;
        bts2 = hex"00";
      }
    }
    """#"
    text_o = """
    type state is unit;
    
    function test (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const bts0 : bytes = 0x00010203;
        const bts1 : bytes = 0x00;
        const bts2 : bytes = bts0;
        bts2 := 0x00;
      } with (unit);
    """#"
    make_test text_i, text_o

  it "cast to address from bytes and uint", ()->
    text_i = """
    pragma solidity ^0.4.16;

    contract eee {
      function foo(address arg) returns (address) {
          return arg;
      }
      
      function bar() public {
          address a = 0x01;
          address b = 4242;

          if (a == 0x01) {
              b = foo(0x02);
          }
      }
    }
    """#"
    text_o = """
    type state is unit;
    
    function foo (const arg : address) : (address) is
      block {
        skip
      } with (arg);

    function bar (const test_reserved_long___unit : unit) : (unit) is
      block {
        const a : address = ("PLEASE_REPLACE_ETH_ADDRESS_0x01_WITH_A_TEZOS_ADDRESS" : address);
        const b : address = ("PLEASE_REPLACE_ETH_ADDRESS_4242_WITH_A_TEZOS_ADDRESS" : address);
        if (a = ("PLEASE_REPLACE_ETH_ADDRESS_0x01_WITH_A_TEZOS_ADDRESS" : address)) then block {
          b := foo(("PLEASE_REPLACE_ETH_ADDRESS_0x02_WITH_A_TEZOS_ADDRESS" : address));
        } else block {
          skip
        };
      } with (unit);
    """#"
    make_test text_i, text_o

  