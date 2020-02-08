config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
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
      #{config.fix_underscore}__pausers : roles_Role;
    end;
    """#"
    make_test text_i, text_o
  