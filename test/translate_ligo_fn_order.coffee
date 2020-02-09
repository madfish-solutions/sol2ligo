config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
  @timeout 10000
  it "modifier after usage", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    contract DSAuth {
      function setAuthority() public auth {
        
      }
      
      modifier auth {
        _;
      }
    }
    """
    text_o = """
    type state is record
      #{config.empty_state} : int;
    end;
    
    (* modifier auth inlined *)
    
    function setAuthority (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    """
    make_test text_i, text_o
  
  it "modifier after usage, but method in modifier is after modifier", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    contract DSAuth {
      function setAuthority() public auth {
        
      }
      
      modifier auth {
        require(isAuthorized());
        _;
      }
      
      function isAuthorized() internal view returns (bool) {
        return false;
      }
    }
    """
    text_o = """
    type state is record
      #{config.empty_state} : int;
    end;
    
    (* modifier auth inlined *)
    
    function isAuthorized (const opList : list(operation); const contractStorage : state) : (list(operation) * state * bool) is
      block {
        skip
      } with (opList, contractStorage, False);
    
    function setAuthority (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const tmp_0 : (list(operation) * state * bool) = isAuthorized(opList, contractStorage);
        opList := tmp_0.0;
        contractStorage := tmp_0.1;
        if tmp_0.2 then {skip} else failwith("require fail");
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o
  
  it "allow self recursion", ()->
    text_i = """
    pragma solidity ^0.5.0;
    
    contract Recursive_test {
      function test() public {
        if (false) {
          test();
        }
      }
    }
    """
    text_o = """
    type state is record
      #{config.empty_state} : int;
    end;
    
    function test (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        if (False) then block {
          const tmp_0 : (list(operation) * state) = test(opList, contractStorage);
          opList := tmp_0.0;
          contractStorage := tmp_0.1;
        } else block {
          skip
        };
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o
  