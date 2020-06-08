config = require "../src/config"
assert = require "assert"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section ops", ()->
  @timeout 10000
  # ###################################################################################################
  #    expr
  # ###################################################################################################
  describe "uintX un_ops emulator", ()->
    for type in config.uint_type_list
      it "#{type} un_ops", (on_end)->
        @timeout 30000
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          #{type} public ret;
          
          function expr() public {
            #{type} a = 0;
            #{type} c = 0;
            a++;
            a--;
            ++a;
            --a;
            c = ~a;
            c = #{type}(~0);
            c = a++;
            c = a--;
            c = ++a;
            c = --a;
            ret = c;
          }
          function getRet() public view returns (#{type} ret_val) {
            ret_val = ret;
          }
        }
        """#"
        text_o = """
          type state is record
            ret : nat;
          end;
          
          function expr (const #{config.contract_storage} : state) : (list(operation) * state) is
            block {
              const a : nat = 0n;
              const c : nat = 0n;
              a := a + 1n;
              a := abs(a - 1n);
              a := a + 1n;
              a := abs(a - 1n);
              c := abs(not (a));
              c := abs(not (0));
              a := a + 1n;
              c := abs(a - 1n);
              a := abs(a - 1n);
              c := (a + 1n);
              a := a + 1n;
              c := a;
              a := abs(a - 1n);
              c := a;
              #{config.contract_storage}.ret := c;
            } with ((nil: list(operation)), #{config.contract_storage});
          
          function getRet (const self : state; const receiver : contract(nat)) : (list(operation)) is
            block {
              const ret_val : nat = 0n;
              ret_val := self.ret;
              var opList : list(operation) := list transaction((ret_val), 0mutez, receiver) end;
            } with (opList);
        """
        make_test text_i, text_o
        if process.env.EMULATOR
          await make_emulator_test {
            sol_code      : text_i
            contract_name : "Expr"
            ligo_arg      : '"Expr"'
            ligo_state    : "record ret = 100n; end"
            sol_test_fn   : (contract, on_end)->
              await contract.expr().cb defer(err, result); return on_end err if err
              await contract.getRet.call().cb defer(err, result); return on_end err if err
              
              try
                assert.strictEqual result.toNumber(), 0
              catch err
                return on_end err
              on_end()
            ligo_test_fn  : (res, on_end)->
              try
                assert.strictEqual +res, 0
              catch err
                return on_end err
              on_end()
          }, defer(err); return on_end err if err
        on_end()
    
    if process.env.EMULATOR
      it "uint a++", (on_end)->
        @timeout 30000
        text_i = """
          pragma solidity ^0.5.11;
          
          contract Expr {
            uint public ret;
            
            function expr() public {
              uint a = 100;
              uint c = 0;
              ret = a++;
            }
            function getRet() public view returns (uint ret_val) {
              ret_val = ret;
            }
          }
          """#"
        make_emulator_test {
          sol_code      : text_i
          contract_name : "Expr"
          ligo_arg      : '"Expr"'
          ligo_state    : "record ret = 100n; end"
          sol_test_fn   : (contract, loc_on_end)->
            await contract.expr().cb defer(err, result); return loc_on_end err if err
            await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
            try
              assert.strictEqual result.toNumber(), 100
            catch err
              return loc_on_end err
            loc_on_end()
          ligo_test_fn  : (res, loc_on_end)->
            try
              assert.strictEqual +res, 100
            catch err
              return loc_on_end err
            loc_on_end()
        }, on_end
      
      it "uint a--", (on_end)->
        @timeout 30000
        text_i = """
          pragma solidity ^0.5.11;
          
          contract Expr {
            uint public ret;
            
            function expr() public {
              uint a = 100;
              uint c = 0;
              ret = a--;
            }
            function getRet() public view returns (uint ret_val) {
              ret_val = ret;
            }
          }
          """#"
        make_emulator_test {
          sol_code      : text_i
          contract_name : "Expr"
          ligo_arg      : '"Expr"'
          ligo_state    : "record ret = 100n; end"
          sol_test_fn   : (contract, loc_on_end)->
            await contract.expr().cb defer(err, result); return loc_on_end err if err
            await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
            try
              assert.strictEqual result.toNumber(), 100
            catch err
              return loc_on_end err
            loc_on_end()
          ligo_test_fn  : (res, loc_on_end)->
            try
              assert.strictEqual +res, 100
            catch err
              return loc_on_end err
            loc_on_end()
        }, on_end
      
      it "uint ++a", (on_end)->
        @timeout 30000
        text_i = """
          pragma solidity ^0.5.11;
          
          contract Expr {
            uint public ret;
            
            function expr() public {
              uint a = 100;
              uint c = 0;
              ret = ++a;
            }
            function getRet() public view returns (uint ret_val) {
              ret_val = ret;
            }
          }
          """#"
        make_emulator_test {
          sol_code      : text_i
          contract_name : "Expr"
          ligo_arg      : '"Expr"'
          ligo_state    : "record ret = 100n; end"
          sol_test_fn   : (contract, loc_on_end)->
            await contract.expr().cb defer(err, result); return loc_on_end err if err
            await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
            try
              assert.strictEqual result.toNumber(), 101
            catch err
              return loc_on_end err
            loc_on_end()
          ligo_test_fn  : (res, loc_on_end)->
            try
              assert.strictEqual +res, 101
            catch err
              return loc_on_end err
            loc_on_end()
        }, on_end
      
      it "uint --a", (on_end)->
        @timeout 30000
        text_i = """
          pragma solidity ^0.5.11;
          
          contract Expr {
            uint public ret;
            
            function expr() public {
              uint a = 100;
              uint c = 0;
              ret = --a;
            }
            function getRet() public view returns (uint ret_val) {
              ret_val = ret;
            }
          }
          """#"
        make_emulator_test {
          sol_code      : text_i
          contract_name : "Expr"
          ligo_arg      : '"Expr"'
          ligo_state    : "record ret = 100n; end"
          sol_test_fn   : (contract, loc_on_end)->
            await contract.expr().cb defer(err, result); return loc_on_end err if err
            await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
            try
              assert.strictEqual result.toNumber(), 99
            catch err
              return loc_on_end err
            loc_on_end()
          ligo_test_fn  : (res, loc_on_end)->
            try
              assert.strictEqual +res, 99
            catch err
              return loc_on_end err
            loc_on_end()
        }, on_end
      
      it "uint ~a", (on_end)->
        @timeout 30000
        text_i = """
          pragma solidity ^0.5.11;
          
          contract Expr {
            uint public ret;
            
            function expr() public {
              uint a = 100;
              uint c = 0;
              ret = ~a;
            }
            function getRet() public view returns (uint ret_val) {
              ret_val = ret;
            }
          }
          """#"
        make_emulator_test {
          sol_code      : text_i
          contract_name : "Expr"
          ligo_arg      : '"Expr"'
          ligo_state    : "record ret = 100n; end"
          sol_test_fn   : (contract, loc_on_end)->
            await contract.expr().cb defer(err, result); return loc_on_end err if err
            await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
            # WTF hell yes. Very wierd split of uint256
            try
              assert.strictEqual result.words[0], 67108763 # 3ffffff
              assert.strictEqual result.words[1], 67108863 # 3ffff9b
              assert.strictEqual result.words[2], 67108863
              assert.strictEqual result.words[3], 67108863
              assert.strictEqual result.words[4], 67108863
              assert.strictEqual result.words[5], 67108863
              assert.strictEqual result.words[6], 67108863
              assert.strictEqual result.words[7], 67108863
              assert.strictEqual result.words[8], 67108863
              assert.strictEqual result.words[9], 4194303 # 3fffff
            catch err
              return loc_on_end err
            loc_on_end()
          ligo_test_fn  : (res, loc_on_end)->
            try
              assert.strictEqual +res, 101 # WTF hell yes
            catch err
              return loc_on_end err
            loc_on_end()
        }, on_end
  
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
            } with ((nil: list(operation)), #{config.contract_storage}, c);
          
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
            } with ((nil: list(operation)), #{config.contract_storage}, 0n);
          
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
            } with ((nil: list(operation)), #{config.contract_storage}, c);
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
  #       } with ((nil: list(operation)), #{config.contract_storage}, c);
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
            } with ((nil: list(operation)), #{config.contract_storage}, c);
          
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
            } with ((nil: list(operation)), #{config.contract_storage}, 0n);
          
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
      } with ((nil: list(operation)), #{config.contract_storage}, (case #{config.contract_storage}.balances[owner] of | None -> 0n | Some(x) -> x end));
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
      } with ((nil: list(operation)), #{config.contract_storage});
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
    