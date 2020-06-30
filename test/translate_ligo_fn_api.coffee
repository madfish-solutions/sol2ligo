config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section fn api", ()->
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
    type state is unit;
    
    function asserts (const #{config.contract_storage} : state) : (list(operation) * state) is
      block {
        const tokenCount : nat = 4n;
        assert((tokenCount < 5n)) (* "Sample text" *);
        assert((tokenCount = 4n));
        failwith("revert");
        failwith("Should fail");
      } with ((nil: list(operation)), #{config.contract_storage});
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
    
    function test (const #{config.contract_storage} : state; const owner : address) : (list(operation) * state * nat) is
      block {
        assert(((case #{config.contract_storage}.balances[owner] of | None -> 0n | Some(x) -> x end) >= 0n)) (* "Overdrawn balance" *);
      } with ((nil: list(operation)), #{config.contract_storage}, 0n);
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
    type state is unit;
    
    function test2 (const #{config.contract_storage} : state; const b0 : bytes) : (state) is
      block {
        const h0 : bytes = sha_256(b0);
        const h1 : bytes = blake2b(b0);
        const h2 : bytes = sha_256(b0);
        const h3 : bytes = sha_256(b0);
      } with (#{config.contract_storage});
    """#"
    make_test text_i, text_o
  
  it "crypto fn", ()->
    text_i = """
    pragma solidity ^0.4.21;

    contract Test {
        function test() public {
            address a = block.coinbase;
            uint256 b = block.difficulty;
            uint256 gl = block.gaslimit;
            uint256 n = block.number;
            bytes memory d = msg.data;
            uint256 g = msg.gas;
            // uint256 g = gasleft();
            bytes4 s = msg.sig;
            uint256 gp = tx.gasprice;
        }
    }
    """#"
    text_o = """
    type state is unit;
    
    function test (const #{config.contract_storage} : state) : (list(operation) * state) is
      block {
        const a : address = tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg;
        const b : nat = 0n;
        const gl : nat = 0n;
        const n : nat = 0n;
        const d : bytes = ("00": bytes);
        const g : nat = 0n;
        const s : bytes = ("00": bytes);
        const gp : nat = 0n;
      } with ((nil: list(operation)), #{config.contract_storage});
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
    
    function test (const #{config.contract_storage} : state; const owner : address) : (list(operation) * state * nat) is
      block {
        assert(((case #{config.contract_storage}.balances[owner] of | None -> 0n | Some(x) -> x end) >= 0n));
      } with ((nil: list(operation)), #{config.contract_storage}, 0n);
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
        type state is unit;
        
        function test (const #{config.contract_storage} : state; const b0 : bytes) : (state) is
          block {
            const h0 : bytes = sha_256(b0);
            const h1 : bytes = blake2b(b0);
            const h2 : bytes = sha_256(b0);
            const h3 : bytes = sha_256(b0);
          } with (#{config.contract_storage});
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
      type state is unit;
      
      function test (const #{config.contract_storage} : state; const b0 : bytes) : (list(operation) * state * bytes) is
        block {
          skip
        } with ((nil: list(operation)), #{config.contract_storage}, (sha_256(b0)));
      """#"
      make_test text_i, text_o
  