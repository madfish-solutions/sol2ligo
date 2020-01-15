assert              = require "assert"
{json_eq}           = require "fy/test_util"
ast_gen             = require("../src/ast_gen")
solidity_to_ast4gen = require("../src/solidity_to_ast4gen").gen
ast_transform       = require("../src/ast_transform")
type_inference      = require("../src/type_inference").gen
translate           = require("../src/translate_ligo_default_state").gen

make_test = (text_i, hash_o_expected, text_o_expected)->
  solidity_ast = ast_gen text_i, silent:true
  ast = solidity_to_ast4gen solidity_ast
  ast = ast_transform.ligo_pack ast, router: false
  ast = type_inference ast
  hash_o_real     = translate ast, convert_to_string: false
  json_eq hash_o_real, hash_o_expected
  text_o_real     = translate ast
  assert.strictEqual text_o_real, text_o_expected

describe "translate ligo default state section", ()->
  it "no state", ()->
    text_i = """
    contract State {
    }
    """
    make_test text_i, {
      State : {
        _empty_state : {
          type : "nat"
          value: "0n"
        }
      }
    }, """
    record
      _empty_state = 0n;
    end
    """
  
  it "1 field", ()->
    text_i = """
    contract State {
      uint public value;
    }
    """
    make_test text_i, {
      State : {
        value : {
          type : "nat"
          value: "0n"
        }
      }
    }, """
    record
      value = 0n;
    end
    """
  
  it "all scalar types", ()->
    text_i = """
    contract State {
      bool public value_bool;
      uint public value_uint;
      int  public value_int ;
    }
    """
    make_test text_i, {
      State : {
        value_bool : {
          type : "bool"
          value: "False"
        }
        value_uint : {
          type : "nat"
          value: "0n"
        }
        value_int : {
          type : "int"
          value: "0"
        }
      }
    }, """
    record
      value_bool = False;
      value_uint = 0n;
      value_int = 0;
    end
    """
  
  it "string", ()->
    text_i = """
    contract State {
      string public value_string;
    }
    """
    make_test text_i, {
      State : {
        value_string : {
          type : "string"
          value: '""'
        }
      }
    }, """
    record
      value_string = "";
    end
    """#"
  
  it "map", ()->
    text_i = """
    contract State {
      mapping (address => uint) balances;
    }
    """
    make_test text_i, {
      State : {
        balances : {
          type : "map(address, nat)"
          value: "map end : map(address, nat)"
        }
      }
    }, """
    record
      balances = map end : map(address, nat);
    end
    """
  