config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section ops", ()->
  @timeout 10000
  # ###################################################################################################
  #    expr
  # ###################################################################################################
  describe "uintX un_ops", ()->
    for type in config.uint_type_list
      it "#{type} un_ops", ()->
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          #{type} public value;
          
          function expr() public returns (#{type}) {
            #{type} a = 0;
            #{type} c = 0;
            a++;
            a--;
            ++a;
            --a;
            c = a++;
            c = a--;
            c = ++a;
            c = --a;
            c = ~a;
            c = #{type}(~0);
            return c;
          }
        }
        """#"
        text_o = """
          type state is record
            value : nat;
          end;
          
          function expr (const #{config.contract_storage} : state) : (list(operation) * state * nat) is
            block {
              const a : nat = 0n;
              const c : nat = 0n;
              a := a + 1;
              a := a - 1;
              a := a + 1;
              a := a - 1;
              a := a + 1;
              c := (a - 1);
              a := a - 1;
              c := (a + 1);
              a := a + 1;
              c := a;
              a := a - 1;
              c := a;
              c := abs(not (a));
              c := abs(not (0));
            } with (list [], #{config.contract_storage}, c);
        """
        make_test text_i, text_o
  
  describe "uintX bin_ops", ()->
    for type in config.uint_type_list
      it "#{type} bin_ops", ()->
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          #{type} public value;
          
          function expr() public returns (#{type}) {
            #{type} a = 0;
            #{type} b = 0;
            #{type} c = 0;
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
          
          function expr (const #{config.contract_storage} : state) : (list(operation) * state * nat) is
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
            } with (list [], #{config.contract_storage}, c);
          
        """
        make_test text_i, text_o
    
    for type in config.uint_type_list
      it "cmp #{type}", ()->
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          #{type} public value;
          
          function expr() public returns (#{type}) {
            #{type} a = 0;
            #{type} b = 0;
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
          
          function expr (const #{config.contract_storage} : state) : (list(operation) * state * nat) is
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
            } with (list [], #{config.contract_storage}, 0n);
          
        """
        make_test text_i, text_o
  
  describe "intX un_ops", ()->
    for type in config.int_type_list
      it "#{type} un_ops", ()->
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          uint public value;
          
          function expr() public returns (#{type}) {
            #{type} a = 0;
            #{type} c = 0;
            c = ~a;
            c = #{type}(~0);
            return c;
          }
        }
        """#"
        text_o = """
          type state is record
            value : nat;
          end;
          
          function expr (const #{config.contract_storage} : state) : (list(operation) * state * int) is
            block {
              const a : int = 0;
              const c : int = 0;
              c := not (a);
              c := int(abs(not (0)));
            } with (list [], #{config.contract_storage}, c);
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
  #     function expr (const #{config.contract_storage} : state) : (list(operation) * state * int) is
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
  #       } with (list [], #{config.contract_storage}, c);
  #     
  #   """
  #   make_test text_i, text_o
  # 
  describe "intX bin_ops", ()->
    for type in config.int_type_list
      it "#{type} bin_ops", ()->
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          #{type} public value;
          
          function expr() public returns (#{type}) {
            #{type} a = 0;
            #{type} b = 0;
            #{type} c = 0;
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
          
          function expr (const #{config.contract_storage} : state) : (list(operation) * state * int) is
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
            } with (list [], #{config.contract_storage}, c);
          
        """
        make_test text_i, text_o
    
    for type in config.int_type_list
      it "cmp #{type}", ()->
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          uint public value;
          
          function expr() public returns (uint) {
            #{type} a = 0;
            #{type} b = 0;
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
          
          function expr (const #{config.contract_storage} : state) : (list(operation) * state * nat) is
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
            } with (list [], #{config.contract_storage}, 0n);
          
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
    
    function expr (const #{config.contract_storage} : state; const owner : address) : (list(operation) * state * nat) is
      block {
        skip
      } with (list [], #{config.contract_storage}, (case #{config.contract_storage}.balances[owner] of | None -> 0n | Some(x) -> x end));
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
    type state is unit;
    
    function addmulmod (const #{config.contract_storage} : state) : (list(operation) * state) is
      block {
        const x : nat = 1n;
        const y : nat = 2n;
        const z : nat = 3n;
        const a : nat = ((x + y) mod z);
        const m : nat = ((x * y) mod z);
      } with (list [], #{config.contract_storage});
    """
    make_test text_i, text_o

  it "un_op0", ()->
    text_i = """
    pragma solidity ^0.4.16;

    contract UnOpTest {
        function test1(uint256 u0) internal {
            uint256 u1 = ~u0;
            uint256 u2 = ~(~u0);
            uint256 u3 = ~u0 + u2;
            uint256 u4 = ~u3 + u2;
        }
    }"""#"
    text_o = """
    type state is unit;
    
    function test1 (const #{config.contract_storage} : state; const u0 : nat) : (state) is
      block {
        const u1 : nat = abs(not (u0));
        const u2 : nat = abs(not (abs(not (u0))));
        const u3 : nat = (abs(not (u0)) + u2);
        const u4 : nat = (abs(not (u3)) + u2);
      } with (#{config.contract_storage});
    """
    make_test text_i, text_o
  it "un_op1", ()->
    text_i = """
    pragma solidity ^0.4.16;

    contract UnOpTest {
        function test2(bool b0) internal {
            bool b1 = !b0;
            bool b2 = !!!!!b1;
        }
    }"""#"
    text_o = """
    type state is unit;
    
    function test2 (const #{config.contract_storage} : state; const b0 : bool) : (state) is
      block {
        const b1 : bool = not (b0);
        const b2 : bool = not (not (not (not (not (b1)))));
      } with (#{config.contract_storage});
    """
    make_test text_i, text_o
    