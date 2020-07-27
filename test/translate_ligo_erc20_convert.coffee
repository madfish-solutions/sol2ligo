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
  perr "NOTE all those tests are broken and need to be fixed; Problem is with opList usage. Only 1 test remains broken intentionally"
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
    function getAllowanceCallback (const arg : nat) : (unit) is
      block {
        (* This method should handle return value of GetAllowance of foreign contract. Read more at https://git.io/JfDxR *)
      } with (unit);
    
    function getBalanceCallback (const arg : nat) : (unit) is
      block {
        (* This method should handle return value of GetBalance of foreign contract. Read more at https://git.io/JfDxR *)
      } with (unit);
    
    function getTotalSupplyCallback (const arg : nat) : (unit) is
      block {
        (* This method should handle return value of GetTotalSupply of foreign contract. Read more at https://git.io/JfDxR *)
      } with (unit);
    
    function test (const #{config.op_list} : list(operation)) : (list(operation)) is
      block {
        const token : UNKNOWN_TYPE_ERC20TokenFace = eRC20TokenFace(0x0);
        const supply : nat = const op0 : operation = transaction((Tezos.self("%GetTotalSupplyCallback")), 0mutez, (get_contract(("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) : contract(GetTotalSupply)));
        const bal : nat = const op1 : operation = transaction((Tezos.sender, Tezos.self("%GetBalanceCallback")), 0mutez, (get_contract(("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) : contract(GetBalance)));
        const allowance : nat = const op2 : operation = transaction((0x0, Tezos.sender, Tezos.self("%GetAllowanceCallback")), 0mutez, (get_contract(("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) : contract(GetAllowance)));
        const op3 : operation = transaction((Tezos.sender, 0x0, 50n), 0mutez, (get_contract(("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) : contract(Transfer)));
        const op4 : operation = transaction((Tezos.sender, Tezos.sender, 50n), 0mutez, (get_contract(("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) : contract(Transfer)));
        const op5 : operation = transaction((Tezos.sender, 5n), 0mutez, (get_contract(("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) : contract(Approve)));
      } with (list [op0; op1; op2; op3; op4; op5]);
    """#"
    make_test text_i, text_o

  it "callback dummy declaration", ()->
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

    function getAllowanceCallback (const arg : nat) : (unit) is
      block {
        (* This method should handle return value of GetAllowance of foreign contract. Read more at https://git.io/JfDxR *)
      } with (unit);

    function test (const #{config.op_list} : list(operation)) : (list(operation)) is
      block {
        const allowance : nat = const op0 : operation = transaction((0x0, Tezos.sender, Tezos.self("%GetAllowanceCallback")), 0mutez, (get_contract(("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) : contract(GetAllowance)));
      } with (list [op0]);

    function main (const action : router_enum; const self : state) : (list(operation) * state) is
      (case action of
      | GetAllowanceCallback(match_action) -> block {
        (* This function does nothing, but it's present in router *)
        const tmp : unit = getAllowanceCallback(match_action.arg);
      } with (((nil: list(operation)), self))
      end);

    """#"
    make_test text_i, text_o, router: true

  it "mixed address and erc20 calls", ()->
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
    function getAllowanceCallback (const arg : nat) : (unit) is
      block {
        (* This method should handle return value of GetAllowance of foreign contract. Read more at https://git.io/JfDxR *)
      } with (unit);

    function test (const #{config.op_list} : list(operation)) : (list(operation)) is
      block {
        const allowance : nat = const op0 : operation = transaction((0x0, Tezos.sender, Tezos.self("%GetAllowanceCallback")), 0mutez, (get_contract(("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) : contract(GetAllowance)));
        const op1 : operation = transaction((unit), (40n * 1mutez), (get_contract(sender) : contract(unit)));
      } with (list [op0; op1]);
    """#"
    make_test text_i, text_o


