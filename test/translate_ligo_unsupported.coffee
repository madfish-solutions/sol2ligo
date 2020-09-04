assert = require "assert"
config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section unsupported", ()->
  @timeout 10000
  # ###################################################################################################
  #    there are no support in LIGO
  # ###################################################################################################
  # NOTE this test will produce invalid code, that will compile with Ligo 
  it "UNSUPPORTED break continue", ()->
    text_i = """
    pragma solidity ^0.5.0;
    
    contract Recursive_test {
      function test() public {
        while(false) {
          break;
          continue;
        }
      }
    }
    """
    text_o = """
    type state is unit;
    
    function test (const #{config.reserved}__unit : unit) : (unit) is
      block {
        while (False) block {
          (* `break` statement is not supported in LIGO *);
          (* `continue` statement is not supported in LIGO *);
        };
      } with (unit);
    """#"
    make_test text_i, text_o, allow_need_prevent_deploy:true
  
  # NOTE this test will not compile with Ligo
  it "ecrecover", ()->
    text_i = """
    pragma solidity ^0.5.0;
    
    contract ECDSA {
      function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) pure public returns (address) {
        return ecrecover(hash, v, r, s);
      }
    }
    """
    text_o = """
    type state is unit;
    
    function recover (const hash : bytes; const v : nat; const r : bytes; const s : bytes) : (address) is
      block {
        skip
      } with (ecrecover(hash, v, r, s));
    """#"
    make_test text_i, text_o, no_ligo:true
  
  # ###################################################################################################
  #    unimplemented yet
  # ###################################################################################################
  it "ecrecover", ()->
    text_i = """
    pragma solidity ^0.4.13;
    
    contract DSAuthority {
      
    }
    
    contract DSAuth {
      function isAuthorized() {
        DSAuthority(0);
      }
    }
    """
    text_o = """
    type state is unit;
    
    const burn_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    function isAuthorized (const test_reserved_long___unit : unit) : (unit) is
      block {
        burn_address;
      } with (unit);
    """#"
    make_test text_i, text_o, no_ligo:true
