config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section array", ()->
  @timeout 10000
  # https://github.com/madfish-solutions/Solidity-Dry-Runner/blob/master/contracts/Arrays.ligo
  # https://github.com/madfish-solutions/Solidity-Dry-Runner/blob/master/contracts/Arrays.sol
  # ###################################################################################################
  #    array
  # ###################################################################################################
  it "dynamic array", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Array {
      int[] public storageArray;
      
      function array() public returns (uint) {
        return 0;
      }
    }
    """
    text_o = """
    type state is record
      storageArray : map(nat, int);
    end;
    
    function array (const #{config.reserved}__unit : unit) : (nat) is
      block {
        skip
      } with (0n);
    
    """
    make_test text_i, text_o
  
  it "static array", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Array {
      int[10] public storageArray;
      
      function array() public returns (uint) {
        return 0;
      }
    }
    """
    text_o = """
    type state is record
      storageArray : map(nat, int);
    end;
    
    function array (const #{config.reserved}__unit : unit) : (nat) is
      block {
        skip
      } with (0n);
    
    """
    make_test text_i, text_o
  
  it "dynamic length", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Array {
      int[] public storageArray;
      
      function array() public returns (uint) {
        return storageArray.length;
      }
    }
    """
    text_o = """
    type state is record
      storageArray : map(nat, int);
    end;
    
    function array (const #{config.contract_storage} : state) : (nat) is
      block {
        skip
      } with (size(#{config.contract_storage}.storageArray));
    
    """
    make_test text_i, text_o
  
  it "static length", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Array {
      int[10] public storageArray;
      
      function array() public returns (uint) {
        return storageArray.length;
      }
    }
    """
    text_o = """
    type state is record
      storageArray : map(nat, int);
    end;
    
    function array (const #{config.contract_storage} : state) : (nat) is
      block {
        skip
      } with (size(#{config.contract_storage}.storageArray));
    
    """
    make_test text_i, text_o
  
  it "push element", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Array {
      int[] public storageArray;
      
      function array() public returns (uint) {
        storageArray.push(0);
        return 0;
      }
    }
    """
    text_o = """
    type state is record
      storageArray : map(nat, int);
    end;
    
    function array (const #{config.contract_storage} : state) : (state * nat) is
      block {
        const tmp_0 : map(nat, int) = #{config.contract_storage}.storageArray;
        tmp_0[size(tmp_0)] := 0;
      } with (#{config.contract_storage}, 0n);
    
    """
    make_test text_i, text_o

  it "inline array", ()->
    text_i = """
    pragma solidity ^0.4.20;

    contract Expr {
        int256[] arr;

        function expr() public {
            uint8[1] memory memArr = [0];
            arr = [0];
        }
    }
    """
    text_o = """
    type state is record
      arr : map(nat, int);
    end;

    function expr (const #{config.contract_storage} : state) : (state) is
      block {
        const memArr : map(nat, nat) = map
          0n -> 0n;
        end;
        #{config.contract_storage}.arr := map
          0n -> 0;
        end;
      } with (#{config.contract_storage});
    """
    make_test text_i, text_o

  it "inline arrays", ()->
    text_i = """
    pragma solidity ^0.4.24;
    
    contract Expr {
        function expr() public {
            uint8[5] memory foo1 = [0, 0, 0, 0, 0];
            int256[5] memory foo2 = [int256(1), 0, 0, 0, 0];
            int256[5] memory foo3 = [
                int256(1),
                int256(-1),
                int256(0),
                int256(0),
                int256(0)
            ];
            int8[5] memory foo4 = [int8(0), int8(0), int8(0), int8(0), int8(0)];
        }
    }
    """
    text_o = """
    type state is unit;

    function expr (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const foo1 : map(nat, nat) = map
          0n -> 0n;
          1n -> 0n;
          2n -> 0n;
          3n -> 0n;
          4n -> 0n;
        end;
        const foo2 : map(nat, int) = map
          0n -> int(abs(1));
          1n -> 0;
          2n -> 0;
          3n -> 0;
          4n -> 0;
        end;
        const foo3 : map(nat, int) = map
          0n -> int(abs(1));
          1n -> int(abs(-(1)));
          2n -> int(abs(0));
          3n -> int(abs(0));
          4n -> int(abs(0));
        end;
        const foo4 : map(nat, int) = map
          0n -> int(abs(0));
          1n -> int(abs(0));
          2n -> int(abs(0));
          3n -> int(abs(0));
          4n -> int(abs(0));
        end;
      } with (unit);
    """
    make_test text_i, text_o
  
  it "delete element", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Array {
      int[] public storageArray;
      
      function array() public returns (uint) {
        delete storageArray[0];
        return 0;
      }
    }
    """
    text_o = """
    type state is record
      storageArray : map(nat, int);
    end;
    
    function array (const #{config.contract_storage} : state) : (state * nat) is
      block {
        remove 0n from map #{config.contract_storage}.storageArray;
      } with (#{config.contract_storage}, 0n);
    
    """
    make_test text_i, text_o
  
  it "inline-array", ()->
    text_i = """
    pragma solidity ^0.5.11;
        
    contract InlineArray {
      function inlineArray() public {
        uint[3] memory temp = [uint(1),2,3];
      }
    }
    """
    text_o = """
    type state is unit;
    
    function inlineArray (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const temp : map(nat, nat) = map
          0n -> abs(1);
          1n -> 2n;
          2n -> 3n;
        end;
      } with (unit);
    """
    make_test text_i, text_o
