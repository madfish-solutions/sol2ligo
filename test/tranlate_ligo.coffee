assert = require 'assert'
ast_gen             = require('../src/ast_gen')
solidity_to_ast4gen = require('../src/solidity_to_ast4gen').gen
ast_transform       = require('../src/ast_transform')
type_inference      = require('../src/type_inference').gen
translate           = require('../src/translate_ligo').gen

make_test = (text_i, text_o_expected)->
  solidity_ast = ast_gen text_i, silent:true
  ast = solidity_to_ast4gen solidity_ast
  ast = ast_transform.ligo_pack ast
  ast = type_inference ast
  text_o_real     = translate ast,
    router : false
  text_o_expected = text_o_expected.trim()
  text_o_real     = text_o_real.trim()
  assert.strictEqual text_o_real, text_o_expected


describe 'translate section', ()->
  # ###################################################################################################
  #    basic
  # ###################################################################################################
  it 'hello world', ()->
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
      value: nat;
    end;
    
    function test (const contractStorage : state) : (state) is
      block {
        contractStorage.value := 1n;
      } with (contractStorage);
    
    """
    make_test text_i, text_o
  
  it 'basic types', ()->
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
      value_bool: bool;
      value_int: int;
      value_uint: nat;
      value_int8: int;
      value_uint8: nat;
      value_address: address;
      value_string: string;
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
  
  # ###################################################################################################
  #    expr
  # ###################################################################################################
  it 'uint ops', ()->
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
        value: nat;
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
  
  it 'int ops', ()->
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
        value: int;
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
  
  it 'a[b]', ()->
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
      balances: map(address, nat);
    end;
    
    function expr (const contractStorage : state; const owner : address) : (state * nat) is
      block {
        skip
      } with (contractStorage, (case contractStorage.balances[owner] of | None -> 0n | Some(x) -> x end));
    """
    make_test text_i, text_o
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
        while (true) block {
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