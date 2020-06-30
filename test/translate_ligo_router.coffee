config = require("../src/config")
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section router", ()->
  @timeout 10000
  it "router with args (BROKEN vertical align)", ()->
    text_i = """
    pragma solidity >=0.5.0 <0.6.0;
    
    contract Router {
      function oneArgFunction(uint amount) public {  }
      function twoArgsFunction(address dest, uint amount) public {  }
    }
    """#"
    text_o = """
    type oneArgFunction_args is record
      #{config.reserved}__amount : nat;
    end;
    
    type twoArgsFunction_args is record
      dest : address;
      #{config.reserved}__amount : nat;
    end;
    
    type state is unit;
    
    type router_enum is
      | OneArgFunction of oneArgFunction_args
     | TwoArgsFunction of twoArgsFunction_args;
    
    function oneArgFunction (const #{config.contract_storage} : state; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with ((nil: list(operation)), #{config.contract_storage});
    
    function twoArgsFunction (const #{config.contract_storage} : state; const dest : address; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with ((nil: list(operation)), #{config.contract_storage});
    
    function main (const action : router_enum; const #{config.contract_storage} : state) : (list(operation) * state) is
      (case action of
      | OneArgFunction(match_action) -> oneArgFunction(self, match_action.test_reserved_long___amount)
      | TwoArgsFunction(match_action) -> twoArgsFunction(self, match_action.dest, match_action.test_reserved_long___amount)
      end);
    """
    make_test text_i, text_o, {
      router: true
    }
  
  it "router private method", ()->
    text_i = """
    pragma solidity >=0.5.0 <0.6.0;
    
    contract Router {
      function oneArgFunction(uint amount) private {  }
      function twoArgsFunction(address dest, uint amount) public {  }
    }
    """#"
    text_o = """
    type twoArgsFunction_args is record
      dest : address;
      #{config.reserved}__amount : nat;
    end;
    
    type state is unit;
    
    type router_enum is
      | TwoArgsFunction of twoArgsFunction_args;
    
    function oneArgFunction (const #{config.contract_storage} : state; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with ((nil: list(operation)), #{config.contract_storage});
    
    function twoArgsFunction (const #{config.contract_storage} : state; const dest : address; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with ((nil: list(operation)), #{config.contract_storage});
    
    function main (const action : router_enum; const #{config.contract_storage} : state) : (list(operation) * state) is
      (case action of
      | TwoArgsFunction(match_action) -> twoArgsFunction(self, match_action.dest, match_action.test_reserved_long___amount)
      end);
    """
    make_test text_i, text_o, {
      router: true
    }
  
  it "router internal method", ()->
    text_i = """
    pragma solidity >=0.5.0 <0.6.0;
    
    contract Router {
      function oneArgFunction(uint amount) internal {  }
      function twoArgsFunction(address dest, uint amount) public {  }
    }
    """#"
    text_o = """
    type twoArgsFunction_args is record
      dest : address;
      #{config.reserved}__amount : nat;
    end;
    
    type state is unit;
    
    type router_enum is
      | TwoArgsFunction of twoArgsFunction_args;
    
    function oneArgFunction (const #{config.contract_storage} : state; const #{config.reserved}__amount : nat) : (state) is
      block {
        skip
      } with (#{config.contract_storage});
    
    function twoArgsFunction (const #{config.contract_storage} : state; const dest : address; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with ((nil: list(operation)), #{config.contract_storage});
    
    function main (const action : router_enum; const #{config.contract_storage} : state) : (list(operation) * state) is
      (case action of
      | TwoArgsFunction(match_action) -> twoArgsFunction(self, match_action.dest, match_action.test_reserved_long___amount)
      end);
    """
    make_test text_i, text_o, {
      router: true
    }
