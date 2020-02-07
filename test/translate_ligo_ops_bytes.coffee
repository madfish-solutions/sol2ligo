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
  