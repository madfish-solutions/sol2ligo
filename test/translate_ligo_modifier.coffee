config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section modifier", ()->
  # ###################################################################################################
  #    modifier
  # ###################################################################################################
  it "basic modifier", ()->
    text_i = """
    pragma solidity ^0.4.26;
    contract BasicModifier {
      
      bool locked = false;
      bool a = false;
      
      modifier lock() {
        if(!locked) {
            locked = true;
            _;
            locked = false;
        }
      }
      function test() lock {
        a = true;
      }
    }
    """
    text_o = """
    type #{config.storage} is record
      locked : bool;
      a : bool;
    end;
    
    (* modifier lock inlined *)
    
    function test (const #{config.contract_storage} : #{config.storage}) : (#{config.storage}) is
      block {
        if (not (#{config.contract_storage}.locked)) then block {
          #{config.contract_storage}.locked := True;
          #{config.contract_storage}.a := True;
          #{config.contract_storage}.locked := False;
        } else block {
          skip
        };
      } with (#{config.contract_storage});
    """
    make_test text_i, text_o
  
  it "modifier with arguments", ()->
    text_i = """
    pragma solidity ^0.4.26;
    pragma solidity ^0.4.26;
    contract BasicModifier {
      
      bool val = false;
      
      modifier greaterThan(uint value, uint limit) {
        if(value <= limit) { throw; }
        _;
      }
      
      function test(uint a) greaterThan(a, 10) {
        val = true;
      }
    }
    """
    text_o = """
    type #{config.storage} is record
      val : bool;
    end;
    
    (* modifier greaterThan inlined *)
    
    function test (const #{config.contract_storage} : #{config.storage}; const a : nat) : (#{config.storage}) is
      block {
        const value : nat = a;
        const limit : nat = 10n;
        if (value <= limit) then block {
          failwith("throw");
        } else block {
          skip
        };
        #{config.contract_storage}.val := True;
      } with (#{config.contract_storage});
    """#"
    make_test text_i, text_o
  