config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
  @timeout 10000
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
      
      function expr (const opList : list(operation); const contractStorage : state) : (list(operation) * state * nat) is
        block {
          const a : nat = 0n;
          const c : nat = 0n;
          c := abs(not (a));
          c := abs(not (0));
        } with (opList, contractStorage, c);
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
      
      function expr (const opList : list(operation); const contractStorage : state) : (list(operation) * state * nat) is
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
        } with (opList, contractStorage, c);
      
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
      
      function expr (const opList : list(operation); const contractStorage : state) : (list(operation) * state * int) is
        block {
          const a : int = 0;
          const c : int = 0;
          c := not (a);
          c := int(abs(not (0)));
        } with (opList, contractStorage, c);
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
  #     function expr (const opList : list(operation); const contractStorage : state) : (list(operation) * state * int) is
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
  #       } with (opList, contractStorage, c);
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
      
      function expr (const opList : list(operation); const contractStorage : state) : (list(operation) * state * int) is
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
        } with (opList, contractStorage, c);
      
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
      
      function expr (const opList : list(operation); const contractStorage : state) : (list(operation) * state * nat) is
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
        } with (opList, contractStorage, 0n);
      
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
      
      function expr (const opList : list(operation); const contractStorage : state) : (list(operation) * state * nat) is
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
        } with (opList, contractStorage, 0n);
      
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
    
    function expr (const opList : list(operation); const contractStorage : state; const owner : address) : (list(operation) * state * nat) is
      block {
        skip
      } with (opList, contractStorage, (case contractStorage.balances[owner] of | None -> 0n | Some(x) -> x end));
    """
    make_test text_i, text_o
  
  it "addmulmod", ()->
    text_i = """
    pragma solidity ^0.5.11;
    contract AddMulMod {
      function addmulmod() public {
        uint x = 1;
        uint y = 2;
        uint z = 3;
        uint a = addmod(x,y,z);
        uint m = mulmod(x,y,z);
      }
    }"""#"
    text_o = """
    type state is record
      reserved__empty_state : int;
    end;
    
    function addmulmod (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const x : nat = 1n;
        const y : nat = 2n;
        const z : nat = 3n;
        const a : nat = ((x + y) mod z);
        const m : nat = ((x * y) mod z);
      } with (opList, contractStorage);
    """
    make_test text_i, text_o