config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section unsorted", ()->
  @timeout 10000
  # ###################################################################################################
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
    type structure_SampleStruct is record
      data : nat;
    end;
    
    type state is unit;
    
    const structure_SampleStruct_default : structure_SampleStruct = record [ data = 0n ];
    
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
    type state is unit;
    
    type someData is
      | DEFAULT
     | ONE
     | TWO;
    """
    make_test text_i, text_o, replace_enums_by_nats: false

   
  it "enum to nat conversion", ()->
    text_i = """
    pragma solidity ^0.5.11;

    contract Enumeration {
      enum EnumType {DEFAULT,ONE,TWO}

      mapping (bytes32 => EnumType) private dataMap;

      function ternary() private {
        EnumType e = EnumType.ONE;
      }
    }
    """
    text_o = """
    type state is record
      dataMap : map(bytes, nat);
    end;

    const enumType_DEFAULT : nat = 0n;
    const enumType_ONE : nat = 1n;
    const enumType_TWO : nat = 2n;
    (* enum EnumType converted into list of nats *)

    function ternary (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const e : nat = enumType_ONE;
      } with (unit);
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
    type state is unit;
    
    function ternary (const #{config.reserved}__unit : unit) : (int) is
      block {
        const i : int = 5;
      } with ((case (i < 5) of | True -> 7 | False -> i end));
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
        string memory str = "123";
        bytes memory b1 = bytes(str);
      }
    }
    """#"
    text_o = """
    type state is unit;
    
    function castType (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const u : nat = abs(-(1));
        const i : int = int(abs(255));
        const addr : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
        const str : string = "123";
        const b1 : bytes = bytes_pack(str);
      } with (unit);
    """#"
    make_test text_i, text_o
  
  it "constants", ()->
      text_i = """
      pragma solidity ^0.5.11;
      contract Consttypes {
          uint256 public timesSeconds;
          uint256 public timeMinutes;
          uint256 public timeHours;
          uint256 public timeWeeks;
          uint256 public timeDays;
          uint256 public amountSzabo;
          uint256 public amountFinney;
          uint256 public amountEther;
          
          function test() public {
              timesSeconds = 100 seconds;
              timeMinutes = 12 minutes;
              timeHours = 3 weeks;
              timeWeeks = 11 hours;
              timeDays = 1 days;
              amountSzabo = 12 szabo;
              amountFinney = 3 finney;
              amountEther = 11 ether;
          }
      }
      """#"
      text_o = """
      type state is record
        timesSeconds : nat;
        timeMinutes : nat;
        timeHours : nat;
        timeWeeks : nat;
        timeDays : nat;
        amountSzabo : nat;
        amountFinney : nat;
        amountEther : nat;
      end;
      
      function test (const #{config.contract_storage} : state) : (state) is
        block {
          #{config.contract_storage}.timesSeconds := 100n;
          #{config.contract_storage}.timeMinutes := (12n * 60n);
          #{config.contract_storage}.timeHours := (3n * 604800n);
          #{config.contract_storage}.timeWeeks := (11n * 3600n);
          #{config.contract_storage}.timeDays := (1n * 86400n);
          #{config.contract_storage}.amountSzabo := 12n;
          #{config.contract_storage}.amountFinney := (3n * 1000n);
          #{config.contract_storage}.amountEther := (11n * 1000000n);
        } with (#{config.contract_storage});
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
    type state is unit;
    
    function newKeyword (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const tokenCount : nat = 4n;
        const emptyBytes : bytes = ("00": bytes) (* args: 0 *);
        const newArray : map(nat, nat) = map end (* args: tokenCount *);
      } with (unit);
    """#"
    make_test text_i, text_o
  
  it "return-tuple", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract TupleRet {
      function tupleRet() public pure returns (uint, bool) {
        return (7, true);
      }
    }
    """#"
    text_o = """
    type state is unit;
    
    function tupleRet (const #{config.reserved}__unit : unit) : ((nat * bool)) is
      block {
        skip
      } with ((7n, True));
    """#"
    make_test text_i, text_o
  
  # ###################################################################################################
  it "this (BAD vertical alignment)", ()->
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
    ###
      THIS was more correct
        const tmp_0 : (list(operation) * state) = #{config.fix_underscore}__transferOwnership(opList, #{config.contract_storage}, newOwner);
        opList := tmp_0.0;
        #{config.contract_storage} := tmp_0.1;
    ###
    
    text_o = """
    type transferOwnership__args is record
      newOwner : address;
    end;
    
    type transferOwnership_args is record
      newOwner : address;
    end;
    
    type state is record
      owner : address;
    end;
    
    type router_enum is
      | TransferOwnership_ of transferOwnership__args
     | TransferOwnership of transferOwnership_args;
    
    function transferOwnership_ (const #{config.contract_storage} : state; const newOwner : address) : (state) is
      block {
        #{config.contract_storage}.owner := newOwner;
      } with (#{config.contract_storage});
    
    function transferOwnership (const #{config.contract_storage} : state; const newOwner : address) : (state) is
      block {
        #{config.contract_storage} := transferOwnership_(#{config.contract_storage}, newOwner);
        #{config.contract_storage}.owner := self_address;
      } with (#{config.contract_storage});
    
    function main (const action : router_enum; const #{config.contract_storage} : state) : (list(operation) * state) is
      (case action of
      | TransferOwnership_(match_action) -> ((nil: list(operation)), transferOwnership_(#{config.contract_storage}, match_action.newOwner))
      | TransferOwnership(match_action) -> ((nil: list(operation)), transferOwnership(#{config.contract_storage}, match_action.newOwner))
      end);
    """#"
    make_test text_i, text_o, {
      router : true
    }
    # NOTE without router self_address will not work
  
  it "this.prop()", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Expr {
      uint public ret;
      
      function getRet() public view returns (uint ret_val) {
        ret_val = this.ret();
      }
    }
    """
    text_o = """
    type state is record
      ret : nat;
    end;
    
    function getRet (const #{config.contract_storage} : state) : (nat) is
      block {
        const ret_val : nat = 0n;
        ret_val := #{config.contract_storage}.ret;
      } with (ret_val);
    """
    make_test text_i, text_o
  