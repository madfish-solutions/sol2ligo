config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
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
      #{config.reserved}__empty_state : int;
    end;
    
    function test (const contractStorage : state) : (state) is
      block {
        const value_bool : bool = False;
        const value_int : int = 0;
        const value_uint : nat = 0n;
        const value_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
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
      #{config.reserved}__sender : address;
      value : nat;
      time : nat;
    end;
    
    function test (const contractStorage : state) : (state) is
      block {
        contractStorage.#{config.reserved}__sender := sender;
        contractStorage.value := (amount / 1tz);
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
      #{config.reserved}__empty_state : int;
    end;
    
    function test (const contractStorage : state) : (state) is
      block {
        const #{config.reserved}__#{config.contract_storage} : nat = 1n;
        const a : nat = #{config.reserved}__#{config.contract_storage};
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
      #{config.reserved}__empty_state : int;
    end;
    
    function test (const contractStorage : state; const #{config.reserved}__#{config.contract_storage} : nat) : (state) is
      block {
        const a : nat = #{config.reserved}__#{config.contract_storage};
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
      #{config.reserved}__#{config.contract_storage} : nat;
    end;
    
    function test (const contractStorage : state) : (state) is
      block {
        const a : nat = contractStorage.#{config.reserved}__#{config.contract_storage};
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
      #{config.fix_underscore}__hi : nat;
    end;
    """#"
    make_test text_i, text_o
  
  it "address(this).balance"
  it "blockhash(block.number - 1)"
  
  # ###################################################################################################
  #    expr
  # ###################################################################################################
  it "uint un_ops", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Expr {
      uint public value;
      
      function expr() public returns (uint) {
        uint a = 0;
        uint c = 0;
        c = ~a;
        c = uint(~0);
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
          const c : nat = 0n;
          c := abs(not (a));
          c := abs(not (0));
        } with (contractStorage, c);
    """
    make_test text_i, text_o
  
  it "uint bin_ops", ()->
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
  
  it "int un_ops", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Expr {
      uint public value;
      
      function expr() public returns (int) {
        int a = 0;
        int c = 0;
        c = ~a;
        c = int(~0);
        return c;
      }
    }
    """#"
    text_o = """
      type state is record
        value : nat;
      end;
      
      function expr (const contractStorage : state) : (state * int) is
        block {
          const a : int = 0;
          const c : int = 0;
          c := not (a);
          c := int(abs(not (0)));
        } with (contractStorage, c);
    """
    make_test text_i, text_o
  # TODO support mod & | ^ LATER
  # it "int bin_ops", ()->
  #   text_i = """
  #   pragma solidity ^0.5.11;
  #   
  #   contract Expr {
  #     int public value;
  #     
  #     function expr() public returns (int) {
  #       int a = 0;
  #       int b = 0;
  #       int c = 0;
  #       c = -c;
  #       c = a + b;
  #       c = a - b;
  #       c = a * b;
  #       c = a / b;
  #       c = a % b;
  #       c = a & b;
  #       c = a | b;
  #       c = a ^ b;
  #       c += b;
  #       c -= b;
  #       c *= b;
  #       c /= b;
  #       c %= b;
  #       c &= b;
  #       c |= b;
  #       c ^= b;
  #       return c;
  #     }
  #   }
  #   """#"
  #   text_o = """
  #     type state is record
  #       value : int;
  #     end;
  #     
  #     function expr (const contractStorage : state) : (state * int) is
  #       block {
  #         const a : int = 0;
  #         const b : int = 0;
  #         const c : int = 0;
  #         c := -(c);
  #         c := (a + b);
  #         c := (a - b);
  #         c := (a * b);
  #         c := (a / b);
  #         c := (a mod b);
  #         c := bitwise_and(a, b);
  #         c := bitwise_or(a, b);
  #         c := bitwise_xor(a, b);
  #         c := (c + b);
  #         c := (c - b);
  #         c := (c * b);
  #         c := (c / b);
  #         c := (c mod b);
  #         c := bitwise_and(c, b);
  #         c := bitwise_or(c, b);
  #         c := bitwise_xor(c, b);
  #       } with (contractStorage, c);
  #     
  #   """
  #   make_test text_i, text_o
  # 
  it "int bin_ops", ()->
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
        c += b;
        c -= b;
        c *= b;
        c /= b;
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
          c := (c + b);
          c := (c - b);
          c := (c * b);
          c := (c / b);
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
      #{config.reserved}__empty_state : int;
    end;
    
    type sampleStruct is record
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
      #{config.reserved}__empty_state : int;
    end;
    
    type someData is
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
      #{config.reserved}__empty_state : int;
    end;
    
    function ternary (const contractStorage : state) : (state * int) is
      block {
        const i : int = 5;
      } with (contractStorage, (case (i < 5) of | True -> 7 | False -> i end));
    """
    make_test text_i, text_o
    
  it "typecasts", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract TypeCast {
      function castType() public {
        uint u = uint(-1);
        int i = int(255);
        address addr = address(0);
      }
    }
    """#"
    text_o = """
    type state is record
      #{config.reserved}__empty_state : int;
    end;
    
    function castType (const contractStorage : state) : (state) is
      block {
        const u : nat = abs(-(1));
        const i : int = int(abs(255));
        const addr : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
      } with (contractStorage);
    """#"
    make_test text_i, text_o

  it "new-keyword", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract NewKeyword {
      function newKeyword() public {
        uint tokenCount = 4;
        bytes memory emptyBytes = new bytes(0);
        uint[] memory newArray = new uint[](tokenCount);
      }
    }
    """#"
    text_o = """
    type state is record
      reserved__empty_state : int;
    end;

    function newKeyword (const contractStorage : state) : (state) is
      block {
        const tokenCount : nat = 4n;
        const emptyBytes : bytes = bytes_pack(unit) (* args: 0 *);
        const newArray : map(nat, nat) = map end (* args: tokenCount *);
      } with (contractStorage);
    """#"
    make_test text_i, text_o
  
  it "this", ()->
    translate = (name)->
      (config.fix_underscore.capitalize()+"_"+name).substr(0, 31)
    
    text_i = """
    pragma solidity ^0.5.0;
    
    contract This_test {
      address owner;
      
      function _transferOwnership(address newOwner) public {
        owner = newOwner;
        this;
      }
      
      function transferOwnership(address newOwner) public {
        this._transferOwnership(newOwner);
        owner = address(this);
      }
    }
    
    """#"
    text_o = """
    type state is record
      owner : address;
      #{config.reserved}__initialized : bool;
    end;
    
    type #{config.fix_underscore}__transferOwnership_args is record
      newOwner : address;
    end;
    
    type transferOwnership_args is record
      newOwner : address;
    end;
    
    function #{config.fix_underscore}__transferOwnership (const opList : list(operation); const contractStorage : state; const newOwner : address) : (list(operation) * state) is
      block {
        contractStorage.owner := newOwner;
      } with (opList, contractStorage);
    
    function transferOwnership (const opList : list(operation); const contractStorage : state; const newOwner : address) : (list(operation) * state) is
      block {
        const tmp_0 : (list(operation) * state) = #{config.fix_underscore}__transferOwnership(opList, contractStorage, newOwner);
        opList := tmp_0.0;
        contractStorage := tmp_0.1;
        contractStorage.owner := self_address;
      } with (opList, contractStorage);
    
    type router_enum is
      | #{translate '_transferOwnership'} of #{config.fix_underscore}__transferOwnership_args
      | TransferOwnership of transferOwnership_args;
    
    function main (const action : router_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        if (contractStorage.#{config.reserved}__initialized) then block {
          case action of
          | #{translate '_transferOwnership'}(match_action) -> block {
            const tmp_0 : (list(operation) * state) = #{config.fix_underscore}__transferOwnership(opList, contractStorage, match_action.newOwner);
            opList := tmp_0.0;
            contractStorage := tmp_0.1;
          }
          | TransferOwnership(match_action) -> block {
            const tmp_1 : (list(operation) * state) = transferOwnership(opList, contractStorage, match_action.newOwner);
            opList := tmp_1.0;
            contractStorage := tmp_1.1;
          }
          end;
        } else block {
          contractStorage.#{config.reserved}__initialized := True;
        };
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o, {
      router : true
      op_list: true
    }
    # NOTE without router self_address will not work
    
