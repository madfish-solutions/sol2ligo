{
  translate_ligo_make_test : make_test
} = require('./util')


describe 'translate section', ()->
  # ###################################################################################################
  #    stmt
  # ###################################################################################################
  it 'if', ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Ifer {
      uint public value;
      
      function ifer() public returns (uint) {
        uint x = 5;
        uint ret = 0;
        if (x == 5) {
          ret = value + x;
        }
        else  {
          ret = 0;
        }
        return ret;
      }
    }
    """
    text_o = """
    type state is record
      value: nat;
    end;
    
    function ifer (const contractStorage : state) : (state * nat) is
      block {
        const x : nat = 5n;
        const ret : nat = 0n;
        if (x = 5n) then block {
          ret := (contractStorage.value + x);
        } else block {
          ret := 0n;
        };
      } with (contractStorage, ret);
    
    """
    make_test text_i, text_o
  
  
  it 'while', ()->
    text_i = """
    pragma solidity ^0.5.11;

    contract Whiler {
      function whiler(address owner) public returns (int) {
        int i = 0;
        while(i < 5) {
          i += 1;
        }
        return i;
      }
    }
    """#"
    text_o = """
    type state is record
      _empty_state: int;
    end;
    
    function whiler (const contractStorage : state; const owner : address) : (state * int) is
      block {
        const i : int = 0;
        while (i < 5) block {
          i := (i + 1);
        };
      } with (contractStorage, i);
    """
    make_test text_i, text_o
  
  # ###################################################################################################
  #    for
  # ###################################################################################################
  it 'for', ()->
    text_i = """
    pragma solidity ^0.5.11;

    contract Forer {
      function forer(address owner) public returns (int) {
        int i = 0;
        for(i=2;i < 5;i+=10) {
          i += 1;
        }
        return i;
      }
    }
    """#"
    text_o = """
    type state is record
      _empty_state: int;
    end;
    
    function forer (const contractStorage : state; const owner : address) : (state * int) is
      block {
        const i : int = 0;
        i := 2;
        while (i < 5) block {
          i := (i + 1);
          i := (i + 10);
        };
      } with (contractStorage, i);
    """
    make_test text_i, text_o
  
  it 'for no init', ()->
    text_i = """
    pragma solidity ^0.5.11;

    contract Forer {
      function forer(address owner) public returns (int) {
        int i = 0;
        for(;i < 5;i+=10) {
          i += 1;
        }
        return i;
      }
    }
    """#"
    text_o = """
    type state is record
      _empty_state: int;
    end;
    
    function forer (const contractStorage : state; const owner : address) : (state * int) is
      block {
        const i : int = 0;
        while (i < 5) block {
          i := (i + 1);
          i := (i + 10);
        };
      } with (contractStorage, i);
    """
    make_test text_i, text_o
  
  it 'for no cond', ()->
    text_i = """
    pragma solidity ^0.5.11;

    contract Forer {
      function forer(address owner) public returns (int) {
        int i = 0;
        for(i=2;;i+=10) {
          i += 1;
        }
        return i;
      }
    }
    """#"
    text_o = """
    type state is record
      _empty_state: int;
    end;
    
    function forer (const contractStorage : state; const owner : address) : (state * int) is
      block {
        const i : int = 0;
        i := 2;
        while (True) block {
          i := (i + 1);
          i := (i + 10);
        };
      } with (contractStorage, i);
    """
    make_test text_i, text_o
  
  it 'for no iter', ()->
    text_i = """
    pragma solidity ^0.5.11;

    contract Forer {
      function forer(address owner) public returns (int) {
        int i = 0;
        for(i=2;i < 5;) {
          i += 1;
        }
        return i;
      }
    }
    """#"
    text_o = """
    type state is record
      _empty_state: int;
    end;
    
    function forer (const contractStorage : state; const owner : address) : (state * int) is
      block {
        const i : int = 0;
        i := 2;
        while (i < 5) block {
          i := (i + 1);
        };
      } with (contractStorage, i);
    """
    make_test text_i, text_o
  # ###################################################################################################
  #    fn call
  # ###################################################################################################
  
  it 'fn call', ()->
    text_i = """
    pragma solidity ^0.5.11;

    contract Call {
      function call_me(int a) public returns (int) {
        return a;
      }
      function test(int a) public returns (int) {
        return call_me(a);
      }
    }
    """#"
    text_o = """
    type state is record
      _empty_state: int;
    end;
    
    function call_me (const contractStorage : state; const a : int) : (state * int) is
      block {
        skip
      } with (contractStorage, a);
    
    function test (const contractStorage : state; const a : int) : (state * int) is
      block {
        const tmp_0 : (state * int) = call_me(contractStorage, a);
        contractStorage := tmp_0.0;
      } with (contractStorage, tmp_0.1);
    """
    make_test text_i, text_o