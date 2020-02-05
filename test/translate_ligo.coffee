config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
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
    
    function ternary (const opList : list(operation); const contractStorage : state) : (list(operation) * state * int) is
      block {
        const i : int = 5;
      } with (opList, contractStorage, (case (i < 5) of | True -> 7 | False -> i end));
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
    
    function castType (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const u : nat = abs(-(1));
        const i : int = int(abs(255));
        const addr : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
      } with (opList, contractStorage);
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
    
    function newKeyword (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const tokenCount : nat = 4n;
        const emptyBytes : bytes = bytes_pack(unit) (* args: 0 *);
        const newArray : map(nat, nat) = map end (* args: tokenCount *);
      } with (opList, contractStorage);
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
    type state is record
      reserved__empty_state : int;
    end;
    
    function tupleRet (const reserved__unit : unit) : ((nat * bool)) is
      block {
        skip
      } with ((7n, True));
    """#"
    make_test text_i, text_o
  
  # ###################################################################################################
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
    }
    # NOTE without router self_address will not work
  
  