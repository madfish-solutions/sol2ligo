config = require "../src/config"
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo online examples", ()->
  @timeout 10000
  # NOTE some duplication with other tests
  # ###################################################################################################
  it "int arithmetic", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Arith {
      int public value;
      
      function arith() public returns (int ret_val) {
        int a = 0;
        int b = 0;
        int c = 0;
        c = -c;
        c = a + b;
        c = a - b;
        c = a * b;
        c = a / b;
        return c;
      }
    }
    """#"
    text_o = """
    type arith_args is record
      callbackAddress : address;
    end;
    
    type state is record
      value : int;
    end;
    
    type router_enum is
      | Arith of arith_args;
    
    function arith (const #{config.reserved}__unit : unit) : (int) is
      block {
        const ret_val : int = 0;
        const a : int = 0;
        const b : int = 0;
        const c : int = 0;
        c := -(c);
        c := (a + b);
        c := (a - b);
        c := (a * b);
        c := (a / b);
      } with (c);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Arith(match_action) -> block {
        const tmp : (int) = arith(unit);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(int))) end;
      } with ((opList, contract_storage))
      end);
    """
    make_test text_i, text_o, router: true
  # ###################################################################################################
  it "uint arithmetic", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Arith {
      uint public value;
      
      function arith() public returns (uint ret_val) {
        uint a = 0;
        uint b = 0;
        uint c = 0;
        c = a + b;
        c = a * b;
        c = a / b;
        c = a | b;
        c = a & b;
        c = a ^ b;
        return c;
      }
    }
    """#"
    text_o = """
    type arith_args is record
      callbackAddress : address;
    end;
    
    type state is record
      value : nat;
    end;
    
    type router_enum is
      | Arith of arith_args;
    
    function arith (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const ret_val : nat = 0n;
        const a : nat = 0n;
        const b : nat = 0n;
        const c : nat = 0n;
        c := (a + b);
        c := (a * b);
        c := (a / b);
        c := Bitwise.or(a, b);
        c := Bitwise.and(a, b);
        c := Bitwise.xor(a, b);
      } with (c);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Arith(match_action) -> block {
        const tmp : (nat) = arith(unit);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(nat))) end;
      } with ((opList, contract_storage))
      end);
    """
    make_test text_i, text_o, router: true
  # ###################################################################################################
  it "if", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Ifer {
      uint public value;
      
      function ifer() public returns (uint) {
        uint x = 6;
        
        if (x == 5) {
            x += 1;
        }
        else {
            x += 10;
        }
        
        return x;
      }
    }
    """#"
    text_o = """
    type ifer_args is record
      callbackAddress : address;
    end;
    
    type state is record
      value : nat;
    end;
    
    type router_enum is
      | Ifer of ifer_args;
    
    function ifer (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const x : nat = 6n;
        if (x = 5n) then block {
          x := (x + 1n);
        } else block {
          x := (x + 10n);
        };
      } with (x);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Ifer(match_action) -> block {
        const tmp : (nat) = ifer(unit);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(nat))) end;
      } with ((opList, contract_storage))
      end);
    """
    make_test text_i, text_o, router: true
  # ###################################################################################################
  it "for", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Forer {
      uint public value;
      
      function forer() public returns (uint ret_val) {
        uint y = 0;
        for (uint i=0; i<5; i+=1) {
            y += 1;
        }
        return y;
      }
    } 
    """#"
    text_o = """
    type forer_args is record
      callbackAddress : address;
    end;
    
    type state is record
      value : nat;
    end;
    
    type router_enum is
      | Forer of forer_args;
    
    function forer (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const ret_val : nat = 0n;
        const y : nat = 0n;
        const i : nat = 0n;
        while (i < 5n) block {
          y := (y + 1n);
          i := (i + 1n);
        };
      } with (y);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Forer(match_action) -> block {
        const tmp : (nat) = forer(unit);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(nat))) end;
      } with ((opList, contract_storage))
      end);
    """
    make_test text_i, text_o, router: true
  # ###################################################################################################
  it "while", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Whiler {
      uint public value;
      
      function whiler() public returns (uint ret_val) {
        uint y = 0;
        while (y != 2) {
            y += 1;
        }
        return y;
      }
    } 
    """#"
    text_o = """
    type whiler_args is record
      callbackAddress : address;
    end;
    
    type state is record
      value : nat;
    end;
    
    type router_enum is
      | Whiler of whiler_args;
    
    function whiler (const #{config.reserved}__unit : unit) : (nat) is
      block {
        const ret_val : nat = 0n;
        const y : nat = 0n;
        while (y =/= 2n) block {
          y := (y + 1n);
        };
      } with (y);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Whiler(match_action) -> block {
        const tmp : (nat) = whiler(unit);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(nat))) end;
      } with ((opList, contract_storage))
      end);
    """
    make_test text_i, text_o, router: true
  # ###################################################################################################
  it "fn call", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Fn_call {
      int public value;
      
      function fn1(int a) public returns (int ret_val) {
        value += 1;
        return a;
      }
      function fn2() public returns (int ret_val) {
        fn1(1);
        int res = 1;
        return res;
      }
    }
    """#"
    text_o = """
    type fn1_args is record
      a : int;
      callbackAddress : address;
    end;
    
    type fn2_args is record
      callbackAddress : address;
    end;
    
    type state is record
      value : int;
    end;
    
    type router_enum is
      | Fn1 of fn1_args
     | Fn2 of fn2_args;
    
    function fn1 (const contract_storage : state; const a : int) : (state * int) is
      block {
        const ret_val : int = 0;
        contract_storage.value := (contract_storage.value + 1);
      } with (contract_storage, a);
    
    function fn2 (const contract_storage : state) : (state * int) is
      block {
        const ret_val : int = 0;
        const tmp_0 : (state * int) = fn1(contract_storage, 1);
        contract_storage := tmp_0.0;
        const res : int = 1;
      } with (contract_storage, res);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Fn1(match_action) -> block {
        const tmp : (state * int) = fn1(contract_storage, match_action.a);
        var opList : list(operation) := list transaction((tmp.0), 0mutez, (get_contract(match_action.callbackAddress) : contract(state))) end;
      } with ((opList, tmp.0))
      | Fn2(match_action) -> block {
        const tmp : (state * int) = fn2(contract_storage);
        var opList : list(operation) := list transaction((tmp.0), 0mutez, (get_contract(match_action.callbackAddress) : contract(state))) end;
      } with ((opList, tmp.0))
      end);
    """
    make_test text_i, text_o, router: true
  # ###################################################################################################
  it "simplecoin", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Coin {
        address minter;
        mapping (address => uint) balances;
        
        constructor() public {
            minter = msg.sender;
        }
        function mint(address owner, uint amount) public {
            if (msg.sender == minter) {
                balances[owner] += amount;
            }
        }
        function send(address receiver, uint amount) public {
            if (balances[msg.sender] >= amount) {
                balances[msg.sender] -= amount;
                balances[receiver] += amount;
            }
        }
        function queryBalance(address addr) public view returns (uint balance) {
            return balances[addr];
        }
    }
    """#"
    text_o = """
    type constructor_args is unit;
    type mint_args is record
      owner : address;
      #{config.reserved}__amount : nat;
    end;
    
    type send_args is record
      receiver : address;
      #{config.reserved}__amount : nat;
    end;
    
    type queryBalance_args is record
      addr : address;
      callbackAddress : address;
    end;
    
    type state is record
      minter : address;
      balances : map(address, nat);
    end;
    
    type router_enum is
      | Constructor of constructor_args
     | Mint of mint_args
     | Send of send_args
     | QueryBalance of queryBalance_args;
    
    function constructor (const contract_storage : state) : (state) is
      block {
        contract_storage.minter := Tezos.sender;
      } with (contract_storage);
    
    function mint (const contract_storage : state; const owner : address; const #{config.reserved}__amount : nat) : (state) is
      block {
        if (Tezos.sender = contract_storage.minter) then block {
          contract_storage.balances[owner] := ((case contract_storage.balances[owner] of | None -> 0n | Some(x) -> x end) + #{config.reserved}__amount);
        } else block {
          skip
        };
      } with (contract_storage);
    
    function send (const contract_storage : state; const receiver : address; const #{config.reserved}__amount : nat) : (state) is
      block {
        if ((case contract_storage.balances[Tezos.sender] of | None -> 0n | Some(x) -> x end) >= #{config.reserved}__amount) then block {
          contract_storage.balances[Tezos.sender] := abs((case contract_storage.balances[Tezos.sender] of | None -> 0n | Some(x) -> x end) - #{config.reserved}__amount);
          contract_storage.balances[receiver] := ((case contract_storage.balances[receiver] of | None -> 0n | Some(x) -> x end) + #{config.reserved}__amount);
        } else block {
          skip
        };
      } with (contract_storage);
    
    function queryBalance (const contract_storage : state; const addr : address) : (nat) is
      block {
        const #{config.reserved}__balance : nat = 0n;
      } with ((case contract_storage.balances[addr] of | None -> 0n | Some(x) -> x end));
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Constructor(match_action) -> ((nil: list(operation)), constructor(contract_storage))
      | Mint(match_action) -> ((nil: list(operation)), mint(contract_storage, match_action.owner, match_action.#{config.reserved}__amount))
      | Send(match_action) -> ((nil: list(operation)), send(contract_storage, match_action.receiver, match_action.#{config.reserved}__amount))
      | QueryBalance(match_action) -> block {
        const tmp : (nat) = queryBalance(contract_storage, match_action.addr);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(nat))) end;
      } with ((opList, contract_storage))
      end);
    """
    make_test text_i, text_o, router: true
  # ###################################################################################################
  
  it "AtomicSwap", ()->
    text_i = """
    pragma solidity ^0.4.18;
    
    contract AtomicSwapEther {
    
      struct Swap {
        uint256 timelock;
        uint256 value;
        address ethTrader;
        address withdrawTrader;
        bytes32 secretLock;
        bytes secretKey;
      }
    
      enum States {
        INVALID,
        OPEN,
        CLOSED,
        EXPIRED
      }
    
      mapping (bytes32 => Swap) private swaps;
      mapping (bytes32 => States) private swapStates;
    
      event Open(bytes32 _swapID, address _withdrawTrader,bytes32 _secretLock);
      event Expire(bytes32 _swapID);
      event Close(bytes32 _swapID, bytes _secretKey);
    
      modifier onlyInvalidSwaps(bytes32 _swapID) {
        require (swapStates[_swapID] == States.INVALID);
        _;
      }
    
      modifier onlyOpenSwaps(bytes32 _swapID) {
        require (swapStates[_swapID] == States.OPEN);
        _;
      }
    
      modifier onlyClosedSwaps(bytes32 _swapID) {
        require (swapStates[_swapID] == States.CLOSED);
        _;
      }
    
      modifier onlyExpirableSwaps(bytes32 _swapID) {
        require (now >= swaps[_swapID].timelock);
        _;
      }
    
      modifier onlyWithSecretKey(bytes32 _swapID, bytes _secretKey) {
        // TODO: Require _secretKey length to conform to the spec
        require (swaps[_swapID].secretLock == sha256(_secretKey));
        _;
      }
    
      function open(bytes32 _swapID, address _withdrawTrader, bytes32 _secretLock, uint256 _timelock) public onlyInvalidSwaps(_swapID) payable {
        // Store the details of the swap.
        Swap memory swap = Swap({
          timelock: _timelock,
          value: msg.value,
          ethTrader: msg.sender,
          withdrawTrader: _withdrawTrader,
          secretLock: _secretLock,
          secretKey: new bytes(0)
        });
        swaps[_swapID] = swap;
        swapStates[_swapID] = States.OPEN;
    
        // Trigger open event.
        Open(_swapID, _withdrawTrader, _secretLock);
      }
    
      function close(bytes32 _swapID, bytes _secretKey) public onlyOpenSwaps(_swapID) onlyWithSecretKey(_swapID, _secretKey) {
        // Close the swap.
        Swap memory swap = swaps[_swapID];
        swaps[_swapID].secretKey = _secretKey;
        swapStates[_swapID] = States.CLOSED;
    
        // Transfer the ETH funds from this contract to the withdrawing trader.
        swap.withdrawTrader.transfer(swap.value);
    
        // Trigger close event.
        Close(_swapID, _secretKey);
      }
    
      function expire(bytes32 _swapID) public onlyOpenSwaps(_swapID) onlyExpirableSwaps(_swapID) {
        // Expire the swap.
        Swap memory swap = swaps[_swapID];
        swapStates[_swapID] = States.EXPIRED;
    
        // Transfer the ETH value from this contract back to the ETH trader.
        swap.ethTrader.transfer(swap.value);
    
        // Trigger expire event.
        Expire(_swapID);
      }
    
      function check(bytes32 _swapID) public view returns (uint256 timelock, uint256 value, address withdrawTrader, bytes32 secretLock) {
        Swap memory swap = swaps[_swapID];
        return (swap.timelock, swap.value, swap.withdrawTrader, swap.secretLock);
      }
    
      function checkSecretKey(bytes32 _swapID) public view onlyClosedSwaps(_swapID) returns (bytes secretKey) {
        Swap memory swap = swaps[_swapID];
        return swap.secretKey;
      }
    }
    """#"
    text_o = """
    type atomicSwapEther_Swap is record
      timelock : nat;
      value : nat;
      ethTrader : address;
      withdrawTrader : address;
      secretLock : bytes;
      secretKey : bytes;
    end;
    
    type open_args is record
      swapID_ : bytes;
      withdrawTrader_ : address;
      secretLock_ : bytes;
      timelock_ : nat;
    end;
    
    type close_args is record
      swapID_ : bytes;
      secretKey_ : bytes;
    end;
    
    type expire_args is record
      swapID_ : bytes;
    end;
    
    type check_args is record
      swapID_ : bytes;
      callbackAddress : address;
    end;
    
    type checkSecretKey_args is record
      swapID_ : bytes;
      callbackAddress : address;
    end;
    
    type state is record
      swaps : map(bytes, atomicSwapEther_Swap);
      swapStates : map(bytes, nat);
    end;
    
    const atomicSwapEther_Swap_default : atomicSwapEther_Swap = record [ timelock = 0n;
      value = 0n;
      ethTrader = burn_address;
      withdrawTrader = burn_address;
      secretLock = ("00": bytes);
      secretKey = ("00": bytes) ];
    
    const burn_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    
    const states_INVALID : nat = 0n;
    const states_OPEN : nat = 1n;
    const states_CLOSED : nat = 2n;
    const states_EXPIRED : nat = 3n;
    type router_enum is
      | Open of open_args
     | Close of close_args
     | Expire of expire_args
     | Check of check_args
     | CheckSecretKey of checkSecretKey_args;
    
    (* EventDefinition Open(swapID_ : bytes; withdrawTrader_ : address; secretLock_ : bytes) *)
    
    (* EventDefinition Expire(swapID_ : bytes) *)
    
    (* EventDefinition Close(swapID_ : bytes; secretKey_ : bytes) *)
    
    (* enum States converted into list of nats *)
    
    (* modifier onlyInvalidSwaps inlined *)
    
    (* modifier onlyOpenSwaps inlined *)
    
    (* modifier onlyClosedSwaps inlined *)
    
    (* modifier onlyExpirableSwaps inlined *)
    
    (* modifier onlyWithSecretKey inlined *)
    
    function open (const test_self : state; const swapID_ : bytes; const withdrawTrader_ : address; const secretLock_ : bytes; const timelock_ : nat) : (state) is
      block {
        assert(((case test_self.swapStates[swapID_] of | None -> 0n | Some(x) -> x end) = states_INVALID));
        const swap : atomicSwapEther_Swap = record [ timelock = timelock_;
          value = (amount / 1mutez);
          ethTrader = Tezos.sender;
          withdrawTrader = withdrawTrader_;
          secretLock = secretLock_;
          secretKey = ("00": bytes) (* args: 0 *) ];
        test_self.swaps[swapID_] := swap;
        test_self.swapStates[swapID_] := states_OPEN;
        (* EmitStatement Open(_swapID, _withdrawTrader, _secretLock) *)
      } with (test_self);
    
    function close (const opList : list(operation); const test_self : state; const swapID_ : bytes; const secretKey_ : bytes) : (list(operation) * state) is
      block {
        assert(((case test_self.swaps[swapID_] of | None -> atomicSwapEther_Swap_default | Some(x) -> x end).secretLock = sha_256(secretKey_)));
        assert(((case test_self.swapStates[swapID_] of | None -> 0n | Some(x) -> x end) = states_OPEN));
        const swap : atomicSwapEther_Swap = (case test_self.swaps[swapID_] of | None -> atomicSwapEther_Swap_default | Some(x) -> x end);
        test_self.swaps[swapID_].secretKey := secretKey_;
        test_self.swapStates[swapID_] := states_CLOSED;
        const op0 : operation = transaction((unit), (swap.value * 1mutez), (get_contract(swap.withdrawTrader) : contract(unit)));
        (* EmitStatement Close(_swapID, _secretKey) *)
      } with (list [op0], test_self);
    
    function expire (const opList : list(operation); const test_self : state; const swapID_ : bytes) : (list(operation) * state) is
      block {
        assert((abs(now - ("1970-01-01T00:00:00Z" : timestamp)) >= (case test_self.swaps[swapID_] of | None -> atomicSwapEther_Swap_default | Some(x) -> x end).timelock));
        assert(((case test_self.swapStates[swapID_] of | None -> 0n | Some(x) -> x end) = states_OPEN));
        const swap : atomicSwapEther_Swap = (case test_self.swaps[swapID_] of | None -> atomicSwapEther_Swap_default | Some(x) -> x end);
        test_self.swapStates[swapID_] := states_EXPIRED;
        const op0 : operation = transaction((unit), (swap.value * 1mutez), (get_contract(swap.ethTrader) : contract(unit)));
        (* EmitStatement Expire(_swapID) *)
      } with (list [op0], test_self);
    
    function check (const test_self : state; const swapID_ : bytes) : ((nat * nat * address * bytes)) is
      block {
        const timelock : nat = 0n;
        const value : nat = 0n;
        const withdrawTrader : address = burn_address;
        const secretLock : bytes = ("00": bytes);
        const swap : atomicSwapEther_Swap = (case test_self.swaps[swapID_] of | None -> atomicSwapEther_Swap_default | Some(x) -> x end);
      } with ((swap.timelock, swap.value, swap.withdrawTrader, swap.secretLock));
    
    function checkSecretKey (const test_self : state; const swapID_ : bytes) : (bytes) is
      block {
        assert(((case test_self.swapStates[swapID_] of | None -> 0n | Some(x) -> x end) = states_CLOSED));
        const secretKey : bytes = ("00": bytes);
        const swap : atomicSwapEther_Swap = (case test_self.swaps[swapID_] of | None -> atomicSwapEther_Swap_default | Some(x) -> x end);
      } with (swap.secretKey);
    
    function main (const action : router_enum; const test_self : state) : (list(operation) * state) is
      (case action of
      | Open(match_action) -> ((nil: list(operation)), open(test_self, match_action.swapID_, match_action.withdrawTrader_, match_action.secretLock_, match_action.timelock_))
      | Close(match_action) -> close((nil: list(operation)), test_self, match_action.swapID_, match_action.secretKey_)
      | Expire(match_action) -> expire((nil: list(operation)), test_self, match_action.swapID_)
      | Check(match_action) -> block {
        const tmp : ((nat * nat * address * bytes)) = check(test_self, match_action.swapID_);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract((nat * nat * address * bytes)))) end;
      } with ((opList, test_self))
      | CheckSecretKey(match_action) -> block {
        const tmp : (bytes) = checkSecretKey(test_self, match_action.swapID_);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(bytes))) end;
      } with ((opList, test_self))
      end);
    """#"
    make_test text_i, text_o, router: true
  # ###################################################################################################
  it "Dice", ()->
    text_i = """
    pragma solidity ^0.4.24;
    
    // * dice2.win - fair games that pay Ether. Version 5.
    //
    // * Ethereum smart contract, deployed at 0xD1CEeeeee83F8bCF3BEDad437202b6154E9F5405.
    //
    // * Uses hybrid commit-reveal + block hash random number generation that is immune
    //   to tampering by players, house and miners. Apart from being fully transparent,
    //   this also allows arbitrarily high bets.
    //
    // * Refer to https://dice2.win/whitepaper.pdf for detailed description and proofs.
    
    contract Dice2Win {
        /// *** Constants section
    
        // Each bet is deducted 1% in favour of the house, but no less than some minimum.
        // The lower bound is dictated by gas costs of the settleBet transaction, providing
        // headroom for up to 10 Gwei prices.
        uint256 constant HOUSE_EDGE_PERCENT = 1;
        uint256 constant HOUSE_EDGE_MINIMUM_AMOUNT = 0.0003 ether;
    
        // Bets lower than this amount do not participate in jackpot rolls (and are
        // not deducted JACKPOT_FEE).
        uint256 constant MIN_JACKPOT_BET = 0.1 ether;
    
        // Chance to win jackpot (currently 0.1%) and fee deducted into jackpot fund.
        uint256 constant JACKPOT_MODULO = 1000;
        uint256 constant JACKPOT_FEE = 0.001 ether;
    
        // There is minimum and maximum bets.
        uint256 constant MIN_BET = 0.01 ether;
        uint256 constant MAX_AMOUNT = 300000 ether;
    
        // Modulo is a number of equiprobable outcomes in a game:
        //  - 2 for coin flip
        //  - 6 for dice
        //  - 6*6 = 36 for double dice
        //  - 100 for etheroll
        //  - 37 for roulette
        //  etc.
        // It's called so because 256-bit entropy is treated like a huge integer and
        // the remainder of its division by modulo is considered bet outcome.
        uint256 constant MAX_MODULO = 100;
    
        // For modulos below this threshold rolls are checked against a bit mask,
        // thus allowing betting on any combination of outcomes. For example, given
        // modulo 6 for dice, 101000 mask (base-2, big endian) means betting on
        // 4 and 6; for games with modulos higher than threshold (Etheroll), a simple
        // limit is used, allowing betting on any outcome in [0, N) range.
        //
        // The specific value is dictated by the fact that 256-bit intermediate
        // multiplication result allows implementing population count efficiently
        // for numbers that are up to 42 bits, and 40 is the highest multiple of
        // eight below 42.
        uint256 constant MAX_MASK_MODULO = 40;
    
        // This is a check on bet mask overflow.
        uint256 constant MAX_BET_MASK = 2**MAX_MASK_MODULO;
    
        // EVM BLOCKHASH opcode can query no further than 256 blocks into the
        // past. Given that settleBet uses block hash of placeBet as one of
        // complementary entropy sources, we cannot process bets older than this
        // threshold. On rare occasions dice2.win croupier may fail to invoke
        // settleBet in this timespan due to technical issues or extreme Ethereum
        // congestion; such bets can be refunded via invoking refundBet.
        uint256 constant BET_EXPIRATION_BLOCKS = 250;
    
        // Some deliberately invalid address to initialize the secret signer with.
        // Forces maintainers to invoke setSecretSigner before processing any bets.
        address constant DUMMY_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        
        // Standard contract ownership transfer.
        address public owner;
        address private nextOwner;
    
        // Adjustable max bet profit. Used to cap bets against dynamic odds.
        uint256 public maxProfit;
    
        // The address corresponding to a private key used to sign placeBet commits.
        address public secretSigner;
    
        // Accumulated jackpot fund.
        uint128 public jackpotSize;
    
        // Funds that are locked in potentially winning bets. Prevents contract from
        // committing to bets it cannot pay out.
        uint128 public lockedInBets;
    
        // A structure representing a single bet.
        struct Bet {
            // Wager amount in wei.
            uint256 amount;
            // Modulo of a game.
            uint8 modulo;
            // Number of winning outcomes, used to compute winning payment (* modulo/rollUnder),
            // and used instead of mask for games with modulo > MAX_MASK_MODULO.
            uint8 rollUnder;
            // Block number of placeBet tx.
            uint40 placeBlockNumber;
            // Bit mask representing winning bet outcomes (see MAX_MASK_MODULO comment).
            uint40 mask;
            // Address of a gambler, used to pay out winning bets.
            address gambler;
        }
    
        // Mapping from commits to all currently active & processed bets.
        mapping(uint256 => Bet) bets;
    
        // Croupier account.
        address public croupier;
    
        // Events that are issued to make statistic recovery easier.
        event FailedPayment(address indexed beneficiary, uint256 amount);
        event Payment(address indexed beneficiary, uint256 amount);
        event JackpotPayment(address indexed beneficiary, uint256 amount);
    
        // This event is emitted in placeBet to record commit in the logs.
        event Commit(uint256 commit);
    
        // Constructor. Deliberately does not take any parameters.
        constructor() public {
            owner = msg.sender;
            secretSigner = DUMMY_ADDRESS;
            croupier = DUMMY_ADDRESS;
        }
    
        // Standard modifier on methods invokable only by contract owner.
        modifier onlyOwner {
            require(msg.sender == owner, "OnlyOwner methods called by non-owner.");
            _;
        }
    
        // Standard modifier on methods invokable only by contract owner.
        modifier onlyCroupier {
            require(
                msg.sender == croupier,
                "OnlyCroupier methods called by non-croupier."
            );
            _;
        }
    
        // Standard contract ownership transfer implementation,
        function approveNextOwner(address _nextOwner) external onlyOwner {
            require(_nextOwner != owner, "Cannot approve current owner.");
            nextOwner = _nextOwner;
        }
    
        function acceptNextOwner() external {
            require(
                msg.sender == nextOwner,
                "Can only accept preapproved new owner."
            );
            owner = nextOwner;
        }
    
        // Fallback function deliberately left empty. It's primary use case
        // is to top up the bank roll.
        function() public payable {}
    
        // See comment for "secretSigner" variable.
        function setSecretSigner(address newSecretSigner) external onlyOwner {
            secretSigner = newSecretSigner;
        }
    
        // Change the croupier address.
        function setCroupier(address newCroupier) external onlyOwner {
            croupier = newCroupier;
        }
    
        // Change max bet reward. Setting this to zero effectively disables betting.
        function setMaxProfit(uint256 _maxProfit) public onlyOwner {
            require(_maxProfit < MAX_AMOUNT, "maxProfit should be a sane number.");
            maxProfit = _maxProfit;
        }
    
        // This function is used to bump up the jackpot fund. Cannot be used to lower it.
        function increaseJackpot(uint256 increaseAmount) external onlyOwner {
            require(
                increaseAmount <= address(this).balance,
                "Increase amount larger than balance."
            );
            require(
                jackpotSize + lockedInBets + increaseAmount <=
                    address(this).balance,
                "Not enough funds."
            );
            jackpotSize += uint128(increaseAmount);
        }
    
        // Funds withdrawal to cover costs of dice2.win operation.
        function withdrawFunds(address beneficiary, uint256 withdrawAmount)
            external
            onlyOwner
        {
            require(
                withdrawAmount <= address(this).balance,
                "Increase amount larger than balance."
            );
            require(
                jackpotSize + lockedInBets + withdrawAmount <=
                    address(this).balance,
                "Not enough funds."
            );
            sendFunds(beneficiary, withdrawAmount, withdrawAmount);
        }
    
        // Contract may be destroyed only when there are no ongoing bets,
        // either settled or refunded. All funds are transferred to contract owner.
        function kill() external onlyOwner {
            require(
                lockedInBets == 0,
                "All bets should be processed (settled or refunded) before test_self-destruct."
            );
            selfdestruct(owner);
        }
    
        /// *** Betting logic
    
        // Bet states:
        //  amount == 0 && gambler == 0 - 'clean' (can place a bet)
        //  amount != 0 && gambler != 0 - 'active' (can be settled or refunded)
        //  amount == 0 && gambler != 0 - 'processed' (can clean storage)
        //
        //  NOTE: Storage cleaning is not implemented in this contract version; it will be added
        //        with the next upgrade to prevent polluting Ethereum state with expired bets.
    
        // Bet placing transaction - issued by the player.
        //  betMask         - bet outcomes bit mask for modulo <= MAX_MASK_MODULO,
        //                    [0, betMask) for larger modulos.
        //  modulo          - game modulo.
        //  commitLastBlock - number of the maximum block where "commit" is still considered valid.
        //  commit          - Keccak256 hash of some secret "reveal" random number, to be supplied
        //                    by the dice2.win croupier bot in the settleBet transaction. Supplying
        //                    "commit" ensures that "reveal" cannot be changed behind the scenes
        //                    after placeBet have been mined.
        //  r, s            - components of ECDSA signature of (commitLastBlock, commit). v is
        //                    guaranteed to always equal 27.
        //
        // Commit, being essentially random 256-bit number, is used as a unique bet identifier in
        // the 'bets' mapping.
        //
        // Commits are signed with a block limit to ensure that they are used at most once - otherwise
        // it would be possible for a miner to place a bet with a known commit/reveal pair and tamper
        // with the blockhash. Croupier guarantees that commitLastBlock will always be not greater than
        // placeBet block number plus BET_EXPIRATION_BLOCKS. See whitepaper for details.
        function placeBet(
            uint256 betMask,
            uint256 modulo,
            uint256 commitLastBlock,
            uint256 commit,
            bytes32 r,
            bytes32 s
        ) external payable {
            // Check that the bet is in 'clean' state.
            Bet storage bet = bets[commit];
            require(bet.gambler == address(0), "Bet should be in a 'clean' _state.");
    
            // Validate input data ranges.
            uint256 amount = msg.value;
            require(
                modulo > 1 && modulo <= MAX_MODULO,
                "Modulo should be within range."
            );
            require(
                amount >= MIN_BET && amount <= MAX_AMOUNT,
                "Amount should be within range."
            );
            require(
                betMask > 0 && betMask < MAX_BET_MASK,
                "Mask should be within range."
            );
    
            // Check that commit is valid - it has not expired and its signature is valid.
            require(block.number <= commitLastBlock, "Commit has expired.");
            bytes32 signatureHash = keccak256(
                abi.encodePacked(uint40(commitLastBlock), commit)
            );
            require(
                secretSigner == ecrecover(signatureHash, 27, r, s),
                "ECDSA signature is not valid."
            );
    
            uint256 rollUnder;
            uint256 mask;
    
            if (modulo <= MAX_MASK_MODULO) {
                // Small modulo games specify bet outcomes via bit mask.
                // rollUnder is a number of 1 bits in this mask (population count).
                // This magic looking formula is an efficient way to compute population
                // count on EVM for numbers below 2**40. For detailed proof consult
                // the dice2.win whitepaper.
                rollUnder = ((betMask * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;
                mask = betMask;
            } else {
                // Larger modulos specify the right edge of half-open interval of
                // winning bet outcomes.
                require(
                    betMask > 0 && betMask <= modulo,
                    "High modulo range, betMask larger than modulo."
                );
                rollUnder = betMask;
            }
    
            // Winning amount and jackpot increase.
            uint256 possibleWinAmount;
            uint256 jackpotFee;
    
            (possibleWinAmount, jackpotFee) = getDiceWinAmount(
                amount,
                modulo,
                rollUnder
            );
    
            // Enforce max profit limit.
            require(
                possibleWinAmount <= amount + maxProfit,
                "maxProfit limit violation."
            );
    
            // Lock funds.
            lockedInBets += uint128(possibleWinAmount);
            jackpotSize += uint128(jackpotFee);
    
            // Check whether contract has enough funds to process this bet.
            require(
                jackpotSize + lockedInBets <= address(this).balance,
                "Cannot afford to lose this bet."
            );
    
            // Record commit in logs.
            emit Commit(commit);
    
            // Store bet parameters on blockchain.
            bet.amount = amount;
            bet.modulo = uint8(modulo);
            bet.rollUnder = uint8(rollUnder);
            bet.placeBlockNumber = uint40(block.number);
            bet.mask = uint40(mask);
            bet.gambler = msg.sender;
        }
    
        // This is the method used to settle 99% of bets. To process a bet with a specific
        // "commit", settleBet should supply a "reveal" number that would Keccak256-hash to
        // "commit". "blockHash" is the block hash of placeBet block as seen by croupier; it
        // is additionally asserted to prevent changing the bet outcomes on Ethereum reorgs.
        function settleBet(uint256 reveal, bytes32 blockHash)
            external
            onlyCroupier
        {
            uint256 commit = uint256(keccak256(abi.encodePacked(reveal)));
    
            Bet storage bet = bets[commit];
            uint256 placeBlockNumber = bet.placeBlockNumber;
    
            // Check that bet has not expired yet (see comment to BET_EXPIRATION_BLOCKS).
            require(
                block.number > placeBlockNumber,
                "settleBet in the same block as placeBet, or before."
            );
            require(
                block.number <= placeBlockNumber + BET_EXPIRATION_BLOCKS,
                "Blockhash can't be queried by EVM."
            );
            require(blockhash(placeBlockNumber) == blockHash);
    
            // Settle bet using reveal and blockHash as entropy sources.
            settleBetCommon(bet, reveal, blockHash);
        }
    
        // This method is used to settle a bet that was mined into an uncle block. At this
        // point the player was shown some bet outcome, but the blockhash at placeBet height
        // is different because of Ethereum chain reorg. We supply a full merkle proof of the
        // placeBet transaction receipt to provide untamperable evidence that uncle block hash
        // indeed was present on-chain at some point.
        function settleBetUncleMerkleProof(
            uint256 reveal,
            uint40 canonicalBlockNumber
        ) external onlyCroupier {
            // "commit" for bet settlement can only be obtained by hashing a "reveal".
            uint256 commit = uint256(keccak256(abi.encodePacked(reveal)));
    
            Bet storage bet = bets[commit];
    
            // Check that canonical block hash can still be verified.
            require(
                block.number <= canonicalBlockNumber + BET_EXPIRATION_BLOCKS,
                "Blockhash can't be queried by EVM."
            );
    
            // Verify placeBet receipt.
            requireCorrectReceipt(4 + 32 + 32 + 4);
    
            // Reconstruct canonical & uncle block hashes from a receipt merkle proof, verify them.
            bytes32 canonicalHash;
            bytes32 uncleHash;
            (canonicalHash, uncleHash) = verifyMerkleProof(commit, 4 + 32 + 32);
            require(blockhash(canonicalBlockNumber) == canonicalHash);
    
            // Settle bet using reveal and uncleHash as entropy sources.
            settleBetCommon(bet, reveal, uncleHash);
        }
    
        // Common settlement code for settleBet & settleBetUncleMerkleProof.
        function settleBetCommon(
            Bet storage bet,
            uint256 reveal,
            bytes32 entropyBlockHash
        ) private {
            // Fetch bet parameters into local variables (to save gas).
            uint256 amount = bet.amount;
            uint256 modulo = bet.modulo;
            uint256 rollUnder = bet.rollUnder;
            address gambler = bet.gambler;
    
            // Check that bet is in 'active' state.
            require(amount != 0, "Bet should be in an 'active' _state");
    
            // Move bet into 'processed' state already.
            bet.amount = 0;
    
            // The RNG - combine "reveal" and blockhash of placeBet using Keccak256. Miners
            // are not aware of "reveal" and cannot deduce it from "commit" (as Keccak256
            // preimage is intractable), and house is unable to alter the "reveal" after
            // placeBet have been mined (as Keccak256 collision finding is also intractable).
            bytes32 entropy = keccak256(abi.encodePacked(reveal, entropyBlockHash));
    
            // Do a roll by taking a modulo of entropy. Compute winning amount.
            uint256 dice = uint256(entropy) % modulo;
    
            uint256 diceWinAmount;
            uint256 _jackpotFee;
            (diceWinAmount, _jackpotFee) = getDiceWinAmount(
                amount,
                modulo,
                rollUnder
            );
    
            uint256 diceWin = 0;
            uint256 jackpotWin = 0;
    
            // Determine dice outcome.
            if (modulo <= MAX_MASK_MODULO) {
                // For small modulo games, check the outcome against a bit mask.
                if ((2**dice) & bet.mask != 0) {
                    diceWin = diceWinAmount;
                }
    
            } else {
                // For larger modulos, check inclusion into half-open interval.
                if (dice < rollUnder) {
                    diceWin = diceWinAmount;
                }
    
            }
    
            // Unlock the bet amount, regardless of the outcome.
            lockedInBets -= uint128(diceWinAmount);
    
            // Roll for a jackpot (if eligible).
            if (amount >= MIN_JACKPOT_BET) {
                // The second modulo, statistically independent from the "main" dice roll.
                // Effectively you are playing two games at once!
                uint256 jackpotRng = (uint256(entropy) / modulo) % JACKPOT_MODULO;
    
                // Bingo!
                if (jackpotRng == 0) {
                    jackpotWin = jackpotSize;
                    jackpotSize = 0;
                }
            }
    
            // Log jackpot win.
            if (jackpotWin > 0) {
                emit JackpotPayment(gambler, jackpotWin);
            }
    
            // Send the funds to gambler.
            sendFunds(
                gambler,
                diceWin + jackpotWin == 0 ? 1 wei : diceWin + jackpotWin,
                diceWin
            );
        }
    
        // Refund transaction - return the bet amount of a roll that was not processed in a
        // due timeframe. Processing such blocks is not possible due to EVM limitations (see
        // BET_EXPIRATION_BLOCKS comment above for details). In case you ever find yourself
        // in a situation like this, just contact the dice2.win support, however nothing
        // precludes you from invoking this method yourself.
        function refundBet(uint256 commit) external {
            // Check that bet is in 'active' state.
            Bet storage bet = bets[commit];
            uint256 amount = bet.amount;
    
            require(amount != 0, "Bet should be in an 'active' _state");
    
            // Check that bet has already expired.
            require(
                block.number > bet.placeBlockNumber + BET_EXPIRATION_BLOCKS,
                "Blockhash can't be queried by EVM."
            );
    
            // Move bet into 'processed' state, release funds.
            bet.amount = 0;
    
            uint256 diceWinAmount;
            uint256 jackpotFee;
            (diceWinAmount, jackpotFee) = getDiceWinAmount(
                amount,
                bet.modulo,
                bet.rollUnder
            );
    
            lockedInBets -= uint128(diceWinAmount);
            jackpotSize -= uint128(jackpotFee);
    
            // Send the refund.
            sendFunds(bet.gambler, amount, amount);
        }
    
        // Get the expected win amount after house edge is subtracted.
        function getDiceWinAmount(uint256 amount, uint256 modulo, uint256 rollUnder)
            private
            pure
            returns (uint256 winAmount, uint256 jackpotFee)
        {
            require(
                0 < rollUnder && rollUnder <= modulo,
                "Win probability out of range."
            );
    
            jackpotFee = amount >= MIN_JACKPOT_BET ? JACKPOT_FEE : 0;
    
            uint256 houseEdge = (amount * HOUSE_EDGE_PERCENT) / 100;
    
            if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
                houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
            }
    
            require(
                houseEdge + jackpotFee <= amount,
                "Bet doesn't even cover house edge."
            );
            winAmount = ((amount - houseEdge - jackpotFee) * modulo) / rollUnder;
        }
    
        // Helper routine to process the payment.
        function sendFunds(
            address beneficiary,
            uint256 amount,
            uint256 successLogAmount
        ) private {
            if (beneficiary.send(amount)) {
                emit Payment(beneficiary, successLogAmount);
            } else {
                emit FailedPayment(beneficiary, amount);
            }
        }
    
        // This are some constants making O(1) population count in placeBet possible.
        // See whitepaper for intuition and proofs behind it.
        uint256 constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
        uint256 constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
        uint256 constant POPCNT_MODULO = 0x3F;
    
        // *** Merkle proofs.
    
        // This helpers are used to verify cryptographic proofs of placeBet inclusion into
        // uncle blocks. They are used to prevent bet outcome changing on Ethereum reorgs without
        // compromising the security of the smart contract. Proof data is appended to the input data
        // in a simple prefix length format and does not adhere to the ABI.
        // Invariants checked:
        //  - receipt trie entry contains a (1) successful transaction (2) directed at this smart
        //    contract (3) containing commit as a payload.
        //  - receipt trie entry is a part of a valid merkle proof of a block header
        //  - the block header is a part of uncle list of some block on canonical chain
        // The implementation is optimized for gas cost and relies on the specifics of Ethereum internal data structures.
        // Read the whitepaper for details.
    
        // Helper to verify a full merkle proof starting from some seedHash (usually commit). "offset" is the location of the proof
        // beginning in the calldata.
        function verifyMerkleProof(uint256 seedHash, uint256 offset)
            private
            pure
            returns (bytes32 blockHash, bytes32 uncleHash)
        {
            // (Safe) assumption - nobody will write into RAM during this method invocation.
            uint256 scratchBuf1;
            assembly {
                scratchBuf1 := mload(0x40)
            }
    
            uint256 uncleHeaderLength;
            uint256 blobLength;
            uint256 shift;
            uint256 hashSlot;
    
            // Verify merkle proofs up to uncle block header. Calldata layout is:
            //  - 2 byte big-endian slice length
            //  - 2 byte big-endian offset to the beginning of previous slice hash within the current slice (should be zeroed)
            //  - followed by the current slice verbatim
            for (; ; offset += blobLength) {
                assembly {
                    blobLength := and(calldataload(sub(offset, 30)), 0xffff)
                }
                if (blobLength == 0) {
                    // Zero slice length marks the end of uncle proof.
                    break;
                }
    
                assembly {
                    shift := and(calldataload(sub(offset, 28)), 0xffff)
                }
                require(shift + 32 <= blobLength, "Shift bounds check.");
    
                offset += 4;
                assembly {
                    hashSlot := calldataload(add(offset, shift))
                }
                require(hashSlot == 0, "Non-empty hash slot.");
    
                assembly {
                    calldatacopy(scratchBuf1, offset, blobLength)
                    mstore(add(scratchBuf1, shift), seedHash)
                    seedHash := sha3(scratchBuf1, blobLength)
                    uncleHeaderLength := blobLength
                }
            }
    
            // At this moment the uncle hash is known.
            uncleHash = bytes32(seedHash);
    
            // Construct the uncle list of a canonical block.
            uint256 scratchBuf2 = scratchBuf1 + uncleHeaderLength;
            uint256 unclesLength;
            assembly {
                unclesLength := and(calldataload(sub(offset, 28)), 0xffff)
            }
            uint256 unclesShift;
            assembly {
                unclesShift := and(calldataload(sub(offset, 26)), 0xffff)
            }
            require(
                unclesShift + uncleHeaderLength <= unclesLength,
                "Shift bounds check."
            );
    
            offset += 6;
            assembly {
                calldatacopy(scratchBuf2, offset, unclesLength)
            }
            memcpy(scratchBuf2 + unclesShift, scratchBuf1, uncleHeaderLength);
    
            assembly {
                seedHash := sha3(scratchBuf2, unclesLength)
            }
    
            offset += unclesLength;
    
            // Verify the canonical block header using the computed sha3Uncles.
            assembly {
                blobLength := and(calldataload(sub(offset, 30)), 0xffff)
                shift := and(calldataload(sub(offset, 28)), 0xffff)
            }
            require(shift + 32 <= blobLength, "Shift bounds check.");
    
            offset += 4;
            assembly {
                hashSlot := calldataload(add(offset, shift))
            }
            require(hashSlot == 0, "Non-empty hash slot.");
    
            assembly {
                calldatacopy(scratchBuf1, offset, blobLength)
                mstore(add(scratchBuf1, shift), seedHash)
    
                // At this moment the canonical block hash is known.
                blockHash := sha3(scratchBuf1, blobLength)
            }
        }
    
        // Helper to check the placeBet receipt. "offset" is the location of the proof beginning in the calldata.
        // RLP layout: [triePath, str([status, cumGasUsed, bloomFilter, [[address, [topics], data]])]
        function requireCorrectReceipt(uint256 offset) private view {
            uint256 leafHeaderByte;
            assembly {
                leafHeaderByte := byte(0, calldataload(offset))
            }
    
            require(leafHeaderByte >= 0xf7, "Receipt leaf longer than 55 bytes.");
            offset += leafHeaderByte - 0xf6;
    
            uint256 pathHeaderByte;
            assembly {
                pathHeaderByte := byte(0, calldataload(offset))
            }
    
            if (pathHeaderByte <= 0x7f) {
                offset += 1;
    
            } else {
                require(
                    pathHeaderByte >= 0x80 && pathHeaderByte <= 0xb7,
                    "Path is an RLP string."
                );
                offset += pathHeaderByte - 0x7f;
            }
    
            uint256 receiptStringHeaderByte;
            assembly {
                receiptStringHeaderByte := byte(0, calldataload(offset))
            }
            require(
                receiptStringHeaderByte == 0xb9,
                "Receipt string is always at least 256 bytes long, but less than 64k."
            );
            offset += 3;
    
            uint256 receiptHeaderByte;
            assembly {
                receiptHeaderByte := byte(0, calldataload(offset))
            }
            require(
                receiptHeaderByte == 0xf9,
                "Receipt is always at least 256 bytes long, but less than 64k."
            );
            offset += 3;
    
            uint256 statusByte;
            assembly {
                statusByte := byte(0, calldataload(offset))
            }
            require(statusByte == 0x1, "Status should be success.");
            offset += 1;
    
            uint256 cumGasHeaderByte;
            assembly {
                cumGasHeaderByte := byte(0, calldataload(offset))
            }
            if (cumGasHeaderByte <= 0x7f) {
                offset += 1;
    
            } else {
                require(
                    cumGasHeaderByte >= 0x80 && cumGasHeaderByte <= 0xb7,
                    "Cumulative gas is an RLP string."
                );
                offset += cumGasHeaderByte - 0x7f;
            }
    
            uint256 bloomHeaderByte;
            assembly {
                bloomHeaderByte := byte(0, calldataload(offset))
            }
            require(
                bloomHeaderByte == 0xb9,
                "Bloom filter is always 256 bytes long."
            );
            offset += 256 + 3;
    
            uint256 logsListHeaderByte;
            assembly {
                logsListHeaderByte := byte(0, calldataload(offset))
            }
            require(
                logsListHeaderByte == 0xf8,
                "Logs list is less than 256 bytes long."
            );
            offset += 2;
    
            uint256 logEntryHeaderByte;
            assembly {
                logEntryHeaderByte := byte(0, calldataload(offset))
            }
            require(
                logEntryHeaderByte == 0xf8,
                "Log entry is less than 256 bytes long."
            );
            offset += 2;
    
            uint256 addressHeaderByte;
            assembly {
                addressHeaderByte := byte(0, calldataload(offset))
            }
            require(addressHeaderByte == 0x94, "Address is 20 bytes long.");
    
            uint256 logAddress;
            assembly {
                logAddress := and(
                    calldataload(sub(offset, 11)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
            require(logAddress == uint256(address(this)));
        }
    
        // Memory copy.
        function memcpy(uint256 dest, uint256 src, uint256 len) private pure {
            // Full 32 byte words
            for (; len >= 32; len -= 32) {
                assembly {
                    mstore(dest, mload(src))
                }
                dest += 32;
                src += 32;
            }
    
            // Remaining bytes
            uint256 mask = 256**(32 - len) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask))
                let destpart := and(mload(dest), mask)
                mstore(dest, or(destpart, srcpart))
            }
        }
    }
    """#"
    text_o = """
    type dice2Win_Bet is record
      #{config.reserved}__amount : nat;
      modulo : nat;
      rollUnder : nat;
      placeBlockNumber : nat;
      mask : nat;
      gambler : address;
    end;
    
    type constructor_args is unit;
    type approveNextOwner_args is record
      nextOwner_ : address;
    end;
    
    type acceptNextOwner_args is unit;
    type fallback_args is unit;
    type setSecretSigner_args is record
      newSecretSigner : address;
    end;
    
    type setCroupier_args is record
      newCroupier : address;
    end;
    
    type setMaxProfit_args is record
      maxProfit_ : nat;
    end;
    
    type increaseJackpot_args is record
      increaseAmount : nat;
    end;
    
    type withdrawFunds_args is record
      beneficiary : address;
      withdrawAmount : nat;
    end;
    
    type kill_args is unit;
    type placeBet_args is record
      betMask : nat;
      modulo : nat;
      commitLastBlock : nat;
      commit : nat;
      r : bytes;
      s : bytes;
    end;
    
    type settleBet_args is record
      reveal : nat;
      blockHash : bytes;
    end;
    
    type settleBetUncleMerkleProof_args is record
      reveal : nat;
      canonicalBlockNumber : nat;
    end;
    
    type refundBet_args is record
      commit : nat;
    end;
    
    type state is record
      owner : address;
      nextOwner : address;
      maxProfit : nat;
      secretSigner : address;
      jackpotSize : nat;
      lockedInBets : nat;
      bets : map(nat, dice2Win_Bet);
      croupier : address;
    end;
    
    const dice2Win_Bet_default : dice2Win_Bet = record [ #{config.reserved}__amount = 0n;
      modulo = 0n;
      rollUnder = 0n;
      placeBlockNumber = 0n;
      mask = 0n;
      gambler = burn_address ];
    
    function pow (const base : nat; const exp : nat) : nat is
      block {
        var b : nat := base;
        var e : nat := exp;
        var r : nat := 1n;
        while e > 0n block {
          if e mod 2n = 1n then {
            r := r * b;
          } else skip;
          b := b * b;
          e := e / 2n;
        }
      } with r;
    
    const burn_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    
    type router_enum is
      | Constructor of constructor_args
     | ApproveNextOwner of approveNextOwner_args
     | AcceptNextOwner of acceptNextOwner_args
     | Fallback of fallback_args
     | SetSecretSigner of setSecretSigner_args
     | SetCroupier of setCroupier_args
     | SetMaxProfit of setMaxProfit_args
     | IncreaseJackpot of increaseJackpot_args
     | WithdrawFunds of withdrawFunds_args
     | Kill of kill_args
     | PlaceBet of placeBet_args
     | SettleBet of settleBet_args
     | SettleBetUncleMerkleProof of settleBetUncleMerkleProof_args
     | RefundBet of refundBet_args;
    
    const hOUSE_EDGE_PERCENT : nat = 1n
    
    const hOUSE_EDGE_MINIMUM_AMOUNT : nat = (0.0003n * 1000000n)
    
    const mIN_JACKPOT_BET : nat = (0.1n * 1000000n)
    
    const jACKPOT_MODULO : nat = 1000n
    
    const jACKPOT_FEE : nat = (0.001n * 1000000n)
    
    const mIN_BET : nat = (0.01n * 1000000n)
    
    const mAX_AMOUNT : nat = (300000n * 1000000n)
    
    const mAX_MODULO : nat = 100n
    
    const mAX_MASK_MODULO : nat = 40n
    
    const mAX_BET_MASK : nat = pow(2n, mAX_MASK_MODULO)
    
    const bET_EXPIRATION_BLOCKS : nat = 250n
    
    const dUMMY_ADDRESS : address = (0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE : address)
    
    (* EventDefinition FailedPayment(beneficiary : address; #{config.reserved}__amount : nat) *)
    
    (* EventDefinition Payment(beneficiary : address; #{config.reserved}__amount : nat) *)
    
    (* EventDefinition JackpotPayment(beneficiary : address; #{config.reserved}__amount : nat) *)
    
    (* EventDefinition Commit(commit : nat) *)
    
    const pOPCNT_MULT : nat = 0x0000000000002000000000100000000008000000000400000000020000000001n
    
    const pOPCNT_MASK : nat = 0x0001041041041041041041041041041041041041041041041041041041041041n
    
    const pOPCNT_MODULO : nat = 0x3Fn
    
    function constructor (const test_self : state) : (state) is
      block {
        test_self.owner := Tezos.sender;
        test_self.secretSigner := dUMMY_ADDRESS;
        test_self.croupier := dUMMY_ADDRESS;
      } with (test_self);
    
    (* modifier onlyOwner inlined *)
    
    (* modifier onlyCroupier inlined *)
    
    function approveNextOwner (const test_self : state; const nextOwner_ : address) : (state) is
      block {
        assert((Tezos.sender = test_self.owner)) (* "OnlyOwner methods called by non-owner." *);
        assert((nextOwner_ =/= test_self.owner)) (* "Cannot approve current owner." *);
        test_self.nextOwner := nextOwner_;
      } with (test_self);
    
    function acceptNextOwner (const test_self : state) : (state) is
      block {
        assert((Tezos.sender = test_self.nextOwner)) (* "Can only accept preapproved new owner." *);
        test_self.owner := test_self.nextOwner;
      } with (test_self);
    
    function fallback (const #{config.reserved}__unit : unit) : (unit) is
      block {
        skip
      } with (unit);
    
    function setSecretSigner (const test_self : state; const newSecretSigner : address) : (state) is
      block {
        assert((Tezos.sender = test_self.owner)) (* "OnlyOwner methods called by non-owner." *);
        test_self.secretSigner := newSecretSigner;
      } with (test_self);
    
    function setCroupier (const test_self : state; const newCroupier : address) : (state) is
      block {
        assert((Tezos.sender = test_self.owner)) (* "OnlyOwner methods called by non-owner." *);
        test_self.croupier := newCroupier;
      } with (test_self);
    
    function setMaxProfit (const test_self : state; const maxProfit_ : nat) : (state) is
      block {
        assert((Tezos.sender = test_self.owner)) (* "OnlyOwner methods called by non-owner." *);
        assert((maxProfit_ < mAX_AMOUNT)) (* "maxProfit should be a sane number." *);
        test_self.maxProfit := maxProfit_;
      } with (test_self);
    
    function increaseJackpot (const test_self : state; const increaseAmount : nat) : (state) is
      block {
        assert((Tezos.sender = test_self.owner)) (* "OnlyOwner methods called by non-owner." *);
        assert((increaseAmount <= self_address.#{config.reserved}__balance)) (* "Increase amount larger than balance." *);
        assert((((test_self.jackpotSize + test_self.lockedInBets) + increaseAmount) <= self_address.#{config.reserved}__balance)) (* "Not enough funds." *);
        test_self.jackpotSize := (test_self.jackpotSize + abs(increaseAmount));
      } with (test_self);
    
    function sendFunds (const opList : list(operation); const test_self : state; const beneficiary : address; const #{config.reserved}__amount : nat; const successLogAmount : nat) : (list(operation)) is
      block {
        if (const op0 : operation = transaction((unit), (#{config.reserved}__amount * 1mutez), (get_contract(beneficiary) : contract(unit)))) then block {
          (* EmitStatement Payment(beneficiary, successLogAmount) *)
        } else block {
          (* EmitStatement FailedPayment(beneficiary, amount) *)
        };
      } with (list [op0]);
    
    function withdrawFunds (const opList : list(operation); const test_self : state; const beneficiary : address; const withdrawAmount : nat) : (list(operation)) is
      block {
        assert((Tezos.sender = test_self.owner)) (* "OnlyOwner methods called by non-owner." *);
        assert((withdrawAmount <= self_address.#{config.reserved}__balance)) (* "Increase amount larger than balance." *);
        assert((((test_self.jackpotSize + test_self.lockedInBets) + withdrawAmount) <= self_address.#{config.reserved}__balance)) (* "Not enough funds." *);
        opList := sendFunds((test_self : address), beneficiary, withdrawAmount, withdrawAmount);
      } with (opList);
    
    function kill (const test_self : state) : (unit) is
      block {
        assert((Tezos.sender = test_self.owner)) (* "OnlyOwner methods called by non-owner." *);
        assert((test_self.lockedInBets = 0n)) (* "All bets should be processed (settled or refunded) before test_self-destruct." *);
        selfdestruct(test_self.owner) (* unsupported *);
      } with (unit);
    
    function getDiceWinAmount (const test_self : state; const #{config.reserved}__amount : nat; const modulo : nat; const rollUnder : nat) : ((nat * nat)) is
      block {
        const winAmount : nat = 0n;
        const jackpotFee : nat = 0n;
        assert(((0n < rollUnder) and (rollUnder <= modulo))) (* "Win probability out of range." *);
        jackpotFee := (case (#{config.reserved}__amount >= mIN_JACKPOT_BET) of | True -> jACKPOT_FEE | False -> 0n end);
        const houseEdge : nat = ((#{config.reserved}__amount * hOUSE_EDGE_PERCENT) / 100n);
        if (houseEdge < hOUSE_EDGE_MINIMUM_AMOUNT) then block {
          houseEdge := hOUSE_EDGE_MINIMUM_AMOUNT;
        } else block {
          skip
        };
        assert(((houseEdge + jackpotFee) <= #{config.reserved}__amount)) (* "Bet doesn't even cover house edge." *);
        winAmount := ((abs(abs(#{config.reserved}__amount - houseEdge) - jackpotFee) * modulo) / rollUnder);
      } with ((winAmount, jackpotFee));
    
    function placeBet (const test_self : state; const betMask : nat; const modulo : nat; const commitLastBlock : nat; const commit : nat; const r : bytes; const s : bytes) : (state) is
      block {
        const bet : dice2Win_Bet = (case test_self.bets[commit] of | None -> dice2Win_Bet_default | Some(x) -> x end);
        assert((bet.gambler = burn_address)) (* "Bet should be in a 'clean' _state." *);
        const #{config.reserved}__amount : nat = (amount / 1mutez);
        assert(((modulo > 1n) and (modulo <= mAX_MODULO))) (* "Modulo should be within range." *);
        assert(((#{config.reserved}__amount >= mIN_BET) and (#{config.reserved}__amount <= mAX_AMOUNT))) (* "Amount should be within range." *);
        assert(((betMask > 0n) and (betMask < mAX_BET_MASK))) (* "Mask should be within range." *);
        assert((0n <= commitLastBlock)) (* "Commit has expired." *);
        const signatureHash : bytes = sha_256((abs(commitLastBlock), commit));
        assert((test_self.secretSigner = ecrecover(signatureHash, 27n, r, s))) (* "ECDSA signature is not valid." *);
        const rollUnder : nat = 0n;
        const mask : nat = 0n;
        if (modulo <= mAX_MASK_MODULO) then block {
          rollUnder := (Bitwise.and((betMask * pOPCNT_MULT), pOPCNT_MASK) mod pOPCNT_MODULO);
          mask := betMask;
        } else block {
          assert(((betMask > 0n) and (betMask <= modulo))) (* "High modulo range, betMask larger than modulo." *);
          rollUnder := betMask;
        };
        const possibleWinAmount : nat = 0n;
        const jackpotFee : nat = 0n;
        (possibleWinAmount, jackpotFee) := getDiceWinAmount(test_self, #{config.reserved}__amount, modulo, rollUnder);
        assert((possibleWinAmount <= (#{config.reserved}__amount + test_self.maxProfit))) (* "maxProfit limit violation." *);
        test_self.lockedInBets := (test_self.lockedInBets + abs(possibleWinAmount));
        test_self.jackpotSize := (test_self.jackpotSize + abs(jackpotFee));
        assert(((test_self.jackpotSize + test_self.lockedInBets) <= self_address.#{config.reserved}__balance)) (* "Cannot afford to lose this bet." *);
        (* EmitStatement Commit(commit) *)
        bet.#{config.reserved}__amount := #{config.reserved}__amount;
        bet.modulo := abs(modulo);
        bet.rollUnder := abs(rollUnder);
        bet.placeBlockNumber := abs(0n);
        bet.mask := abs(mask);
        bet.gambler := Tezos.sender;
      } with (test_self);
    
    function settleBetCommon (const opList : list(operation); const test_self : state; const bet : dice2Win_Bet; const reveal : nat; const entropyBlockHash : bytes) : (list(operation) * state) is
      block {
        const #{config.reserved}__amount : nat = bet.#{config.reserved}__amount;
        const modulo : nat = bet.modulo;
        const rollUnder : nat = bet.rollUnder;
        const gambler : address = bet.gambler;
        assert((#{config.reserved}__amount =/= 0n)) (* "Bet should be in an 'active' _state" *);
        bet.#{config.reserved}__amount := 0n;
        const entropy : bytes = sha_256((reveal, entropyBlockHash));
        const dice : nat = (abs(entropy) mod modulo);
        const diceWinAmount : nat = 0n;
        const jackpotFee_ : nat = 0n;
        (diceWinAmount, jackpotFee_) := getDiceWinAmount(test_self, #{config.reserved}__amount, modulo, rollUnder);
        const diceWin : nat = 0n;
        const jackpotWin : nat = 0n;
        if (modulo <= mAX_MASK_MODULO) then block {
          if (Bitwise.and(pow(2n, dice), bet.mask) =/= 0n) then block {
            diceWin := diceWinAmount;
          } else block {
            skip
          };
        } else block {
          if (dice < rollUnder) then block {
            diceWin := diceWinAmount;
          } else block {
            skip
          };
        };
        test_self.lockedInBets := abs(test_self.lockedInBets - abs(diceWinAmount));
        if (#{config.reserved}__amount >= mIN_JACKPOT_BET) then block {
          const jackpotRng : nat = ((abs(entropy) / modulo) mod jACKPOT_MODULO);
          if (jackpotRng = 0n) then block {
            jackpotWin := test_self.jackpotSize;
            test_self.jackpotSize := 0n;
          } else block {
            skip
          };
        } else block {
          skip
        };
        if (jackpotWin > 0n) then block {
          (* EmitStatement JackpotPayment(gambler, jackpotWin) *)
        } else block {
          skip
        };
        opList := sendFunds((test_self : address), gambler, (case ((diceWin + jackpotWin) = 0n) of | True -> 1n | False -> (diceWin + jackpotWin) end), diceWin);
      } with (opList, test_self);
    
    function settleBet (const opList : list(operation); const test_self : state; const reveal : nat; const blockHash : bytes) : (list(operation) * state) is
      block {
        assert((Tezos.sender = test_self.croupier)) (* "OnlyCroupier methods called by non-croupier." *);
        const commit : nat = abs(sha_256((reveal)));
        const bet : dice2Win_Bet = (case test_self.bets[commit] of | None -> dice2Win_Bet_default | Some(x) -> x end);
        const placeBlockNumber : nat = bet.placeBlockNumber;
        assert((0n > placeBlockNumber)) (* "settleBet in the same block as placeBet, or before." *);
        assert((0n <= (placeBlockNumber + bET_EXPIRATION_BLOCKS))) (* "Blockhash can't be queried by EVM." *);
        assert((("00" : bytes) (* Should be blockhash of placeBlockNumber *) = blockHash));
        const tmp_0 : (list(operation) * state) = settleBetCommon(test_self, bet, reveal, blockHash);
        opList := tmp_0.0;
        test_self := tmp_0.1;
      } with (opList, test_self);
    
    function memcpy (const dest : nat; const src : nat; const len : nat) : (unit) is
      block {
        while (len >= 32n) block {
          failwith("Unsupported InlineAssembly");
          (* InlineAssembly {
              mstore(dest, mload(src))
          } *)
          dest := (dest + 32n);
          src := (src + 32n);
          len := abs(len - 32n);
        };
        const mask : nat = abs(pow(256n, abs(32n - len)) - 1n);
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        } *)
      } with (unit);
    
    function verifyMerkleProof (const seedHash : nat; const offset : nat) : ((bytes * bytes)) is
      block {
        const blockHash : bytes = ("00": bytes);
        const uncleHash : bytes = ("00": bytes);
        const scratchBuf1 : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            scratchBuf1 := mload(0x40)
        } *)
        const uncleHeaderLength : nat = 0n;
        const blobLength : nat = 0n;
        const shift : nat = 0n;
        const hashSlot : nat = 0n;
        while (True) block {
          failwith("Unsupported InlineAssembly");
          (* InlineAssembly {
              blobLength := and(calldataload(sub(offset, 30)), 0xffff)
          } *)
          if (blobLength = 0n) then block {
            (* `break` statement is not supported in LIGO *);
          } else block {
            skip
          };
          failwith("Unsupported InlineAssembly");
          (* InlineAssembly {
              shift := and(calldataload(sub(offset, 28)), 0xffff)
          } *)
          assert(((shift + 32n) <= blobLength)) (* "Shift bounds check." *);
          offset := (offset + 4n);
          failwith("Unsupported InlineAssembly");
          (* InlineAssembly {
              hashSlot := calldataload(add(offset, shift))
          } *)
          assert((hashSlot = 0n)) (* "Non-empty hash slot." *);
          failwith("Unsupported InlineAssembly");
          (* InlineAssembly {
              calldatacopy(scratchBuf1, offset, blobLength)
              mstore(add(scratchBuf1, shift), seedHash)
              seedHash := keccak256(scratchBuf1, blobLength)
              uncleHeaderLength := blobLength
          } *)
          offset := (offset + blobLength);
        };
        uncleHash := (seedHash : bytes);
        const scratchBuf2 : nat = (scratchBuf1 + uncleHeaderLength);
        const unclesLength : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            unclesLength := and(calldataload(sub(offset, 28)), 0xffff)
        } *)
        const unclesShift : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            unclesShift := and(calldataload(sub(offset, 26)), 0xffff)
        } *)
        assert(((unclesShift + uncleHeaderLength) <= unclesLength)) (* "Shift bounds check." *);
        offset := (offset + 6n);
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            calldatacopy(scratchBuf2, offset, unclesLength)
        } *)
        memcpy((scratchBuf2 + unclesShift), scratchBuf1, uncleHeaderLength);
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            seedHash := keccak256(scratchBuf2, unclesLength)
        } *)
        offset := (offset + unclesLength);
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            blobLength := and(calldataload(sub(offset, 30)), 0xffff)
            shift := and(calldataload(sub(offset, 28)), 0xffff)
        } *)
        assert(((shift + 32n) <= blobLength)) (* "Shift bounds check." *);
        offset := (offset + 4n);
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            hashSlot := calldataload(add(offset, shift))
        } *)
        assert((hashSlot = 0n)) (* "Non-empty hash slot." *);
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            calldatacopy(scratchBuf1, offset, blobLength)
            mstore(add(scratchBuf1, shift), seedHash)
            blockHash := keccak256(scratchBuf1, blobLength)
        } *)
      } with ((blockHash, uncleHash));
    
    function requireCorrectReceipt (const offset : nat) : (unit) is
      block {
        const leafHeaderByte : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            leafHeaderByte := byte(0, calldataload(offset))
        } *)
        assert((leafHeaderByte >= 0xf7n)) (* "Receipt leaf longer than 55 bytes." *);
        offset := (offset + abs(leafHeaderByte - 0xf6n));
        const pathHeaderByte : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            pathHeaderByte := byte(0, calldataload(offset))
        } *)
        if (pathHeaderByte <= 0x7fn) then block {
          offset := (offset + 1n);
        } else block {
          assert(((pathHeaderByte >= 0x80n) and (pathHeaderByte <= 0xb7n))) (* "Path is an RLP string." *);
          offset := (offset + abs(pathHeaderByte - 0x7fn));
        };
        const receiptStringHeaderByte : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            receiptStringHeaderByte := byte(0, calldataload(offset))
        } *)
        assert((receiptStringHeaderByte = 0xb9n)) (* "Receipt string is always at least 256 bytes long, but less than 64k." *);
        offset := (offset + 3n);
        const receiptHeaderByte : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            receiptHeaderByte := byte(0, calldataload(offset))
        } *)
        assert((receiptHeaderByte = 0xf9n)) (* "Receipt is always at least 256 bytes long, but less than 64k." *);
        offset := (offset + 3n);
        const statusByte : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            statusByte := byte(0, calldataload(offset))
        } *)
        assert((statusByte = 0x1n)) (* "Status should be success." *);
        offset := (offset + 1n);
        const cumGasHeaderByte : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            cumGasHeaderByte := byte(0, calldataload(offset))
        } *)
        if (cumGasHeaderByte <= 0x7fn) then block {
          offset := (offset + 1n);
        } else block {
          assert(((cumGasHeaderByte >= 0x80n) and (cumGasHeaderByte <= 0xb7n))) (* "Cumulative gas is an RLP string." *);
          offset := (offset + abs(cumGasHeaderByte - 0x7fn));
        };
        const bloomHeaderByte : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            bloomHeaderByte := byte(0, calldataload(offset))
        } *)
        assert((bloomHeaderByte = 0xb9n)) (* "Bloom filter is always 256 bytes long." *);
        offset := (offset + (256 + 3));
        const logsListHeaderByte : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            logsListHeaderByte := byte(0, calldataload(offset))
        } *)
        assert((logsListHeaderByte = 0xf8n)) (* "Logs list is less than 256 bytes long." *);
        offset := (offset + 2n);
        const logEntryHeaderByte : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            logEntryHeaderByte := byte(0, calldataload(offset))
        } *)
        assert((logEntryHeaderByte = 0xf8n)) (* "Log entry is less than 256 bytes long." *);
        offset := (offset + 2n);
        const addressHeaderByte : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            addressHeaderByte := byte(0, calldataload(offset))
        } *)
        assert((addressHeaderByte = 0x94n)) (* "Address is 20 bytes long." *);
        const logAddress : nat = 0n;
        failwith("Unsupported InlineAssembly");
        (* InlineAssembly {
            logAddress := and(calldataload(sub(offset, 11)), 0xffffffffffffffffffffffffffffffffffffffff)
        } *)
        assert((logAddress = abs(self_address)));
      } with (unit);
    
    function settleBetUncleMerkleProof (const opList : list(operation); const test_self : state; const reveal : nat; const canonicalBlockNumber : nat) : (list(operation) * state) is
      block {
        assert((Tezos.sender = test_self.croupier)) (* "OnlyCroupier methods called by non-croupier." *);
        const commit : nat = abs(sha_256((reveal)));
        const bet : dice2Win_Bet = (case test_self.bets[commit] of | None -> dice2Win_Bet_default | Some(x) -> x end);
        assert((0n <= (canonicalBlockNumber + bET_EXPIRATION_BLOCKS))) (* "Blockhash can't be queried by EVM." *);
        requireCorrectReceipt((((4 + 32) + 32) + 4n));
        const canonicalHash : bytes = ("00": bytes);
        const uncleHash : bytes = ("00": bytes);
        (canonicalHash, uncleHash) := verifyMerkleProof(commit, ((4 + 32) + 32n));
        assert((("00" : bytes) (* Should be blockhash of canonicalBlockNumber *) = canonicalHash));
        const tmp_0 : (list(operation) * state) = settleBetCommon(test_self, bet, reveal, uncleHash);
        opList := tmp_0.0;
        test_self := tmp_0.1;
      } with (opList, test_self);
    
    function refundBet (const opList : list(operation); const test_self : state; const commit : nat) : (list(operation) * state) is
      block {
        const bet : dice2Win_Bet = (case test_self.bets[commit] of | None -> dice2Win_Bet_default | Some(x) -> x end);
        const #{config.reserved}__amount : nat = bet.#{config.reserved}__amount;
        assert((#{config.reserved}__amount =/= 0n)) (* "Bet should be in an 'active' _state" *);
        assert((0n > (bet.placeBlockNumber + bET_EXPIRATION_BLOCKS))) (* "Blockhash can't be queried by EVM." *);
        bet.#{config.reserved}__amount := 0n;
        const diceWinAmount : nat = 0n;
        const jackpotFee : nat = 0n;
        (diceWinAmount, jackpotFee) := getDiceWinAmount(test_self, #{config.reserved}__amount, bet.modulo, bet.rollUnder);
        test_self.lockedInBets := abs(test_self.lockedInBets - abs(diceWinAmount));
        test_self.jackpotSize := abs(test_self.jackpotSize - abs(jackpotFee));
        opList := sendFunds((test_self : address), bet.gambler, #{config.reserved}__amount, #{config.reserved}__amount);
      } with (opList, test_self);
    
    function main (const action : router_enum; const test_self : state) : (list(operation) * state) is
      (case action of
      | Constructor(match_action) -> ((nil: list(operation)), constructor(test_self))
      | ApproveNextOwner(match_action) -> ((nil: list(operation)), approveNextOwner(test_self, match_action.nextOwner_))
      | AcceptNextOwner(match_action) -> ((nil: list(operation)), acceptNextOwner(test_self))
      | Fallback(match_action) -> block {
        (* This function does nothing, but it's present in router *)
        const tmp : unit = fallback(unit);
      } with (((nil: list(operation)), test_self))
      | SetSecretSigner(match_action) -> ((nil: list(operation)), setSecretSigner(test_self, match_action.newSecretSigner))
      | SetCroupier(match_action) -> ((nil: list(operation)), setCroupier(test_self, match_action.newCroupier))
      | SetMaxProfit(match_action) -> ((nil: list(operation)), setMaxProfit(test_self, match_action.maxProfit_))
      | IncreaseJackpot(match_action) -> ((nil: list(operation)), increaseJackpot(test_self, match_action.increaseAmount))
      | WithdrawFunds(match_action) -> (withdrawFunds((nil: list(operation)), test_self, match_action.beneficiary, match_action.withdrawAmount), test_self)
      | Kill(match_action) -> block {
        (* This function does nothing, but it's present in router *)
        const tmp : unit = kill(test_self);
      } with (((nil: list(operation)), test_self))
      | PlaceBet(match_action) -> ((nil: list(operation)), placeBet(test_self, match_action.betMask, match_action.modulo, match_action.commitLastBlock, match_action.commit, match_action.r, match_action.s))
      | SettleBet(match_action) -> settleBet((nil: list(operation)), test_self, match_action.reveal, match_action.blockHash)
      | SettleBetUncleMerkleProof(match_action) -> settleBetUncleMerkleProof((nil: list(operation)), test_self, match_action.reveal, match_action.canonicalBlockNumber)
      | RefundBet(match_action) -> refundBet((nil: list(operation)), test_self, match_action.commit)
      end);
    """#"
    make_test text_i, text_o, router: true, allow_need_prevent_deploy: true
  # ###################################################################################################
  it "Creatures", ()->
    text_i = """
    pragma solidity ^0.4.16;
    
    contract Permissions {
        address ownerAddress;
        address storageAddress;
        address callerAddress;
    
        function Permissions() public {
            ownerAddress = msg.sender;
        }
    
        modifier onlyOwner() {
            require(msg.sender == ownerAddress);
            _;
        }
    
        modifier onlyCaller() {
            require(msg.sender == callerAddress);
            _;
        }
    
        function getOwner() external view returns (address) {
            return ownerAddress;
        }
    
        function getStorageAddress() external view returns (address) {
            return storageAddress;
        }
    
        function getCaller() external view returns (address) {
            return callerAddress;
        }
    
        function transferOwnership(address newOwner) external onlyOwner {
            if (newOwner != address(0)) {
                ownerAddress = newOwner;
            }
        }
        function newStorage(address _new) external onlyOwner {
            if (_new != address(0)) {
                storageAddress = _new;
            }
        }
        function newCaller(address _new) external onlyOwner {
            if (_new != address(0)) {
                callerAddress = _new;
            }
        }
    }
    
    contract Creatures is Permissions {
        struct Creature {
            uint16 species;
            uint8 subSpecies;
            uint8 eyeColor;
            uint64 timestamp;
        }
        Creature[] creatures;
    
        mapping(uint256 => address) public creatureIndexToOwner;
        mapping(address => uint256) ownershipTokenCount;
    
        event CreateCreature(uint256 id, address indexed owner);
        event Transfer(address _from, address _to, uint256 creatureID);
    
        function add(
            address _owner,
            uint16 _species,
            uint8 _subSpecies,
            uint8 _eyeColor
        ) external onlyCaller {
            // do checks in caller function
            Creature memory _creature = Creature({
                species: _species,
                subSpecies: _subSpecies,
                eyeColor: _eyeColor,
                timestamp: uint64(now)
            });
            uint256 newCreatureID = creatures.push(_creature) - 1;
            transfer(0, _owner, newCreatureID);
            CreateCreature(newCreatureID, _owner);
        }
        function getCreature(uint256 id)
            external
            view
            returns (address, uint16, uint8, uint8, uint64)
        {
            Creature storage c = creatures[id];
            address owner = creatureIndexToOwner[id];
            return (owner, c.species, c.subSpecies, c.eyeColor, c.timestamp);
        }
        function transfer(address _from, address _to, uint256 _tokenId)
            public
            onlyCaller
        {
            // do checks in caller function
            creatureIndexToOwner[_tokenId] = _to;
            if (_from != address(0)) {
                ownershipTokenCount[_from]--;
            }
            ownershipTokenCount[_to]++;
            Transfer(_from, _to, _tokenId);
        }
    }
    """#"
    text_o = """
    type creatures_Creature is record
      species : nat;
      subSpecies : nat;
      eyeColor : nat;
      timestamp : nat;
    end;
    
    type newCaller_args is record
      new_ : address;
    end;
    
    type newStorage_args is record
      new_ : address;
    end;
    
    type transferOwnership_args is record
      newOwner : address;
    end;
    
    type getCaller_args is record
      callbackAddress : address;
    end;
    
    type getStorageAddress_args is record
      callbackAddress : address;
    end;
    
    type getOwner_args is record
      callbackAddress : address;
    end;
    
    type transfer_args is record
      from_ : address;
      to_ : address;
      tokenId_ : nat;
    end;
    
    type add_args is record
      owner_ : address;
      species_ : nat;
      subSpecies_ : nat;
      eyeColor_ : nat;
    end;
    
    type getCreature_args is record
      id : nat;
      callbackAddress : address;
    end;
    
    type constructor_args is unit;
    type state is record
      callerAddress : address;
      storageAddress : address;
      ownerAddress : address;
      creatures : map(nat, creatures_Creature);
      creatureIndexToOwner : map(nat, address);
      ownershipTokenCount : map(address, nat);
    end;
    
    const creatures_Creature_default : creatures_Creature = record [ species = 0n;
      subSpecies = 0n;
      eyeColor = 0n;
      timestamp = 0n ];
    
    const burn_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    
    type router_enum is
      | NewCaller of newCaller_args
     | NewStorage of newStorage_args
     | TransferOwnership of transferOwnership_args
     | GetCaller of getCaller_args
     | GetStorageAddress of getStorageAddress_args
     | GetOwner of getOwner_args
     | Transfer of transfer_args
     | Add of add_args
     | GetCreature of getCreature_args
     | Constructor of constructor_args;
    
    (* EventDefinition CreateCreature(id : nat; owner : address) *)
    
    (* EventDefinition Transfer(from_ : address; to_ : address; creatureID : nat) *)
    
    function newCaller (const test_self : state; const new_ : address) : (state) is
      block {
        assert((Tezos.sender = test_self.ownerAddress));
        if (new_ =/= burn_address) then block {
          test_self.callerAddress := new_;
        } else block {
          skip
        };
      } with (test_self);
    
    function newStorage (const test_self : state; const new_ : address) : (state) is
      block {
        assert((Tezos.sender = test_self.ownerAddress));
        if (new_ =/= burn_address) then block {
          test_self.storageAddress := new_;
        } else block {
          skip
        };
      } with (test_self);
    
    function transferOwnership (const test_self : state; const newOwner : address) : (state) is
      block {
        assert((Tezos.sender = test_self.ownerAddress));
        if (newOwner =/= burn_address) then block {
          test_self.ownerAddress := newOwner;
        } else block {
          skip
        };
      } with (test_self);
    
    function getCaller (const test_self : state) : (address) is
      block {
        skip
      } with (test_self.callerAddress);
    
    function getStorageAddress (const test_self : state) : (address) is
      block {
        skip
      } with (test_self.storageAddress);
    
    function getOwner (const test_self : state) : (address) is
      block {
        skip
      } with (test_self.ownerAddress);
    
    function permissions_constructor (const test_self : state) : (state) is
      block {
        test_self.ownerAddress := Tezos.sender;
      } with (test_self);
    
    function transfer (const test_self : state; const from_ : address; const to_ : address; const tokenId_ : nat) : (state) is
      block {
        assert((Tezos.sender = test_self.callerAddress));
        test_self.creatureIndexToOwner[tokenId_] := to_;
        if (from_ =/= burn_address) then block {
          (case test_self.ownershipTokenCount[from_] of | None -> 0n | Some(x) -> x end) := abs((case test_self.ownershipTokenCount[from_] of | None -> 0n | Some(x) -> x end) - 1n);
        } else block {
          skip
        };
        (case test_self.ownershipTokenCount[to_] of | None -> 0n | Some(x) -> x end) := (case test_self.ownershipTokenCount[to_] of | None -> 0n | Some(x) -> x end) + 1n;
        (* EmitStatement Transfer(_from, _to, _tokenId) *)
      } with (test_self);
    
    function add (const opList : list(operation); const test_self : state; const owner_ : address; const species_ : nat; const subSpecies_ : nat; const eyeColor_ : nat) : (list(operation) * state) is
      block {
        assert((Tezos.sender = test_self.callerAddress));
        const creature_ : creatures_Creature = record [ species = species_;
          subSpecies = subSpecies_;
          eyeColor = eyeColor_;
          timestamp = abs(#{config.reserved}__now) ];
        const tmp_0 : map(nat, creatures_Creature) = test_self.creatures;
        const newCreatureID : nat = abs(tmp_0[size(tmp_0)] := creature_ - 1n);
        transfer(burn_address, owner_, newCreatureID);
        (* EmitStatement CreateCreature(newCreatureID, _owner) *)
      } with (opList, test_self);
    
    function getCreature (const test_self : state; const id : nat) : ((address * nat * nat * nat * nat)) is
      block {
        const c : creatures_Creature = (case test_self.creatures[id] of | None -> creatures_Creature_default | Some(x) -> x end);
        const owner : address = (case test_self.creatureIndexToOwner[id] of | None -> burn_address | Some(x) -> x end);
      } with ((owner, c.species, c.subSpecies, c.eyeColor, c.timestamp));
    
    function constructor (const test_self : state) : (state) is
      block {
        test_self := permissions_constructor(test_self);
      } with (test_self);
    
    function main (const action : router_enum; const test_self : state) : (list(operation) * state) is
      (case action of
      | NewCaller(match_action) -> ((nil: list(operation)), newCaller(test_self, match_action.new_))
      | NewStorage(match_action) -> ((nil: list(operation)), newStorage(test_self, match_action.new_))
      | TransferOwnership(match_action) -> ((nil: list(operation)), transferOwnership(test_self, match_action.newOwner))
      | GetCaller(match_action) -> block {
        const tmp : (address) = getCaller(test_self);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(address))) end;
      } with ((opList, test_self))
      | GetStorageAddress(match_action) -> block {
        const tmp : (address) = getStorageAddress(test_self);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(address))) end;
      } with ((opList, test_self))
      | GetOwner(match_action) -> block {
        const tmp : (address) = getOwner(test_self);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(address))) end;
      } with ((opList, test_self))
      | Transfer(match_action) -> ((nil: list(operation)), transfer(test_self, match_action.from_, match_action.to_, match_action.tokenId_))
      | Add(match_action) -> add((nil: list(operation)), test_self, match_action.owner_, match_action.species_, match_action.subSpecies_, match_action.eyeColor_)
      | GetCreature(match_action) -> block {
        const tmp : ((address * nat * nat * nat * nat)) = getCreature(test_self, match_action.id);
        var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract((address * nat * nat * nat * nat)))) end;
      } with ((opList, test_self))
      | Constructor(match_action) -> ((nil: list(operation)), constructor(test_self))
      end);
    """#"
    make_test text_i, text_o, router: true