assert = require "assert"
config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

# template for convenience
sol_erc721face_template = """
  interface ERC721 /* is ERC165 */ {
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
  }
"""

describe "erc721 conversions", ()->
  @timeout 10000
  it "erc721 convert", ()->
    #TODO make calls from 'token' not 'ERC20TokenFace(0x0)'
    text_i = """
    pragma solidity ^0.4.16;

    #{sol_erc721face_template}

    contract eee {
      function test() private {
        ERC721(0x0).transferFrom(msg.sender, 0x0, 32);
        uint b = ERC721(0x0).balanceOf(msg.sender);
        ERC721(0x0).approve(msg.sender, 0);
        ERC721(0x0).setApprovalForAll(msg.sender, false);
      }
    }
    """
    text_o = """
    type state is unit;
    
    #include "fa2.ligo";
    function balance_ofCallback (const arg : list(balance_of_response_michelson)) : (unit) is
      block {
        failwith("This method should handle return value of Balance_of of foreign contract. Read more at https://git.io/JfDxR");
      } with (unit);

    function test (const #{config.op_list} : list(operation)) : (list(operation)) is
      block {
        const op0 : operation = transaction((Transfer(list [(list [(32n, (0x0, 1n))], Tezos.sender)])), 0mutez, (get_contract(("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) : contract(fa2_entry_points)));
        const b : nat = const op1 : operation = transaction((Balance_of((list [(0n, Tezos.sender)], (Tezos.self("%Balance_ofCallback") : contract(list(balance_of_response_michelson)))))), 0mutez, (get_contract(("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) : contract(fa2_entry_points)));
        const op2 : operation = transaction((Update_operators(list [Layout.convert_to_right_comb(Add_operator((Tezos.sender, Tezos.sender)))])), 0mutez, (get_contract(("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) : contract(fa2_entry_points)));
        const op3 : operation = transaction((Update_operators(list [Layout.convert_to_right_comb(Remove_operator((Tezos.sender, Tezos.sender)))])), 0mutez, (get_contract(("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) : contract(fa2_entry_points)));
      } with (list [op0; op1; op2; op3]);
    """
    make_test text_i, text_o, prefer_erc721: true
