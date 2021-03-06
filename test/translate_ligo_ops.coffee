config = require "../src/config"
assert = require "assert"
{
  translate_ligo_make_test : make_test
  async_assert_strict
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
          
          function expr (const contract_storage : state) : (state) is
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
              contract_storage.ret := c;
            } with (contract_storage);
          
          function getRet (const contract_storage : state) : (nat) is
            block {
              const ret_val : nat = 0n;
              ret_val := contract_storage.ret;
            } with (ret_val);
        """
        make_test text_i, text_o
        if process.env.EMULATOR and type == "uint"
          await make_emulator_test {
            sol_code      : text_i
            contract_name : "Expr"
            ligo_arg_list : ["Expr"]
            ligo_state    : "record ret = 99999n; end"
            sol_test_fn   : (contract, on_end)->
              await contract.expr().cb defer(err, result); return on_end err if err
              await contract.getRet.call().cb defer(err, result); return on_end err if err
              
              await async_assert_strict result.toNumber(), 0, defer(err); return on_end err if err
              on_end()
            ligo_test_fn  : (res_list, on_end)->
              await async_assert_strict +res_list[0], 0, defer(err); return on_end err if err
              on_end()
          }, defer(err); return on_end err if err
        on_end()
    
    if process.env.EMULATOR
      describe "emulator", ()->
        # TODO group in loop
        it "uint a++", (on_end)->
          @timeout 30000
          text_i = """
            pragma solidity ^0.5.11;
            
            contract Expr {
              uint public ret;
              
              function expr(uint a) public {
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
            ligo_arg_list : ["Expr(record a=100n end)"]
            ligo_state    : "record ret = 99999n; end"
            sol_test_fn   : (contract, loc_on_end)->
              await contract.expr(100).cb defer(err, result); return loc_on_end err if err
              await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
              
              await async_assert_strict result.toNumber(), 100, defer(err); return loc_on_end err if err
              loc_on_end()
            ligo_test_fn  : (res_list, loc_on_end)->
              await async_assert_strict +res_list[0], 100, defer(err); return loc_on_end err if err
              loc_on_end()
          }, on_end
        
        it "uint a--", (on_end)->
          @timeout 30000
          text_i = """
            pragma solidity ^0.5.11;
            
            contract Expr {
              uint public ret;
              
              function expr(uint a) public {
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
            ligo_arg_list : ["Expr(record a=100n end)"]
            ligo_state    : "record ret = 99999n; end"
            sol_test_fn   : (contract, loc_on_end)->
              await contract.expr(100).cb defer(err, result); return loc_on_end err if err
              await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
              
              await async_assert_strict result.toNumber(), 100, defer(err); return loc_on_end err if err
              loc_on_end()
            ligo_test_fn  : (res_list, loc_on_end)->
              await async_assert_strict +res_list[0], 100, defer(err); return loc_on_end err if err
              loc_on_end()
          }, on_end
        
        it "uint ++a", (on_end)->
          @timeout 30000
          text_i = """
            pragma solidity ^0.5.11;
            
            contract Expr {
              uint public ret;
              
              function expr(uint a) public {
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
            ligo_arg_list : ["Expr(record a=100n end)"]
            ligo_state    : "record ret = 99999n; end"
            sol_test_fn   : (contract, loc_on_end)->
              await contract.expr(100).cb defer(err, result); return loc_on_end err if err
              await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
              
              await async_assert_strict result.toNumber(), 101, defer(err); return loc_on_end err if err
              loc_on_end()
            ligo_test_fn  : (res_list, loc_on_end)->
              await async_assert_strict +res_list[0], 101, defer(err); return loc_on_end err if err
              loc_on_end()
          }, on_end
        
        it "uint --a", (on_end)->
          @timeout 30000
          text_i = """
            pragma solidity ^0.5.11;
            
            contract Expr {
              uint public ret;
              
              function expr(uint a) public {
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
            ligo_arg_list : ["Expr(record a=100n end)"]
            ligo_state    : "record ret = 99999n; end"
            sol_test_fn   : (contract, loc_on_end)->
              await contract.expr(100).cb defer(err, result); return loc_on_end err if err
              await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
              
              await async_assert_strict result.toNumber(), 99, defer(err); return loc_on_end err if err
              loc_on_end()
            ligo_test_fn  : (res_list, loc_on_end)->
              await async_assert_strict +res_list[0], 99, defer(err); return loc_on_end err if err
              loc_on_end()
          }, on_end
        
        it "uint ~a", (on_end)->
          @timeout 30000
          text_i = """
            pragma solidity ^0.5.11;
            
            contract Expr {
              uint public ret;
              
              function expr(uint a) public {
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
            ligo_arg_list : ["Expr(record a=100n end)"]
            ligo_state    : "record ret = 99999n; end"
            sol_test_fn   : (contract, loc_on_end)->
              await contract.expr(100).cb defer(err, result); return loc_on_end err if err
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
            ligo_test_fn  : (res_list, loc_on_end)->
              # WTF hell yes
              await async_assert_strict +res_list[0], 101, defer(err); return loc_on_end err if err
              loc_on_end()
          }, on_end
  
  describe "uintX bin_ops emulator", ()->
    for type in config.uint_type_list
      it "#{type} bin_ops", (on_end)->
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          #{type} public ret;
          
          function expr() public {
            #{type} a = 0;
            #{type} b = 1;
            #{type} c = 0;
            c = a + b;
            c = a - b;
            c = a * b;
            c = a / b;
            c = a % b;
            c = a ** b;
            c = a & b;
            c = a | b;
            c = a ^ b;
            c = a << b;
            c = a >> b;
            c += b;
            c -= b;
            c *= b;
            c /= b;
            c %= b;
            c &= b;
            c |= b;
            c ^= b;
            c <<= b;
            c >>= b;
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
          
          function pow (const base : nat; const exp : nat) : nat is
            block {
              var b : nat := base;
              var e : nat := exp;
              var r : nat := 1n;
              while e > 0n block {
                if e mod 2n = 1n then {
                  r := r * b;
                } else skip;
                b := b * b;
                e := e / 2n;
              }
            } with r;
          
          function expr (const contract_storage : state) : (state) is
            block {
              const a : nat = 0n;
              const b : nat = 1n;
              const c : nat = 0n;
              c := (a + b);
              c := abs(a - b);
              c := (a * b);
              c := (a / b);
              c := (a mod b);
              c := pow(a, b);
              c := Bitwise.and(a, b);
              c := Bitwise.or(a, b);
              c := Bitwise.xor(a, b);
              c := Bitwise.shift_left(a, b);
              c := Bitwise.shift_right(a, b);
              c := (c + b);
              c := abs(c - b);
              c := (c * b);
              c := (c / b);
              c := (c mod b);
              c := Bitwise.and(c, b);
              c := Bitwise.or(c, b);
              c := Bitwise.xor(c, b);
              c := Bitwise.shift_left(c, b);
              c := Bitwise.shift_right(c, b);
              contract_storage.ret := c;
            } with (contract_storage);
          
          function getRet (const contract_storage : state) : (nat) is
            block {
              const ret_val : nat = 0n;
              ret_val := contract_storage.ret;
            } with (ret_val);
        """
        make_test text_i, text_o
        if process.env.EMULATOR and type == "uint"
          await make_emulator_test {
            sol_code      : text_i
            contract_name : "Expr"
            ligo_arg_list : ["Expr"]
            ligo_state    : "record ret = 99999n; end"
            sol_test_fn   : (contract, on_end)->
              await contract.expr().cb defer(err, result); return on_end err if err
              await contract.getRet.call().cb defer(err, result); return on_end err if err
              
              await async_assert_strict result.toNumber(), 0, defer(err); return on_end err if err
              on_end()
            ligo_test_fn  : (res_list, on_end)->
              await async_assert_strict +res_list[0], 0, defer(err); return on_end err if err
              on_end()
          }, defer(err); return on_end err if err
        on_end()
      
      it "#{type} bin_ops with a const", (on_end)->
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          #{type} public ret;
          
          function expr() public {
            #{type} b = 1;
            #{type} c = 0;
            c = 1 + b;
            c = 1 - b;
            c = 1 * b;
            c = 1 / b;
            c = 1 % b;
            c = 1 ** b;
            c = 1 & b;
            c = 1 | b;
            c = 1 ^ b;
            c = 1 << b;
            c = 1 >> b;
            c += b;
            c -= b;
            c *= b;
            c /= b;
            c %= b;
            c &= b;
            c |= b;
            c ^= b;
            c <<= b;
            c >>= b;
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
          
          function pow (const base : nat; const exp : nat) : nat is
            block {
              var b : nat := base;
              var e : nat := exp;
              var r : nat := 1n;
              while e > 0n block {
                if e mod 2n = 1n then {
                  r := r * b;
                } else skip;
                b := b * b;
                e := e / 2n;
              }
            } with r;
          
          function expr (const contract_storage : state) : (state) is
            block {
              const b : nat = 1n;
              const c : nat = 0n;
              c := (1n + b);
              c := abs(1n - b);
              c := (1n * b);
              c := (1n / b);
              c := (1n mod b);
              c := pow(1n, b);
              c := Bitwise.and(1n, b);
              c := Bitwise.or(1n, b);
              c := Bitwise.xor(1n, b);
              c := Bitwise.shift_left(1n, b);
              c := Bitwise.shift_right(1n, b);
              c := (c + b);
              c := abs(c - b);
              c := (c * b);
              c := (c / b);
              c := (c mod b);
              c := Bitwise.and(c, b);
              c := Bitwise.or(c, b);
              c := Bitwise.xor(c, b);
              c := Bitwise.shift_left(c, b);
              c := Bitwise.shift_right(c, b);
              contract_storage.ret := c;
            } with (contract_storage);
          
          function getRet (const contract_storage : state) : (nat) is
            block {
              const ret_val : nat = 0n;
              ret_val := contract_storage.ret;
            } with (ret_val);
        """
        make_test text_i, text_o
        if process.env.EMULATOR and type == "uint"
          await make_emulator_test {
            sol_code      : text_i
            contract_name : "Expr"
            ligo_arg_list : ["Expr"]
            ligo_state    : "record ret = 99999n; end"
            sol_test_fn   : (contract, on_end)->
              await contract.expr().cb defer(err, result); return on_end err if err
              await contract.getRet.call().cb defer(err, result); return on_end err if err
              
              await async_assert_strict result.toNumber(), 0, defer(err); return on_end err if err
              on_end()
            ligo_test_fn  : (res_list, on_end)->
              await async_assert_strict +res_list[0], 0, defer(err); return on_end err if err
              on_end()
          }, defer(err); return on_end err if err
        on_end()
      
      it "#{type} bin_ops with b const", (on_end)->
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          #{type} public ret;
          
          function expr() public {
            #{type} a = 0;
            #{type} c = 0;
            c = a + 1;
            c = a - 1;
            c = a * 1;
            c = a / 1;
            c = a % 1;
            c = a ** 1;
            c = a & 1;
            c = a | 1;
            c = a ^ 1;
            c = a << 1;
            c = a >> 1;
            c += 1;
            c -= 1;
            c *= 1;
            c /= 1;
            c %= 1;
            c &= 1;
            c |= 1;
            c ^= 1;
            c <<= 1;
            c >>= 1;
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
          
          function pow (const base : nat; const exp : nat) : nat is
            block {
              var b : nat := base;
              var e : nat := exp;
              var r : nat := 1n;
              while e > 0n block {
                if e mod 2n = 1n then {
                  r := r * b;
                } else skip;
                b := b * b;
                e := e / 2n;
              }
            } with r;
          
          function expr (const contract_storage : state) : (state) is
            block {
              const a : nat = 0n;
              const c : nat = 0n;
              c := (a + 1n);
              c := abs(a - 1n);
              c := (a * 1n);
              c := (a / 1n);
              c := (a mod 1n);
              c := pow(a, 1n);
              c := Bitwise.and(a, 1n);
              c := Bitwise.or(a, 1n);
              c := Bitwise.xor(a, 1n);
              c := Bitwise.shift_left(a, 1n);
              c := Bitwise.shift_right(a, 1n);
              c := (c + 1n);
              c := abs(c - 1n);
              c := (c * 1n);
              c := (c / 1n);
              c := (c mod 1n);
              c := Bitwise.and(c, 1n);
              c := Bitwise.or(c, 1n);
              c := Bitwise.xor(c, 1n);
              c := Bitwise.shift_left(c, 1n);
              c := Bitwise.shift_right(c, 1n);
              contract_storage.ret := c;
            } with (contract_storage);
          
          function getRet (const contract_storage : state) : (nat) is
            block {
              const ret_val : nat = 0n;
              ret_val := contract_storage.ret;
            } with (ret_val);
        """
        make_test text_i, text_o
        if process.env.EMULATOR and type == "uint"
          await make_emulator_test {
            sol_code      : text_i
            contract_name : "Expr"
            ligo_arg_list : ["Expr"]
            ligo_state    : "record ret = 99999n; end"
            sol_test_fn   : (contract, on_end)->
              await contract.expr().cb defer(err, result); return on_end err if err
              await contract.getRet.call().cb defer(err, result); return on_end err if err
              
              await async_assert_strict result.toNumber(), 0, defer(err); return on_end err if err
              on_end()
            ligo_test_fn  : (res_list, on_end)->
              await async_assert_strict +res_list[0], 0, defer(err); return on_end err if err
              on_end()
          }, defer(err); return on_end err if err
        on_end()
    
    if process.env.EMULATOR
      describe "emulator a op b -> uint", ()->
        for op in "+ - * / % ** & | ^ << >>".split /\s+/g
          do (op)->
            test_value_list = []
            for a in [0 .. 2]
              for b in [0 .. 2]
                c = eval "#{a} #{op} #{b}"
                continue if c < 0
                continue if !isFinite c
                c = Math.floor c
                test_value_list.push [a,b,c]
            it "uint a#{op}b", (on_end)->
              @timeout 30000
              text_i = """
                pragma solidity ^0.5.11;
                
                contract Expr {
                  uint public ret;
                  
                  function expr(uint a, uint b) public {
                    ret = a #{op} b;
                  }
                  function getRet() public view returns (uint ret_val) {
                    ret_val = ret;
                  }
                }
                """#"
              
              make_emulator_test {
                sol_code      : text_i
                contract_name : "Expr"
                ligo_arg_list : test_value_list.map (v)->
                  "Expr(record a=#{v[0]}n; b=#{v[1]}n end)"
                ligo_state    : "record ret = 99999n; end"
                sol_test_fn   : (contract, loc_on_end)->
                  for v in test_value_list
                    [a,b,c] = v
                    await contract.expr(a, b).cb defer(err, result); return loc_on_end err if err
                    await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
                    
                    await async_assert_strict result.toNumber(), c, defer(err); return loc_on_end err if err
                  loc_on_end()
                ligo_test_fn  : (res_list, loc_on_end)->
                  for v,idx in test_value_list
                    [a,b,c] = v
                    await async_assert_strict +res_list[idx], c, defer(err); return loc_on_end err if err
                  loc_on_end()
              }, on_end
      
      describe "emulator a op b -> bool", ()->
        for op in "== != >= <= < >".split /\s+/g
          do (op)->
            test_value_list = []
            for a in [0 .. 2]
              for b in [0 .. 2]
                c = eval "#{a} #{op} #{b}"
                test_value_list.push [a,b,c]
            it "uint a#{op}b", (on_end)->
              @timeout 30000
              text_i = """
                pragma solidity ^0.5.11;
                
                contract Expr {
                  bool public ret;
                  
                  function expr(uint a, uint b) public {
                    ret = a #{op} b;
                  }
                  function getRet() public view returns (bool ret_val) {
                    ret_val = ret;
                  }
                }
                """#"
              
              make_emulator_test {
                sol_code      : text_i
                contract_name : "Expr"
                ligo_arg_list : test_value_list.map (v)->
                  "Expr(record a=#{v[0]}n; b=#{v[1]}n end)"
                ligo_state    : "record ret = False; end"
                sol_test_fn   : (contract, loc_on_end)->
                  for v in test_value_list
                    [a,b,c] = v
                    await contract.expr(a, b).cb defer(err, result); return loc_on_end err if err
                    await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
                    
                    await async_assert_strict result, c, defer(err); return loc_on_end err if err
                  loc_on_end()
                ligo_test_fn  : (res_list, loc_on_end)->
                  for v,idx in test_value_list
                    [a,b,c] = v
                    real = eval res_list[idx]
                    await async_assert_strict real, c, defer(err); return loc_on_end err if err
                  loc_on_end()
              }, on_end
        
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
          
          function expr (const #{config.reserved}__unit : unit) : (nat) is
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
            } with (0n);
          
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
          
          function expr (const #{config.reserved}__unit : unit) : (int) is
            block {
              const a : int = 0;
              const c : int = 0;
              c := not (a);
              c := int(abs(not (0)));
            } with (c);
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
  #     function expr (const #{config.reserved}__unit : unit) : (int) is
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
  #         c := Bitwise.and(a, b);
  #         c := Bitwise.or(a, b);
  #         c := Bitwise.xor(a, b);
  #         c := (c + b);
  #         c := (c - b);
  #         c := (c * b);
  #         c := (c / b);
  #         c := (c mod b);
  #         c := Bitwise.and(c, b);
  #         c := Bitwise.or(c, b);
  #         c := Bitwise.xor(c, b);
  #       } with (c);
  #     
  #   """
  #   make_test text_i, text_o
  # 
  describe "intX bin_ops emulator", ()->
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
            c = a & b;
            c = a | b;
            c = a ^ b;
            c = a << b;
            c = a >> b;
            c += b;
            c -= b;
            c *= b;
            c /= b;
            c &= b;
            c |= b;
            c ^= b;
            c <<= b;
            c >>= b;
            return c;
          }
        }
        """#"
        text_o = """
          type state is record
            value : int;
          end;
          
          function expr (const #{config.reserved}__unit : unit) : (int) is
            block {
              const a : int = 0;
              const b : int = 0;
              const c : int = 0;
              c := -(c);
              c := (a + b);
              c := (a - b);
              c := (a * b);
              c := (a / b);
              c := int(Bitwise.and(abs(a), abs(b)));
              c := int(Bitwise.or(abs(a), abs(b)));
              c := int(Bitwise.xor(abs(a), abs(b)));
              c := int(Bitwise.shift_left(abs(a), abs(b)));
              c := int(Bitwise.shift_right(abs(a), abs(b)));
              c := (c + b);
              c := (c - b);
              c := (c * b);
              c := (c / b);
              c := int(Bitwise.and(abs(c), abs(b)));
              c := int(Bitwise.or(abs(c), abs(b)));
              c := int(Bitwise.xor(abs(c), abs(b)));
              c := int(Bitwise.shift_left(abs(c), abs(b)));
              c := int(Bitwise.shift_right(abs(c), abs(b)));
            } with (c);
          
        """
        make_test text_i, text_o
    
    for type in config.int_type_list
      it "#{type} bin_ops with a const", ()->
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          #{type} public value;
          
          function expr() public returns (#{type}) {
            #{type} b = 0;
            #{type} c = 0;
            c = -c;
            c = 1 + b;
            c = 1 - b;
            c = 1 * b;
            c = 1 / b;
            c = 1 & b;
            c = 1 | b;
            c = 1 ^ b;
            c = 1 << b;
            c = 1 >> b;
            c += b;
            c -= b;
            c *= b;
            c /= b;
            c &= b;
            c |= b;
            c ^= b;
            c <<= b;
            c >>= b;
            return c;
          }
        }
        """#"
        text_o = """
          type state is record
            value : int;
          end;
          
          function expr (const #{config.reserved}__unit : unit) : (int) is
            block {
              const b : int = 0;
              const c : int = 0;
              c := -(c);
              c := (1 + b);
              c := (1 - b);
              c := (1 * b);
              c := (1 / b);
              c := int(Bitwise.and(1n, abs(b)));
              c := int(Bitwise.or(1n, abs(b)));
              c := int(Bitwise.xor(1n, abs(b)));
              c := int(Bitwise.shift_left(1n, abs(b)));
              c := int(Bitwise.shift_right(1n, abs(b)));
              c := (c + b);
              c := (c - b);
              c := (c * b);
              c := (c / b);
              c := int(Bitwise.and(abs(c), abs(b)));
              c := int(Bitwise.or(abs(c), abs(b)));
              c := int(Bitwise.xor(abs(c), abs(b)));
              c := int(Bitwise.shift_left(abs(c), abs(b)));
              c := int(Bitwise.shift_right(abs(c), abs(b)));
            } with (c);
          
        """
        make_test text_i, text_o
    
    for type in config.int_type_list
      it "#{type} bin_ops with b const", ()->
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          #{type} public value;
          
          function expr() public returns (#{type}) {
            #{type} a = 0;
            #{type} c = 0;
            c = -c;
            c = a + 1;
            c = a - 1;
            c = a * 1;
            c = a / 1;
            c = a & 1;
            c = a | 1;
            c = a ^ 1;
            c = a << 1;
            c = a >> 1;
            c += 1;
            c -= 1;
            c *= 1;
            c /= 1;
            c &= 1;
            c |= 1;
            c ^= 1;
            c <<= 1;
            c >>= 1;
            return c;
          }
        }
        """#"
        text_o = """
          type state is record
            value : int;
          end;
          
          function expr (const #{config.reserved}__unit : unit) : (int) is
            block {
              const a : int = 0;
              const c : int = 0;
              c := -(c);
              c := (a + 1);
              c := (a - 1);
              c := (a * 1);
              c := (a / 1);
              c := int(Bitwise.and(abs(a), 1n));
              c := int(Bitwise.or(abs(a), 1n));
              c := int(Bitwise.xor(abs(a), 1n));
              c := int(Bitwise.shift_left(abs(a), 1n));
              c := int(Bitwise.shift_right(abs(a), 1n));
              c := (c + 1);
              c := (c - 1);
              c := (c * 1);
              c := (c / 1);
              c := int(Bitwise.and(abs(c), 1n));
              c := int(Bitwise.or(abs(c), 1n));
              c := int(Bitwise.xor(abs(c), 1n));
              c := int(Bitwise.shift_left(abs(c), 1n));
              c := int(Bitwise.shift_right(abs(c), 1n));
            } with (c);
          
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
          
          function expr (const #{config.reserved}__unit : unit) : (nat) is
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
            } with (0n);
          
        """
        make_test text_i, text_o
    
    if process.env.EMULATOR
      describe "emulator a op b -> int", ()->
        for op in "+ - * / % & | ^ << >>".split /\s+/g
          do (op)->
            test_value_list = []
            for a in [0 .. 2]
              for b in [0 .. 2]
                c = eval "#{a} #{op} #{b}"
                continue if !isFinite c
                continue if c < 0 # we can't read negative numbers properly from solidity for now
                c = Math.floor c
                test_value_list.push [a,b,c]
            it "int a#{op}b", (on_end)->
              @timeout 30000
              text_i = """
                pragma solidity ^0.5.11;
                
                contract Expr {
                  int public ret;
                  
                  function expr(int a, int b) public {
                    ret = (a #{op} b);
                  }
                  function getRet() public view returns (int ret_val) {
                    ret_val = ret;
                  }
                }
                """#"
              
              make_emulator_test {
                sol_code      : text_i
                contract_name : "Expr"
                ligo_arg_list : test_value_list.map (v)->
                  "Expr(record a=#{v[0]}; b=#{v[1]} end)"
                ligo_state    : "record ret = 99999; end"
                sol_test_fn   : (contract, loc_on_end)->
                  for v in test_value_list
                    [a,b,c] = v
                    await contract.expr(a, b).cb defer(err, result); return loc_on_end err if err
                    await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
                    
                    await async_assert_strict result.toNumber(), c, defer(err); return loc_on_end err if err
                  loc_on_end()
                ligo_test_fn  : (res_list, loc_on_end)->
                  for v,idx in test_value_list
                    [a,b,c] = v
                    await async_assert_strict +res_list[idx], c, defer(err); return loc_on_end err if err
                  loc_on_end()
              }, on_end
        
        for op in "== != >= <= < >".split /\s+/g
          do (op)->
            test_value_list = []
            for a in [0 .. 2]
              for b in [0 .. 2]
                c = eval "#{a} #{op} #{b}"
                test_value_list.push [a,b,c]
            it "int a#{op}b", (on_end)->
              @timeout 30000
              text_i = """
                pragma solidity ^0.5.11;
                
                contract Expr {
                  bool public ret;
                  
                  function expr(int a, int b) public {
                    ret = a #{op} b;
                  }
                  function getRet() public view returns (bool ret_val) {
                    ret_val = ret;
                  }
                }
                """#"
              
              make_emulator_test {
                sol_code      : text_i
                contract_name : "Expr"
                ligo_arg_list : test_value_list.map (v)->
                  "Expr(record a=#{v[0]}; b=#{v[1]} end)"
                ligo_state    : "record ret = False; end"
                sol_test_fn   : (contract, loc_on_end)->
                  for v in test_value_list
                    [a,b,c] = v
                    await contract.expr(a, b).cb defer(err, result); return loc_on_end err if err
                    await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
                    
                    await async_assert_strict result, c, defer(err); return loc_on_end err if err
                  loc_on_end()
                ligo_test_fn  : (res_list, loc_on_end)->
                  for v,idx in test_value_list
                    [a,b,c] = v
                    real = eval res_list[idx]
                    await async_assert_strict real, c, defer(err); return loc_on_end err if err
                  loc_on_end()
              }, on_end
  
  # ###################################################################################################
  describe "bool bin_ops emulator", ()->
    it "bool bin_ops", (on_end)->
      @timeout 30000
      text_i = """
      pragma solidity ^0.5.11;
      
      contract Expr {
        bool public ret;
        
        function expr() public {
          bool a = false;
          bool b = true;
          bool c = false;
          c = a && b;
          c = a || b;
          c = a == b;
          c = a != b;
          c = !b;
          ret = c;
        }
        function getRet() public view returns (bool ret_val) {
          ret_val = ret;
        }
      }
      """#"
      text_o = """
        type state is record
          ret : bool;
        end;
        
        function expr (const contract_storage : state) : (state) is
          block {
            const a : bool = False;
            const b : bool = True;
            const c : bool = False;
            c := (a and b);
            c := (a or b);
            c := (a = b);
            c := (a =/= b);
            c := not (b);
            contract_storage.ret := c;
          } with (contract_storage);
        
        function getRet (const contract_storage : state) : (bool) is
          block {
            const ret_val : bool = False;
            ret_val := contract_storage.ret;
          } with (ret_val);
      """
      make_test text_i, text_o
      if process.env.EMULATOR
        await make_emulator_test {
          sol_code      : text_i
          contract_name : "Expr"
          ligo_arg_list : ["Expr"]
          ligo_state    : "record ret = False; end"
          sol_test_fn   : (contract, on_end)->
            await contract.expr().cb defer(err, result); return on_end err if err
            await contract.getRet.call().cb defer(err, result); return on_end err if err
            
            await async_assert_strict result, false, defer(err); return on_end err if err
            on_end()
          ligo_test_fn  : (res_list, on_end)->
            await async_assert_strict res_list[0], "false", defer(err); return on_end err if err
            on_end()
        }, defer(err); return on_end err if err
      on_end()
    
    if process.env.EMULATOR
      describe "emulator a op b -> bool", ()->
        for op in "== != && ||".split /\s+/g
          do (op)->
            test_value_list = []
            for a in [true, false]
              for b in [true, false]
                c = eval "#{a} #{op} #{b}"
                test_value_list.push [a,b,c]
            it "bool a#{op}b", (on_end)->
              @timeout 30000
              text_i = """
                pragma solidity ^0.5.11;
                
                contract Expr {
                  bool public ret;
                  
                  function expr(bool a, bool b) public {
                    ret = a #{op} b;
                  }
                  function getRet() public view returns (bool ret_val) {
                    ret_val = ret;
                  }
                }
                """#"
              
              make_emulator_test {
                sol_code      : text_i
                contract_name : "Expr"
                ligo_arg_list : test_value_list.map (v)->
                  [a,b] = v
                  a = JSON.stringify(a).capitalize()
                  b = JSON.stringify(b).capitalize()
                  "Expr(record a=#{a}; b=#{b} end)"
                ligo_state    : "record ret = False; end"
                sol_test_fn   : (contract, loc_on_end)->
                  for v in test_value_list
                    [a,b,c] = v
                    await contract.expr(a, b).cb defer(err, result); return loc_on_end err if err
                    await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
                    
                    await async_assert_strict result, c, defer(err); return loc_on_end err if err
                  loc_on_end()
                ligo_test_fn  : (res_list, loc_on_end)->
                  for v,idx in test_value_list
                    [a,b,c] = v
                    real = eval res_list[idx]
                    await async_assert_strict real, c, defer(err); return loc_on_end err if err
                  loc_on_end()
              }, on_end
  # ###################################################################################################
  describe "map emulator", ()->
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
      
      function expr (const contract_storage : state; const owner : address) : (nat) is
        block {
          skip
        } with ((case contract_storage.balances[owner] of | None -> 0n | Some(x) -> x end));
      """
      make_test text_i, text_o
    
    if process.env.EMULATOR
      it "a[b] get/set emulator", (on_end)->
        @timeout 30000
        text_i = """
          pragma solidity ^0.5.11;
          
          contract Expr {
            uint public ret;
            mapping (uint => uint) store_map;
            
            function call_set(uint key, uint value) public {
              store_map[key] = value;
            }
            function call_get(uint key) public {
              ret = store_map[key];
            }
            function getRet() public view returns (uint ret_val) {
              ret_val = ret;
            }
          }
          """#"
        make_emulator_test {
          sol_code      : text_i
          contract_name : "Expr"
          ligo_arg_list : [
            "Call_set(record key=1n; value=100n end)"
            "Call_get(record key=2n end)"
          ]
          ligo_state    : "record ret = 99999n; store_map = (map [2n->100n] : map(nat,nat)) end"
          sol_test_fn   : (contract, loc_on_end)->
            await contract.call_set(1, 100).cb defer(err, result); return loc_on_end err if err
            await contract.call_get(1).cb defer(err, result); return loc_on_end err if err
            await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
            
            await async_assert_strict result.toNumber(), 100, defer(err); return loc_on_end err if err
            
            await contract.call_get(2).cb defer(err, result); return loc_on_end err if err
            await contract.getRet.call().cb defer(err, result); return loc_on_end err if err
            
            # empty in solidity == default value
            await async_assert_strict result.toNumber(), 0, defer(err); return loc_on_end err if err
            
            loc_on_end()
          ligo_test_fn  : (res_list, loc_on_end)->
            # we can't store state between calls yet
            # no check for 1
            await async_assert_strict +res_list[1], 100, defer(err); return loc_on_end err if err
            loc_on_end()
        }, on_end
  
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
    
    function addmulmod (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const x : nat = 1n;
        const y : nat = 2n;
        const z : nat = 3n;
        const a : nat = ((x + y) mod z);
        const m : nat = ((x * y) mod z);
      } with (unit);
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
    
    function test1 (const u0 : nat) : (unit) is
      block {
        const u1 : nat = abs(not (u0));
        const u2 : nat = abs(not (abs(not (u0))));
        const u3 : nat = (abs(not (u0)) + u2);
        const u4 : nat = (abs(not (u3)) + u2);
      } with (unit);
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
    
    function test2 (const b0 : bool) : (unit) is
      block {
        const b1 : bool = not (b0);
        const b2 : bool = not (not (not (not (not (b1)))));
      } with (unit);
    """
    make_test text_i, text_o
  
  # ###################################################################################################
  #    state change
  # ###################################################################################################
  describe "state change", ()->
    it "un_op", ()->
      text_i = """
      pragma solidity ^0.4.16;

      contract State_change {
        uint private quality;
        function post_inc() public {
          quality++;
        }
        function post_dec() public {
          quality--;
        }
        function pre_inc() public {
          ++quality;
        }
        function pre_dec() public {
          --quality;
        }
        function upd_inc() public {
          quality += 1;
        }
        function upd_dec() public {
          quality -= 1;
        }
      }
      """#"
      text_o = """
      type state is record
        quality : nat;
      end;

      function post_inc (const contract_storage : state) : (state) is
        block {
          contract_storage.quality := contract_storage.quality + 1n;
        } with (contract_storage);

      function post_dec (const contract_storage : state) : (state) is
        block {
          contract_storage.quality := abs(contract_storage.quality - 1n);
        } with (contract_storage);

      function pre_inc (const contract_storage : state) : (state) is
        block {
          contract_storage.quality := contract_storage.quality + 1n;
        } with (contract_storage);

      function pre_dec (const contract_storage : state) : (state) is
        block {
          contract_storage.quality := abs(contract_storage.quality - 1n);
        } with (contract_storage);

      function upd_inc (const contract_storage : state) : (state) is
        block {
          contract_storage.quality := (contract_storage.quality + 1n);
        } with (contract_storage);

      function upd_dec (const contract_storage : state) : (state) is
        block {
          contract_storage.quality := abs(contract_storage.quality - 1n);
        } with (contract_storage);
      """
      make_test text_i, text_o
  # ###################################################################################################
  #    chain assignment
  # ###################################################################################################
  describe "chain assignment", ()->
    it "basic", ()->
      text_i = """
      pragma solidity ^0.5.0;
      
      contract Test {
       function test() public {
          bool boolean0 = false;
          bool boolean1 = true;
          bool boolean = boolean0 = boolean1; 
        }
      }
      """#"
      text_o = """
      type state is unit;
      
      function test (const #{config.reserved}__unit : unit) : (unit) is
        block {
          const boolean0 : bool = False;
          const boolean1 : bool = True;
          boolean0 := boolean1;
          const boolean : bool = boolean0;
        } with (unit);
      """
      make_test text_i, text_o
