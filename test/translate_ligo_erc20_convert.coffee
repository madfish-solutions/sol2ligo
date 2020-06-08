assert = require "assert"
config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

# template for convenience
sol_erc20face_template = """
  contract ERC20TokenFace {
    function totalSupply() public constant returns (uint256 totalSupply);
    function balanceOf(address _owner) public constant returns (uint256 balance);
    // solhint-disable-next-line no-simple-event-func-name
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
  }
"""

describe "erc20 conversions", ()->
  @timeout 10000
  it "erc20_convert", ()->
    #TODO make calls from 'token' not 'ERC20TokenFace(0x0)'
    text_i = """
    pragma solidity ^0.4.16;

    #{sol_erc20face_template}

    contract eee {
      function test() private {
        ERC20TokenFace token = ERC20TokenFace(0x0);
        uint supply = ERC20TokenFace(0x0).totalSupply();
        uint bal = ERC20TokenFace(0x0).balanceOf(msg.sender);
        uint allowance = ERC20TokenFace(0x0).allowance(0x0, msg.sender);
        ERC20TokenFace(0x0).transferFrom(msg.sender, 0x0, 50);
        ERC20TokenFace(0x0).transfer(msg.sender, 50);
        ERC20TokenFace(0x0).approve(msg.sender, 5);
      }
    }
    """
    #TODO UNKNOWN_TYPE_ERC20TokenFace
    text_o = """
    type state is unit;
    
    #include "fa1.2.ligo";
    function getAllowanceCallback (const self : state; const arg : nat) : (list(operation) * state) is
      block {
        (* This method should handle return value of GetAllowance of foreign contract *)
      } with ((nil: list(operation)), self);
    
    function getBalanceCallback (const self : state; const arg : nat) : (list(operation) * state) is
      block {
        (* This method should handle return value of GetBalance of foreign contract *)
      } with ((nil: list(operation)), self);
    
    function getTotalSupplyCallback (const self : state; const arg : nat) : (list(operation) * state) is
      block {
        (* This method should handle return value of GetTotalSupply of foreign contract *)
      } with ((nil: list(operation)), self);
    
    function test (const #{config.contract_storage} : state) : (list(operation) * state) is
      block {
        const token : UNKNOWN_TYPE_ERC20TokenFace = eRC20TokenFace(0x0);
        const supply : nat = const op0 : operation = transaction((Tezos.self("%GetTotalSupplyCallback")), 0mutez, (get_contract(ERC20TokenFace(0x0)) : contract(GetTotalSupply)));
        const bal : nat = const op1 : operation = transaction((sender, Tezos.self("%GetBalanceCallback")), 0mutez, (get_contract(ERC20TokenFace(0x0)) : contract(GetBalance)));
        const allowance : nat = const op2 : operation = transaction((0x0, sender, Tezos.self("%GetAllowanceCallback")), 0mutez, (get_contract(ERC20TokenFace(0x0)) : contract(GetAllowance)));
        const op3 : operation = transaction((sender, 0x0, 50n), 0mutez, (get_contract(ERC20TokenFace(0x0)) : contract(Transfer)));
        const op4 : operation = transaction((sender, sender, 50n), 0mutez, (get_contract(ERC20TokenFace(0x0)) : contract(Transfer)));
        const op5 : operation = transaction((sender, 5n), 0mutez, (get_contract(ERC20TokenFace(0x0)) : contract(Approve)));
      } with (list [op0; op1; op2; op3; op4; op5], #{config.contract_storage});
    """#"
    make_test text_i, text_o

  it "callback dummy declaration", ()->
    #TODO make calls from 'token' not 'ERC20TokenFace(0x0)'
    text_i = """
    pragma solidity ^0.4.16;

    #{sol_erc20face_template}

    contract CBD {
      function test() private {
        uint allowance = ERC20TokenFace(0x0).allowance(0x0, msg.sender);
      }
    }
    """
    text_o = """
    type getAllowanceCallback_args is record
      arg : nat;
    end;

    type state is unit;

    #include "fa1.2.ligo";
    type router_enum is
      | GetAllowanceCallback of getAllowanceCallback_args;

    function getAllowanceCallback (const self : state; const arg : nat) : (list(operation) * state) is
      block {
        (* This method should handle return value of GetAllowance of foreign contract *)
      } with ((nil: list(operation)), self);

    function test (const self : state) : (list(operation) * state) is
      block {
        const allowance : nat = const op0 : operation = transaction((0x0, sender, Tezos.self("%GetAllowanceCallback")), 0mutez, (get_contract(ERC20TokenFace(0x0)) : contract(GetAllowance)));
      } with (list [op0], self);

    function main (const action : router_enum; const self : state) : (list(operation) * state) is
      (case action of
      | GetAllowanceCallback(match_action) -> getAllowanceCallback(self, match_action.arg)
      end);

    """#"
    make_test text_i, text_o, router: true

  it "mixed address and erc20 calls", ()->
    #TODO make calls from 'token' not 'ERC20TokenFace(0x0)'
    text_i = """
    pragma solidity ^0.4.16;

    #{sol_erc20face_template}

    contract CBD {
      function test() private {
        uint allowance = ERC20TokenFace(0x0).allowance(0x0, msg.sender);
        msg.sender.transfer(40);
      }
    }
    """
    text_o = """
    type state is unit;

    #include "fa1.2.ligo";
    function getAllowanceCallback (const self : state; const arg : nat) : (list(operation) * state) is
      block {
        (* This method should handle return value of GetAllowance of foreign contract *)
      } with ((nil: list(operation)), self);

    function test (const self : state) : (list(operation) * state) is
      block {
        const allowance : nat = const op0 : operation = transaction((0x0, sender, Tezos.self("%GetAllowanceCallback")), 0mutez, (get_contract(ERC20TokenFace(0x0)) : contract(GetAllowance)));
        const op1 : operation = transaction((unit), (40n * 1mutez), (get_contract(sender) : contract(unit)));
      } with (list [op0; op1], self);
    """#"
    make_test text_i, text_o

