assert = require "assert"
config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

# template for convenience
sol_erc20face_template = """
  contract ERC20TokenFace {
    function totalSupply() public constant returns (uint256);
    function balanceOf(address _owner) public constant returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public constant returns (uint256);
  }
"""

describe "erc20 conversions", ()->
  perr "NOTE all those tests are broken and need to be fixed; Problem is with opList usage."
  @timeout 10000
  it "erc20_convert", ()->
    ### TODO mechanism and tests for returned values like
      uint supply = ERC20TokenFace(0x0).totalSupply();
      uint bal = ERC20TokenFace(0x0).balanceOf(msg.sender);
      uint allowance = ERC20TokenFace(0x0).allowance(0x0, msg.sender);
    ###
    text_i = """
    pragma solidity ^0.4.16;

    #{sol_erc20face_template}

    contract eee {
      function test() private {
        ERC20TokenFace(0x0).totalSupply();
        ERC20TokenFace(0x0).balanceOf(msg.sender);
        ERC20TokenFace(0x0).allowance(0x0, msg.sender);
        ERC20TokenFace(0x0).transferFrom(msg.sender, 0x0, 50);
        ERC20TokenFace(0x0).transfer(msg.sender, 50);
        ERC20TokenFace(0x0).approve(msg.sender, 5);
      }
    }
    """
    text_o = """
    type state is unit;
    
    const burn_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    
    #include "interfaces/fa1.2.ligo"
    function getAllowanceCallback (const arg : nat) : (unit) is
      block {
        failwith("This method should handle return value of GetAllowance of foreign contract. Read more at https://git.io/JfDxR");
      } with (unit);
    
    function getBalanceCallback (const arg : nat) : (unit) is
      block {
        failwith("This method should handle return value of GetBalance of foreign contract. Read more at https://git.io/JfDxR");
      } with (unit);
    
    function getTotalSupplyCallback (const arg : nat) : (unit) is
      block {
        failwith("This method should handle return value of GetTotalSupply of foreign contract. Read more at https://git.io/JfDxR");
      } with (unit);
    
    function test (const opList : list(operation)) : (list(operation)) is
      block {
        const op0 : operation = transaction((GetTotalSupply(unit, (Tezos.self("%getTotalSupplyCallback") : contract(nat)))), 0mutez, (get_contract(burn_address) : contract(fa12_action)));
        const op1 : operation = transaction((GetBalance(Tezos.sender, (Tezos.self("%getBalanceCallback") : contract(nat)))), 0mutez, (get_contract(burn_address) : contract(fa12_action)));
        const op2 : operation = transaction((GetAllowance(burn_address, Tezos.sender, (Tezos.self("%getAllowanceCallback") : contract(nat)))), 0mutez, (get_contract(burn_address) : contract(fa12_action)));
        const op3 : operation = transaction((Transfer(Tezos.sender, burn_address, 50n)), 0mutez, (get_contract(burn_address) : contract(fa12_action)));
        const op4 : operation = transaction((Transfer(Tezos.sender, Tezos.sender, 50n)), 0mutez, (get_contract(burn_address) : contract(fa12_action)));
        const op5 : operation = transaction((Approve(Tezos.sender, 5n)), 0mutez, (get_contract(burn_address) : contract(fa12_action)));
      } with (list [op0; op1; op2; op3; op4; op5]);
    """#"
    make_test text_i, text_o

  it "callback dummy declaration", ()->
    text_i = """
    pragma solidity ^0.4.16;

    #{sol_erc20face_template}

    contract CBD {
      function test() private {
        ERC20TokenFace(0x0).allowance(0x0, msg.sender);
      }
    }
    """
    text_o = """
    type getAllowanceCallback_args is record
      arg : nat;
    end;

    type state is unit;

    const burn_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    
    #include "interfaces/fa1.2.ligo"
    type router_enum is
      | GetAllowanceCallback of getAllowanceCallback_args;

    function getAllowanceCallback (const arg : nat) : (unit) is
      block {
        failwith("This method should handle return value of GetAllowance of foreign contract. Read more at https://git.io/JfDxR");
      } with (unit);

    function test (const opList : list(operation)) : (list(operation)) is
      block {
        const op0 : operation = transaction((GetAllowance(burn_address, Tezos.sender, (Tezos.self("%getAllowanceCallback") : contract(nat)))), 0mutez, (get_contract(burn_address) : contract(fa12_action)));
      } with (list [op0]);

    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | GetAllowanceCallback(match_action) -> block {
        (* This function does nothing, but it's present in router *)
        const tmp : unit = getAllowanceCallback(match_action.arg);
      } with (((nil: list(operation)), contract_storage))
      end);

    """#"
    make_test text_i, text_o, router: true

  it "mixed address and erc20 calls", ()->
    text_i = """
    pragma solidity ^0.4.16;

    #{sol_erc20face_template}

    contract CBD {
      function test() private {
        ERC20TokenFace(0x0).allowance(0x0, msg.sender);
        msg.sender.transfer(40);
      }
    }
    """
    text_o = """
    type state is unit;

    const burn_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    
    #include "interfaces/fa1.2.ligo"
    function getAllowanceCallback (const arg : nat) : (unit) is
      block {
        failwith("This method should handle return value of GetAllowance of foreign contract. Read more at https://git.io/JfDxR");
      } with (unit);

    function test (const opList : list(operation)) : (list(operation)) is
      block {
        const op0 : operation = transaction((GetAllowance(burn_address, Tezos.sender, (Tezos.self("%getAllowanceCallback") : contract(nat)))), 0mutez, (get_contract(burn_address) : contract(fa12_action)));
        const op1 : operation = transaction((unit), (40n * 1mutez), (get_contract(Tezos.sender) : contract(unit)));
      } with (list [op0; op1]);
    """#"
    make_test text_i, text_o

 it "erc20 preassigned var", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    #{sol_erc20face_template}
    
    contract eee {
      function test() private {
        ERC20TokenFace token = ERC20TokenFace(0x0);
        token.transferFrom(msg.sender, 0x0, 64);
      }
    }
    """
    #TODO this is some crazy input type due to bug: last line being comment breaks return type inference
    text_o = """
    type state is unit;
    
    const burn_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    
    #include "interfaces/fa1.2.ligo"
    function test (const opList : list(operation)) : (list(operation)) is
      block {
        const token : address = burn_address;
        const op0 : operation = transaction((Transfer(Tezos.sender, burn_address, 64n)), 0mutez, (get_contract(token) : contract(fa12_action)));
      } with (list [op0]);
    """
    # a foreign contract call raises the need_prevent_deploy flag
    make_test text_i, text_o, allow_need_prevent_deploy: true
  
  it "erc20 interface skeleton", ()->
    text_i = """
    pragma solidity ^0.4.26;

    contract ERC20Basic {
        mapping(address => uint256) balances;

        mapping(address => mapping (address => uint256)) allowed;

        function totalSupply() public view returns (uint256) {
    	    return 80000;
        }

        function balanceOf(address tokenOwner) public view returns (uint) {
            return balances[tokenOwner];
        }

        function transfer(address receiver, uint numTokens) public returns (bool) {
          require(numTokens <= balances[msg.sender]);
          balances[msg.sender] = balances[msg.sender] - numTokens;
          balances[receiver] = balances[receiver] + numTokens;
          return true;
        }

        function approve(address delegate, uint numTokens) public returns (bool) {
            allowed[msg.sender][delegate] = numTokens;
            return true;
        }

        function allowance(address owner, address delegate) public view returns (uint) {
            return allowed[owner][delegate];
        }

        function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
            require(numTokens <= balances[owner]);    
            require(numTokens <= allowed[owner][msg.sender]);
        
            balances[owner] = balances[owner] - numTokens;
            allowed[owner][msg.sender] = allowed[owner][msg.sender] - numTokens;
            balances[buyer] = balances[buyer] - numTokens;
            return true;
        }
    }
    """
    text_o = """
    type state is record
      balances : map(address, nat);
      allowed : map(address, map(address, nat));
    end;

    (* in Tezos `totalSupply` method should not return a value, but perform a transaction to the passed contract callback with a needed value *)

    function getTotalSupply (const callback : contract(nat)) : (nat) is
      block {
        skip
      } with (80000n);

    (* in Tezos `balanceOf` method should not return a value, but perform a transaction to the passed contract callback with a needed value *)

    function getBalance (const test_self : state; const tokenOwner : address; const callback : contract(nat)) : (nat) is
      block {
        skip
      } with ((case test_self.balances[tokenOwner] of | None -> 0n | Some(x) -> x end));

    function transfer (const test_self : state; const from : address; const receiver : address; const numTokens : nat) : (state * bool) is
      block {
        assert((numTokens <= (case test_self.balances[Tezos.sender] of | None -> 0n | Some(x) -> x end)));
        test_self.balances[Tezos.sender] := abs((case test_self.balances[Tezos.sender] of | None -> 0n | Some(x) -> x end) - numTokens);
        test_self.balances[receiver] := ((case test_self.balances[receiver] of | None -> 0n | Some(x) -> x end) + numTokens);
      } with (test_self, True);

    function approve (const test_self : state; const delegate : address; const numTokens : nat) : (bool) is
      block {
        const temp_idx_access0 : map(address, nat) = (case test_self.allowed[Tezos.sender] of | None -> (map end : map(address, nat)) | Some(x) -> x end);
        temp_idx_access0[delegate] := numTokens;
      } with (True);

    (* in Tezos `allowance` method should not return a value, but perform a transaction to the passed contract callback with a needed value *)

    function getAllowance (const test_self : state; const owner : address; const delegate : address; const callback : contract(nat)) : (nat) is
      block {
        const temp_idx_access0 : map(address, nat) = (case test_self.allowed[owner] of | None -> (map end : map(address, nat)) | Some(x) -> x end);
      } with ((case temp_idx_access0[delegate] of | None -> 0n | Some(x) -> x end));

    (* `transferFrom` and `transfer` methods should merged into one in Tezos' FA1.2 *)

    function transferFrom (const test_self : state; const owner : address; const buyer : address; const numTokens : nat) : (state * bool) is
      block {
        assert((numTokens <= (case test_self.balances[owner] of | None -> 0n | Some(x) -> x end)));
        const temp_idx_access0 : map(address, nat) = (case test_self.allowed[owner] of | None -> (map end : map(address, nat)) | Some(x) -> x end);
        assert((numTokens <= (case temp_idx_access0[Tezos.sender] of | None -> 0n | Some(x) -> x end)));
        test_self.balances[owner] := abs((case test_self.balances[owner] of | None -> 0n | Some(x) -> x end) - numTokens);
        const temp_idx_access0 : map(address, nat) = (case test_self.allowed[owner] of | None -> (map end : map(address, nat)) | Some(x) -> x end);
        const temp_idx_access1 : map(address, nat) = (case test_self.allowed[owner] of | None -> (map end : map(address, nat)) | Some(x) -> x end);
        temp_idx_access0[Tezos.sender] := abs((case temp_idx_access1[Tezos.sender] of | None -> 0n | Some(x) -> x end) - numTokens);
        test_self.balances[buyer] := abs((case test_self.balances[buyer] of | None -> 0n | Some(x) -> x end) - numTokens);
      } with (test_self, True);
    """
    make_test text_i, text_o

  


