config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
  @timeout 10000
  # ###################################################################################################
  #    expr
  # ###################################################################################################
  describe "bytesX un_ops", ()->
    for type in config.bytes_type_list
      it "#{type} un_ops", ()->
        text_i = """
        pragma solidity ^0.5.11;
        
        contract Expr {
          #{type} public value;
          
          function expr() public returns (#{type}) {
            #{type} a = 0;
            #{type} c = 0;
            c = ~a;
            return c;
          }
        }
        """#"
        text_o = """
          type state is record
            value : bytes;
          end;
          
          function expr (const opList : list(operation); const contractStorage : state) : (list(operation) * state * bytes) is
            block {
              const a : bytes = 0;
              const c : bytes = 0;
              c := not (a);
            } with (opList, contractStorage, c);
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
    type state is record
      #{config.empty_state} : int;
    end;
    
    function test0 (const opList : list(operation); const contractStorage : state; const b0 : bytes; const b1 : bytes; const b2 : bytes; const b3 : bytes; const b4 : bytes; const b5 : bytes) : (list(operation) * state) is
      block {
        if (b0 <= b1) then {skip} else failwith("require fail");
        if (b2 > b3) then {skip} else failwith("require fail");
        if (b4 >= b5) then {skip} else failwith("require fail");
        if ((b4 : bytes) < b5) then {skip} else failwith("require fail");
      } with (opList, contractStorage);
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
    type state is record
      #{config.empty_state} : int;
    end;
    
    function test2 (const opList : list(operation); const contractStorage : state; const b0 : bytes; const b1 : bytes; const b2 : bytes; const b3 : bytes) : (list(operation) * state) is
      block {
        const bts : bytes = bytes_pack(unit) (* args: 0 *);
        b0 := b1;
        b2 := b3;
        b3 := bytes_pack(unit) (* args: 15 *);
      } with (opList, contractStorage);
    """
    make_test text_i, text_o