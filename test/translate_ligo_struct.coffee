config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section struct", ()->
  @timeout 10000
  it "struct in state", ()->
    text_i = """
    pragma solidity ^0.5.0;
    
    library Roles {
      struct Role {
        mapping (address => bool) bearer;
      }
    }
    
    contract PauserRole {
      Roles.Role private _pausers;
    }
    """
    text_o = """
    type roles_Role is record
      bearer : map(address, bool);
    end;
    
    type state is record
      pausers_ : roles_Role;
    end;
    
    const roles_Role_default : roles_Role = record [ bearer = (map end : map(address, bool)) ];
    """#"
    make_test text_i, text_o

  it "struct init", ()->
    text_i = """
    pragma solidity ^0.5.0;

    contract Ballot {
      struct Voter {
        address votee;
        bool voted;
      }
        
      function ddd() public {
        Voter memory v = Voter({votee: msg.sender, voted: true});
      }
    }
    """
    text_o = """
    type ballot_Voter is record
      votee : address;
      voted : bool;
    end;
    
    type state is unit;

    const ballot_Voter_default : ballot_Voter = record [ votee = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
      voted = False ];

    function ddd (const self : state) : (list(operation) * state) is
      block {
        const v : ballot_Voter = record [ votee = Tezos.sender;
          voted = True ];
      } with (list [], self);
    """
    make_test text_i, text_o
