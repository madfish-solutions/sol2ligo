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
    
    const ballot_Voter_default : ballot_Voter = record [ votee = burn_address;
      voted = False ];
    
    function ddd (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const v : ballot_Voter = record [ votee = Tezos.sender;
          voted = True ];
      } with (unit);
    """
    make_test text_i, text_o
  
  it "struct type inference 1", ()->
    text_i = """
    pragma solidity ^0.5.0;
    
    contract C {
      struct S {
        int8 v;
        uint8 w;
      }
      function f() public {
        S memory s = S(2, 5);
      }
    }
    """
    text_o = """
    type c_S is record
      v : int;
      w : nat;
    end;
    
    type state is unit;
    
    const c_S_default : c_S = record [ v = 0;
      w = 0n ];
    
    function f (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const s : c_S = record [ v = 2;
          w = 5n ];
      } with (unit);
    """
    make_test text_i, text_o
  
  it "struct type inference 2", ()->
    text_i = """
    pragma solidity ^0.4.21;
    
    contract C {
      struct S {
        int8 v;
        uint8 w;
      }
      function f() public {
        var s = S(2, 5);
      }
    }
    """
    text_o = """
    type c_S is record
      v : int;
      w : nat;
    end;
    
    type state is unit;
    
    const c_S_default : c_S = record [ v = 0;
      w = 0n ];
    
    function f (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const s : c_S = record [ v = 2;
          w = 5n ];
      } with (unit);
    """
    make_test text_i, text_o
