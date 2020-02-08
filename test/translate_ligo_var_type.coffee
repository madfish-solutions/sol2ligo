config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
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
    
    function test (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
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
    
    function test (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
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
      #{config.reserved}__empty_state : int;
    end;
    
    function test (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const value_bool : bool = False;
        const value_int : int = 0;
        const value_uint : nat = 0n;
        const value_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
        const value_string : string = "";
      } with (opList, contractStorage);
    
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
    type state is record
      reserved__empty_state : int;
    end;
    
    function test (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const n : nat = 1n;
      } with (opList, contractStorage);
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
    type state is record
      reserved__empty_state : int;
    end;
    
    function test (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const n : int = -(1);
      } with (opList, contractStorage);
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
    type state is record
      reserved__empty_state : int;
    end;
    
    function test (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const n : string = "1";
      } with (opList, contractStorage);
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
    
    function test (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        contractStorage.#{config.reserved}__sender := sender;
        contractStorage.#{config.reserved}__source := source;
        contractStorage.value := (amount / 1mutez);
        contractStorage.data := bytes_pack(unit);
        contractStorage.time := abs(now - (\"1970-01-01T00:00:00Z\": timestamp));
        contractStorage.timestamp := abs(now - (\"1970-01-01T00:00:00Z\": timestamp));
      } with (opList, contractStorage);
    
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
      #{config.reserved}__empty_state : int;
    end;
    
    function test (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const #{config.reserved}__#{config.contract_storage} : nat = 1n;
        const a : nat = #{config.reserved}__#{config.contract_storage};
      } with (opList, contractStorage);
    
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
      #{config.reserved}__empty_state : int;
    end;
    
    function test (const opList : list(operation); const contractStorage : state; const #{config.reserved}__#{config.contract_storage} : nat) : (list(operation) * state) is
      block {
        const a : nat = #{config.reserved}__#{config.contract_storage};
      } with (opList, contractStorage);
    
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
      #{config.reserved}__#{config.contract_storage} : nat;
    end;
    
    function test (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const a : nat = contractStorage.#{config.reserved}__#{config.contract_storage};
      } with (opList, contractStorage);
    
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
      #{config.fix_underscore}__hi : nat;
    end;
    """#"
    make_test text_i, text_o
  
  it "address(this).balance"
  it "blockhash(block.number - 1)"
  
