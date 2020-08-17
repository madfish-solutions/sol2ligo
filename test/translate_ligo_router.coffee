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
    
    function oneArgFunction (const #{config.reserved}__amount : nat) : (unit) is
      block {
        skip
      } with (unit);
    
    function twoArgsFunction (const dest : address; const #{config.reserved}__amount : nat) : (unit) is
      block {
        skip
      } with (unit);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | OneArgFunction(match_action) -> block {
        (* This function does nothing, but it's present in router *)
        const tmp : unit = oneArgFunction(match_action.test_reserved_long___amount);
      } with (((nil: list(operation)), contract_storage))
      | TwoArgsFunction(match_action) -> block {
        (* This function does nothing, but it's present in router *)
        const tmp : unit = twoArgsFunction(match_action.dest, match_action.test_reserved_long___amount);
      } with (((nil: list(operation)), contract_storage))
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
    
    function oneArgFunction (const #{config.reserved}__amount : nat) : (unit) is
      block {
        skip
      } with (unit);
    
    function twoArgsFunction (const dest : address; const #{config.reserved}__amount : nat) : (unit) is
      block {
        skip
      } with (unit);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | TwoArgsFunction(match_action) -> block {
        (* This function does nothing, but it's present in router *)
        const tmp : unit = twoArgsFunction(match_action.dest, match_action.test_reserved_long___amount);
      } with (((nil: list(operation)), contract_storage))
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
    
    function oneArgFunction (const #{config.reserved}__amount : nat) : (unit) is
      block {
        skip
      } with (unit);
    
    function twoArgsFunction (const dest : address; const #{config.reserved}__amount : nat) : (unit) is
      block {
        skip
      } with (unit);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | TwoArgsFunction(match_action) -> block {
        (* This function does nothing, but it's present in router *)
        const tmp : unit = twoArgsFunction(match_action.dest, match_action.test_reserved_long___amount);
      } with (((nil: list(operation)), contract_storage))
      end);
    """
    make_test text_i, text_o, {
      router: true
    }
