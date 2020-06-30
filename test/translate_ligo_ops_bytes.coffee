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
          
          function expr (const #{config.contract_storage} : state) : (list(operation) * state * bytes) is
            block {
              const a : bytes = 0x#{'00'.repeat count};
            } with ((nil: list(operation)), #{config.contract_storage}, a);
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
    
    function test0 (const #{config.contract_storage} : state; const b0 : bytes; const b1 : bytes; const b2 : bytes; const b3 : bytes; const b4 : bytes; const b5 : bytes) : (list(operation) * state) is
      block {
        assert((b0 <= b1));
        assert((b2 > b3));
        assert((b4 >= b5));
        assert(((b4 : bytes) < b5));
      } with ((nil: list(operation)), #{config.contract_storage});
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
    
    function test2 (const #{config.contract_storage} : state; const b0 : bytes; const b1 : bytes; const b2 : bytes; const b3 : bytes) : (state) is
      block {
        const bts : bytes = ("00": bytes) (* args: 0 *);
        b0 := b1;
        b2 := b3;
        b3 := ("00": bytes) (* args: 15 *);
      } with (#{config.contract_storage});
    """
    make_test text_i, text_o