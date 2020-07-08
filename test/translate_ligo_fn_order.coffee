config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section fn order", ()->
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
    type state is unit;
    
    (* modifier auth inlined *)
    
    function setAuthority (const #{config.reserved}__unit : unit) : (unit) is
      block {
        skip
      } with (unit);
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
    type state is unit;
    
    (* modifier auth inlined *)
    
    function isAuthorized (const #{config.reserved}__unit : unit) : (bool) is
      block {
        skip
      } with (False);
    
    function setAuthority (const #{config.reserved}__unit : unit) : (unit) is
      block {
        assert(isAuthorized(unit));
      } with (unit);
    """#"
    make_test text_i, text_o
  
  # NOTE this test will not compile with Ligo
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
    type state is unit;
    
    function test (const #{config.reserved}__unit : unit) : (unit) is
      block {
        if (False) then block {
          test(unit);
        } else block {
          skip
        };
      } with (unit);
    """#"
    make_test text_i, text_o, no_ligo:true
  