config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
  @timeout 10000
  # ###################################################################################################
  #    assert
  # ###################################################################################################
  it "asserts", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Asserts {
      function asserts() public {
        uint tokenCount = 4;
        require(tokenCount < 5, "Sample text");
        assert(tokenCount == 4);
        revert();
        revert("Should fail");
      }
    }
    """#"
    text_o = """
    type state is record
      #{config.empty_state} : int;
    end;
    
    function asserts (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const tokenCount : nat = 4n;
        if (tokenCount < 5n) then {skip} else failwith("Sample text");
        if (tokenCount = 4n) then {skip} else failwith("require fail");
        failwith("revert");
        failwith("Should fail");
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o
  
  it "require", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Require_test {
      mapping (address => uint) balances;
      
      function test(address owner) public returns (uint) {
        require(balances[owner] >= 0, "Overdrawn balance");
        return 0;
      }
    }
    """#"
    text_o = """
    type state is record
      balances : map(address, nat);
    end;
    
    function test (const opList : list(operation); const contractStorage : state; const owner : address) : (list(operation) * state * nat) is
      block {
        if ((case contractStorage.balances[owner] of | None -> 0n | Some(x) -> x end) >= 0n) then {skip} else failwith("Overdrawn balance");
      } with (opList, contractStorage, 0n);
    """#"
    make_test text_i, text_o
  
  it "crypto fn", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    contract UnOpTest {
        function test2(bytes b0) internal {
            bytes32 h0 = sha256(b0);
            bytes20 h1 = ripemd160(b0);
            bytes32 h2 = sha3(b0);
            bytes32 h3 = keccak256(b0);
        }
    }
    """#"
    text_o = """
    type state is record
      #{config.empty_state} : int;
    end;
    
    function test2 (const opList : list(operation); const contractStorage : state; const b0 : bytes) : (list(operation) * state) is
      block {
        const h0 : bytes = sha_256(b0);
        const h1 : bytes = blake2b(b0);
        const h2 : bytes = sha_256(b0);
        const h3 : bytes = sha_256(b0);
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o
  
  it "require 0.4", ()->
    text_i = """
    pragma solidity >=0.4.21;
    
    contract Require_test {
      mapping (address => uint) balances;
      
      function test(address owner) public returns (uint) {
        require(balances[owner] >= 0);
        return 0;
      }
    }
    """#"
    text_o = """
    type state is record
      balances : map(address, nat);
    end;
    
    function test (const opList : list(operation); const contractStorage : state; const owner : address) : (list(operation) * state * nat) is
      block {
        if ((case contractStorage.balances[owner] of | None -> 0n | Some(x) -> x end) >= 0n) then {skip} else failwith("require fail");
      } with (opList, contractStorage, 0n);
    """#"
    make_test text_i, text_o
  
  # ###################################################################################################
  #    hash functions
  # ###################################################################################################
  describe "bytesX hash functions", ()->
    for type in config.bytes_type_list
      it "hash functions (#{type})", ()->
        text_i = """
        pragma solidity ^0.4.16;
        
        contract Hash_fn_Test {
          function test(#{type} b0) internal {
            bytes32 h0 = sha256(b0);
            bytes20 h1 = ripemd160(b0);
            bytes32 h2 = sha3(b0);
            bytes32 h3 = keccak256(b0);
          }
        }
        """#"
        text_o = """
        type state is record
          #{config.empty_state} : int;
        end;
        
        function test (const opList : list(operation); const contractStorage : state; const b0 : bytes) : (list(operation) * state) is
          block {
            const h0 : bytes = sha_256(b0);
            const h1 : bytes = blake2b(b0);
            const h2 : bytes = sha_256(b0);
            const h3 : bytes = sha_256(b0);
          } with (opList, contractStorage);
        """#"
        make_test text_i, text_o
    
    it "hash functions (bytes) assign to bytes", ()->
      text_i = """
      pragma solidity ^0.4.22;
      
      contract Hash_fn_Test {
        function test(bytes b0) returns (bytes) {
          return abi.encodePacked(sha256(b0));
        }
      }
      """#"
      text_o = """
      type state is record
        #{config.empty_state} : int;
      end;
      
      function test (const opList : list(operation); const contractStorage : state; const b0 : bytes) : (list(operation) * state * bytes) is
        block {
          const tmp_0 : bytes = (sha_256(b0));
        } with (opList, contractStorage, tmp_0);
      """#"
      make_test text_i, text_o
  