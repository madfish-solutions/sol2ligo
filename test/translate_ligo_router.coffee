config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "generate router", ()->
  @timeout 10000
  it "router for no-contract", ()->
    text_i = """
    pragma solidity >=0.5.0 <0.6.0;
    """#"
    text_o = """
    type dummy_contract_dummy_fn_args is record
      #{config.reserved}__empty_state : int;
    end;
    
    type state is record
      #{config.reserved}__initialized : bool;
    end;
    
    type dummy_contract_enum is
      | Dummy_fn of dummy_contract_dummy_fn_args;
    
    
    function dummy_fn (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function main (const action : dummy_contract_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        case action of
        | Dummy_fn(match_action) -> block {
          if contractStorage.#{config.reserved}__initialized then {skip} else failwith("can't call this method on non-initialized contract");
          const tmp_0 : (list(operation) * state) = dummy_fn(opList, contractStorage);
          opList := tmp_0.0;
          contractStorage := tmp_0.1;
        }
        end;
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o, {
      router: true
    }
  
  it "router for contract with no methods", ()->
    text_i = """
    pragma solidity >=0.5.0 <0.6.0;
    
    contract Empty_contract {}
    """#"
    text_o = """
    type empty_contract_dummy_fn_args is record
      #{config.reserved}__empty_state : int;
    end;
    
    type state is record
      #{config.reserved}__initialized : bool;
    end;
    
    type empty_contract_enum is
      | Dummy_fn of empty_contract_dummy_fn_args;
    
    
    function dummy_fn (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function main (const action : empty_contract_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        case action of
        | Dummy_fn(match_action) -> block {
          if contractStorage.#{config.reserved}__initialized then {skip} else failwith("can't call this method on non-initialized contract");
          const tmp_0 : (list(operation) * state) = dummy_fn(opList, contractStorage);
          opList := tmp_0.0;
          contractStorage := tmp_0.1;
        }
        end;
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o, {
      router: true
    }
  
  it "router with args", ()->
    text_i = """
    pragma solidity >=0.5.0 <0.6.0;
    
    contract Router {
      function oneArgFunction(uint amount) public {  }
      function twoArgsFunction(address dest, uint amount) public {  }
    }
    """#"
    text_o = """
    type router_oneArgFunction_args is record
      #{config.reserved}__amount : nat;
    end;
    
    type router_twoArgsFunction_args is record
      dest : address;
      #{config.reserved}__amount : nat;
    end;
    
    type state is record
      #{config.initialized} : bool;
    end;
    
    type router_enum is
      | OneArgFunction of router_oneArgFunction_args
      | TwoArgsFunction of router_twoArgsFunction_args;
    
    
    function oneArgFunction (const opList : list(operation); const contractStorage : state; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function twoArgsFunction (const opList : list(operation); const contractStorage : state; const dest : address; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function main (const action : router_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        case action of
        | OneArgFunction(match_action) -> block {
          if contractStorage.#{config.reserved}__initialized then {skip} else failwith("can't call this method on non-initialized contract");
          const tmp_0 : (list(operation) * state) = oneArgFunction(opList, contractStorage, match_action.#{config.reserved}__amount);
          opList := tmp_0.0;
          contractStorage := tmp_0.1;
        }
        | TwoArgsFunction(match_action) -> block {
          if contractStorage.#{config.reserved}__initialized then {skip} else failwith("can't call this method on non-initialized contract");
          const tmp_1 : (list(operation) * state) = twoArgsFunction(opList, contractStorage, match_action.dest, match_action.#{config.reserved}__amount);
          opList := tmp_1.0;
          contractStorage := tmp_1.1;
        }
        end;
      } with (opList, contractStorage);
    """#"
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
    type router_twoArgsFunction_args is record
      dest : address;
      #{config.reserved}__amount : nat;
    end;
    
    type state is record
      #{config.initialized} : bool;
    end;
    
    type router_enum is
      | TwoArgsFunction of router_twoArgsFunction_args;
    
    
    function oneArgFunction (const opList : list(operation); const contractStorage : state; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function twoArgsFunction (const opList : list(operation); const contractStorage : state; const dest : address; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function main (const action : router_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        case action of
        | TwoArgsFunction(match_action) -> block {
          if contractStorage.#{config.reserved}__initialized then {skip} else failwith("can't call this method on non-initialized contract");
          const tmp_0 : (list(operation) * state) = twoArgsFunction(opList, contractStorage, match_action.dest, match_action.#{config.reserved}__amount);
          opList := tmp_0.0;
          contractStorage := tmp_0.1;
        }
        end;
      } with (opList, contractStorage);
    """#"
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
    type router_twoArgsFunction_args is record
      dest : address;
      #{config.reserved}__amount : nat;
    end;
    
    type state is record
      #{config.initialized} : bool;
    end;
    
    type router_enum is
      | TwoArgsFunction of router_twoArgsFunction_args;
    
    
    function oneArgFunction (const opList : list(operation); const contractStorage : state; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function twoArgsFunction (const opList : list(operation); const contractStorage : state; const dest : address; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function main (const action : router_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        case action of
        | TwoArgsFunction(match_action) -> block {
          if contractStorage.#{config.reserved}__initialized then {skip} else failwith("can't call this method on non-initialized contract");
          const tmp_0 : (list(operation) * state) = twoArgsFunction(opList, contractStorage, match_action.dest, match_action.#{config.reserved}__amount);
          opList := tmp_0.0;
          contractStorage := tmp_0.1;
        }
        end;
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o, {
      router: true
    }
  
  it "router 2 contracts", ()->
    text_i = """
    pragma solidity >=0.5.0 <0.6.0;
    
    contract c1 {
      uint a;
      constructor() public {}
      function f1(uint amount) public {  }
    }
    contract c2 {
      uint b;
      constructor() public {}
      function f2(uint amount) public {  }
    }
    """#"
    text_o = """
    type c1_constructor_args is record
      #{config.reserved}__empty_state : int;
    end;
    
    type c1_f1_args is record
      #{config.reserved}__amount : nat;
    end;
    
    type c2_constructor_args is record
      #{config.reserved}__empty_state : int;
    end;
    
    type c2_f2_args is record
      #{config.reserved}__amount : nat;
    end;
    
    type state is record
      b : nat;
      #{config.reserved}__initialized : bool;
    end;
    
    type c1_enum is
      | Constructor of c1_constructor_args
      | F1 of c1_f1_args;
    
    type c2_enum is
      | Constructor of c2_constructor_args
      | F2 of c2_f2_args;
    
    
    function constructor (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function f2 (const opList : list(operation); const contractStorage : state; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function main (const action : c2_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        case action of
        | Constructor(match_action) -> block {
          if not (contractStorage.#{config.reserved}__initialized) then {skip} else failwith("can't call constructor on initialized contract");
          const tmp_0 : (list(operation) * state) = constructor(opList, contractStorage);
          opList := tmp_0.0;
          contractStorage := tmp_0.1;
          contractStorage.#{config.reserved}__initialized := True;
        }
        | F2(match_action) -> block {
          if contractStorage.#{config.reserved}__initialized then {skip} else failwith("can't call this method on non-initialized contract");
          const tmp_1 : (list(operation) * state) = f2(opList, contractStorage, match_action.#{config.reserved}__amount);
          opList := tmp_1.0;
          contractStorage := tmp_1.1;
        }
        end;
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o, {
      router: true
    }
  