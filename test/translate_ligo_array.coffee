config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
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
    
    function array (const opList : list(operation); const contractStorage : state) : (list(operation) * state * nat) is
      block {
        skip
      } with (opList, contractStorage, 0n);
    
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
    
    function array (const opList : list(operation); const contractStorage : state) : (list(operation) * state * nat) is
      block {
        skip
      } with (opList, contractStorage, 0n);
    
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
    
    function array (const opList : list(operation); const contractStorage : state) : (list(operation) * state * nat) is
      block {
        skip
      } with (opList, contractStorage, size(contractStorage.storageArray));
    
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
    
    function array (const opList : list(operation); const contractStorage : state) : (list(operation) * state * nat) is
      block {
        skip
      } with (opList, contractStorage, size(contractStorage.storageArray));
    
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
    
    function array (const opList : list(operation); const contractStorage : state) : (list(operation) * state * nat) is
      block {
        const tmp_0 : map(nat, int) = contractStorage.storageArray;
        tmp_0[size(tmp_0)] := 0;
      } with (opList, contractStorage, 0n);
    
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
    
    function array (const opList : list(operation); const contractStorage : state) : (list(operation) * state * nat) is
      block {
        remove 0n from map contractStorage.storageArray;
      } with (opList, contractStorage, 0n);
    
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
    type state is record
      #{config.empty_state} : int;
    end;
    
    function inlineArray (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const temp : map(nat, nat) = map
          0n -> abs(1);
          1n -> 2n;
          2n -> 3n;
        end;
      } with (opList, contractStorage);
    """
    make_test text_i, text_o
