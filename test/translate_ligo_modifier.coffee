config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
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
    type state is record
      locked : bool;
      a : bool;
    end;
    
    (* modifier lock inlined *)
    
    function test (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        if (not (contractStorage.locked)) then block {
          contractStorage.locked := True;
          contractStorage.a := True;
          contractStorage.locked := False;
        } else block {
          skip
        };
      } with (opList, contractStorage);
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
    type state is record
      val : bool;
    end;
    
    (* modifier greaterThan inlined *)
    
    function test (const opList : list(operation); const contractStorage : state; const a : nat) : (list(operation) * state) is
      block {
        const value : nat = a;
        const limit : nat = 10n;
        if (value <= limit) then block {
          failwith("throw");
        } else block {
          skip
        };
        contractStorage.val := True;
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o
  