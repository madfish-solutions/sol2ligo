{
  translate_ligo_make_test : make_test
} = require('./util')

describe 'translate section', ()->
  # https://github.com/madfish-solutions/Solidity-Dry-Runner/blob/master/contracts/Arrays.ligo
  # https://github.com/madfish-solutions/Solidity-Dry-Runner/blob/master/contracts/Arrays.sol
  # ###################################################################################################
  #    array
  # ###################################################################################################
  it 'dynamic array', ()->
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
      storageArray: map(nat, int);
    end;
    
    function array (const contractStorage : state) : (state * nat) is
      block {
        skip
      } with (contractStorage, 0);
    
    """
    make_test text_i, text_o
  
  it 'static array', ()->
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
      storageArray: map(nat, int);
    end;
    
    function array (const contractStorage : state) : (state * nat) is
      block {
        skip
      } with (contractStorage, 0);
    
    """
    make_test text_i, text_o
  
  it 'dynamic length', ()->
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
      storageArray: map(nat, int);
    end;
    
    function array (const contractStorage : state) : (state * nat) is
      block {
        skip
      } with (contractStorage, size(contractStorage.storageArray));
    
    """
    make_test text_i, text_o
  
  
  it 'static length', ()->
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
      storageArray: map(nat, int);
    end;
    
    function array (const contractStorage : state) : (state * nat) is
      block {
        skip
      } with (contractStorage, size(contractStorage.storageArray));
    
    """
    make_test text_i, text_o
  