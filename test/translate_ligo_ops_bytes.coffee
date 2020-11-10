config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section ops bytes", ()->
  @timeout 10000
  # ###################################################################################################
  #    expr
  # ###################################################################################################
  describe "bytesX un_ops", ()->
    for type in config.bytes_type_list
      continue if type == "bytes"
      ###
      LIGO doesn't have ~ for bytes
        #{type} c = 0;
        c = ~a;
      ###
      it "#{type} un_ops", ()->
        count = +(type.replace /bytes/, "")
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          #{type} public value;
          
          function expr() public returns (#{type}) {
            #{type} a = 0;
            return a;
          }
        }
        """#"
        text_o = """
          type state is record
            value : bytes;
          end;
          
          function expr (const #{config.reserved}__unit : unit) : (bytes) is
            block {
              const a : bytes = 0x#{'00'.repeat count};
            } with (a);
        """
        make_test text_i, text_o
  
  it "bytes ops0", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    contract BytesTest {
        function test0(
            bytes2 b0,
            bytes2 b1,
            bytes30 b2,
            bytes30 b3,
            bytes1 b4,
            bytes1 b5
        ) public {
            require(b0 <= b1);
            require(b2 > b3);
            require(b4 >= b5);
            require(bytes30(b4) < b5);
        }
    }
    """#"
    text_o = """
    type state is unit;
    
    function test0 (const b0 : bytes; const b1 : bytes; const b2 : bytes; const b3 : bytes; const b4 : bytes; const b5 : bytes) : (unit) is
      block {
        assert((b0 <= b1));
        assert((b2 > b3));
        assert((b4 >= b5));
        assert(((b4 : bytes) < b5));
      } with (unit);
    """#"
    make_test text_i, text_o
  
  it "bytes ops1", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    contract BytesTest {
        function test2(
            bytes storage b0,
            bytes storage b1,
            bytes memory b2,
            bytes memory b3
        ) internal {
            bytes memory bts = new bytes(0);
            b0 = b1;
            b2 = b3;
            b3 = new bytes(15);
        }
    }
    """#"
    
    text_o = """
    type state is unit;
    
    function test2 (const b0 : bytes; const b1 : bytes; const b2 : bytes; const b3 : bytes) : (unit) is
      block {
        const bts : bytes = ("00": bytes) (* args: 0 *);
        b0 := b1;
        b2 := b3;
        b3 := ("00": bytes) (* args: 15 *);
      } with (unit);
    """
    make_test text_i, text_o
  
  it "bytes length", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    contract BytesTest {
        function test0(
            bytes2 b0,
            bytes30 b1,
            bytes1 b2,
            bytes b3
        ) public {
            uint len0 = b0.length;
            uint len1 = b1.length;
            uint len2 = b2.length;
            uint len3 = b3.length;
        }
    }
    """#"
    text_o = """
    type state is unit;
    
    function test0 (const b0 : bytes; const b1 : bytes; const b2 : bytes; const b3 : bytes) : (unit) is
      block {
        const len0 : nat = size(b0);
        const len1 : nat = size(b1);
        const len2 : nat = size(b2);
        const len3 : nat = size(b3);
      } with (unit);
    """#"
    make_test text_i, text_o
  
  it "bytes push/pop/access", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract BytesTest {
        bytes b0;
        function test0() public {
            bytes1 bx;
            b0.push(bx);
            b0.pop();
            byte a = b0[0];
        }
    }
    """#"
    text_o = """
    type state is record
      b0 : bytes;
    end;
    
    function test0 (const contract_storage : state) : (state) is
      block {
        const bx : bytes = ("00": bytes);
        contract_storage.b0 := Bytes.concat(contract_storage.b0, bx);
        const tmp_0 : bytes = contract_storage.b0;
        contract_storage.b0 := Bytes.sub(0n, abs(size(tmp_0)-1), tmp_0);
        const tmp_1 : nat = 0n;
        const a : bytes = Bytes.sub(tmp_1, tmp_1+1n, contract_storage.b0);
      } with (contract_storage);
    """#"
    make_test text_i, text_o
  
  it "larger byte literals", ()->
    text_i = """
    pragma solidity ^0.4.16;

    contract BytesTest {
        function test0() public {
          bytes30 b1 = 0x1034a34234;
          bytes30 b2 = 0xee1034a34234;
        }
    }
    """#"
    
    text_o = """
    type state is unit;
    
    function test0 (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const b1 : bytes = 0x000000000000000000000000000000000000000000000000001034a34234;
        const b2 : bytes = 0x000000000000000000000000000000000000000000000000ee1034a34234;
      } with (unit);
    """
    make_test text_i, text_o
