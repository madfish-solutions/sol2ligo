config = require("../src/config")
{
  translate_ligo_make_test : make_test
} = require("./util")


describe "translate ligo section stmt", ()->
  @timeout 10000
  # ###################################################################################################
  #    stmt
  # ###################################################################################################
  it "var_decl_multi", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    contract Main {
      function fromBytes(bytes memory bts) internal pure returns (uint addr, uint len) {
        
      }
      function main(bytes memory self, bytes memory other) {
        var (src, srcLen) = fromBytes(self);
      }
    }
    """
    text_o = """
    type state is unit;
    
    function fromBytes (const bts : bytes) : ((nat * nat)) is
      block {
        const addr : nat = 0n;
        const len : nat = 0n;
      } with ((addr, len));
    
    function #{config.reserved}__main (const test_reserved_long___self : bytes; const other : bytes) : (unit) is
      block {
        const tmp_0 : (nat * nat) = fromBytes(test_reserved_long___self);
        const src : nat = tmp_0.0;
        const srcLen : nat = tmp_0.1;
      } with (unit);
    """
    make_test text_i, text_o
  
  it "if", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Ifer {
      uint public value;
      
      function ifer() public returns (uint) {
        uint x = 5;
        uint ret = 0;
        if (x == 5) {
          ret = value + x;
        }
        else  {
          ret = 0;
        }
        return ret;
      }
    }
    """
    text_o = """
    type state is record
      value : nat;
    end;
    
    function ifer (const contract_storage : state) : (nat) is
      block {
        const x : nat = 5n;
        const ret : nat = 0n;
        if (x = 5n) then block {
          ret := (contract_storage.value + x);
        } else block {
          ret := 0n;
        };
      } with (ret);
    
    """
    make_test text_i, text_o
  
  
  it "while", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Whiler {
      function whiler(address owner) public returns (int) {
        int i = 0;
        while(i < 5) {
          i += 1;
        }
        return i;
      }
    }
    """#"
    text_o = """
    type state is unit;
    
    function whiler (const owner : address) : (int) is
      block {
        const i : int = 0;
        while (i < 5) block {
          i := (i + 1);
        };
      } with (i);
    """
    make_test text_i, text_o
  
  # ###################################################################################################
  #    for
  # ###################################################################################################
  it "for", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Forer {
      function forer(address owner) public returns (int) {
        int i = 0;
        for(i=2;i < 5;i+=10) {
          i += 1;
        }
        return i;
      }
    }
    """#"
    text_o = """
    type state is unit;
    
    function forer (const owner : address) : (int) is
      block {
        const i : int = 0;
        i := 2;
        while (i < 5) block {
          i := (i + 1);
          i := (i + 10);
        };
      } with (i);
    """
    make_test text_i, text_o
  
  it "for no init", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Forer {
      function forer(address owner) public returns (int) {
        int i = 0;
        for(;i < 5;i+=10) {
          i += 1;
        }
        return i;
      }
    }
    """#"
    text_o = """
    type state is unit;
    
    function forer (const owner : address) : (int) is
      block {
        const i : int = 0;
        while (i < 5) block {
          i := (i + 1);
          i := (i + 10);
        };
      } with (i);
    """
    make_test text_i, text_o
  
  it "for no cond", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Forer {
      function forer(address owner) public returns (int) {
        int i = 0;
        for(i=2;;i+=10) {
          i += 1;
        }
        return i;
      }
    }
    """#"
    text_o = """
    type state is unit;
    
    function forer (const owner : address) : (int) is
      block {
        const i : int = 0;
        i := 2;
        while (True) block {
          i := (i + 1);
          i := (i + 10);
        };
      } with (i);
    """
    make_test text_i, text_o
  
  it "for no iter", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Forer {
      function forer(address owner) public returns (int) {
        int i = 0;
        for(i=2;i < 5;) {
          i += 1;
        }
        return i;
      }
    }
    """#"
    text_o = """
    type state is unit;
    
    function forer (const owner : address) : (int) is
      block {
        const i : int = 0;
        i := 2;
        while (i < 5) block {
          i := (i + 1);
        };
      } with (i);
    """
    make_test text_i, text_o
  
  it "for with body of no scope", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    contract Body_no_scope {
      function test() returns (int256) {
        for (uint256 i = 0; false;)
          if (i > 0) i = 2;
        return 0;
      }
    }
    """#"
    text_o = """
    type state is unit;
    
    function test (const #{config.reserved}__unit : unit) : (int) is
      block {
        const i : nat = 0n;
        while (False) block {
          if (i > 0n) then block {
            i := 2n;
          } else block {
            skip
          };
        };
      } with (0);
    """
    make_test text_i, text_o
  
