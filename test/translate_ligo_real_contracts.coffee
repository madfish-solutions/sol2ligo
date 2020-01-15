{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate_real_contracts section", ()->
  # ###################################################################################################
  #    simple coin
  # ###################################################################################################
  it "hello world", ()->
    text_i = """
    pragma solidity >=0.5.0 <0.6.0;
    
    contract SimpleCoin {
        mapping(address => uint) public balances;

        constructor() public {
            balances[msg.sender] = 1000000;
        }
        
        function transfer(address to, uint amount) public {
            require(balances[msg.sender] >= amount, "Overdrawn balance");
            balances[msg.sender] -= amount;
            balances[to] += amount;
        }
    }
    """#"
    
    text_o = """
    type state is record
      balances : map(address, nat);
    end;
    
    function reserved__constructor (const contractStorage : state) : (state) is
      block {
        contractStorage.balances[sender] := 1000000n;
      } with (contractStorage);
    
    function transfer (const contractStorage : state; const to : address; const reserved__amount : nat) : (state) is
      block {
        if ((case contractStorage.balances[sender] of | None -> 0n | Some(x) -> x end) >= reserved__amount) then {skip} else failwith("Overdrawn balance");
        contractStorage.balances[sender] := abs((case contractStorage.balances[sender] of | None -> 0n | Some(x) -> x end) - reserved__amount);
        contractStorage.balances[to] := ((case contractStorage.balances[to] of | None -> 0n | Some(x) -> x end) + reserved__amount);
      } with (contractStorage);
    """#"
    make_test text_i, text_o
  