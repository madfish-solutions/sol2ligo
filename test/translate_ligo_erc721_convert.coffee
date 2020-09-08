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
        ERC721(0x0).balanceOf(address(0));
        ERC721(0x0).approve(msg.sender, 0);
        ERC721(0x0).setApprovalForAll(msg.sender, false);
      }
    }
    """
    text_o = """
    type state is unit;
    
    const burn_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    
    #include "interfaces/fa2.ligo"
    function balance_ofCallback (const arg : list(balance_of_response_michelson)) : (unit) is
      block {
        failwith("This method should handle return value of Balance_of of foreign contract. Read more at https://git.io/JfDxR");
      } with (unit);

    function test (const opList : list(operation)) : (list(operation)) is
      block {
        const op0 : operation = transaction((Transfer(list [(list [(32n, (burn_address, 1n))], Tezos.sender)])), 0mutez, (get_contract(burn_address) : contract(fa2_entry_points)));
        const op1 : operation = transaction((Balance_of((list [(0n, burn_address)], (Tezos.self("%Balance_ofCallback") : contract(list(balance_of_response_michelson)))))), 0mutez, (get_contract(burn_address) : contract(fa2_entry_points)));
        const op2 : operation = transaction((Update_operators(list [Layout.convert_to_right_comb(Add_operator((Tezos.sender, Tezos.sender)))])), 0mutez, (get_contract(burn_address) : contract(fa2_entry_points)));
        const op3 : operation = transaction((Update_operators(list [Layout.convert_to_right_comb(Remove_operator((Tezos.sender, Tezos.sender)))])), 0mutez, (get_contract(burn_address) : contract(fa2_entry_points)));
      } with (list [op0; op1; op2; op3]);
    """
    make_test text_i, text_o

  it "erc721 unsupported", ()->
    #TODO make calls from 'token' not 'ERC20TokenFace(0x0)'
    text_i = """
    pragma solidity ^0.4.16;

    #{sol_erc721face_template}

    contract eee {
      function test() private {
        address approvedAddress = ERC721(0x0).getApproved(0);
        ERC721(0x0).safeTransferFrom(msg.sender, 0x0, 32);
      }
    }
    """
    #TODO this is some crazy input type due to bug: last line being comment breaks return type inference
    text_o = """
    type state is unit;
    
    const burn_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    
    #include "interfaces/fa2.ligo"
    function test (const test_reserved_long___unit : unit) : (unit) is
      block {
        const approvedAddress : address = eRC721(0x0).getApproved(0n);
        (* ^ getApproved is not supported in LIGO. Read more https://git.io/JJFij ^ *);
        eRC721(0x0).safeTransferFrom(Tezos.sender, burn_address, 32n);
        (* ^ safeTransferFrom is not supported in LIGO. Read more https://git.io/JJFij ^ *)
      } with (unit);
    """
    make_test text_i, text_o
 
  it "erc721 preassigned var", ()->
    #TODO make calls from 'token' not 'ERC20TokenFace(0x0)'
    text_i = """
    pragma solidity ^0.4.16;

    #{sol_erc721face_template}

    contract eee {
      function test() private {
        ERC721 token = ERC721(0x01);
        token.transferFrom(msg.sender, 0x1, 64);
      }
    }
    """
    #TODO this is some crazy input type due to bug: last line being comment breaks return type inference
    text_o = """
    type state is unit;
    
    #include "interfaces/fa2.ligo"
    function test (const opList : list(operation)) : (list(operation)) is
      block {
        const token : address = (0x01 : address);
        const op0 : operation = transaction((Transfer(list [(list [(64n, ((0x1 : address), 1n))], Tezos.sender)])), 0mutez, (get_contract(token) : contract(fa2_entry_points)));
      } with (list [op0]);
    """
    make_test text_i, text_o


