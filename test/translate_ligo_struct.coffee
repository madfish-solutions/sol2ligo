config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section struct", ()->
  @timeout 10000
  it "struct in state (BROKEN pauserRole_Roles.Role)", ()->
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
      pausers_ : pauserRole_Roles.Role;
    end;
    
    const roles_Role_default : roles_Role = record [ bearer = (map end : map(address, bool)) ];
    """#"
    make_test text_i, text_o
  