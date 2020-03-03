const atomicSwapEther_States_INVALID : nat = 0n;
const atomicSwapEther_States_OPEN : nat = 1n;
const atomicSwapEther_States_CLOSED : nat = 2n;
const atomicSwapEther_States_EXPIRED : nat = 3n;

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
  receiver : contract((nat * nat * address * bytes));
  swapID_ : bytes;
end;

type checkSecretKey_args is record
  receiver : contract(bytes);
  swapID_ : bytes;
end;

type state is record
  swaps : map(bytes, atomicSwapEther_Swap);
  swapStates : map(bytes, nat);
end;

const atomicSwapEther_Swap_default : atomicSwapEther_Swap = record [ timelock = 0n;
	value = 0n;
	ethTrader = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
	withdrawTrader = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
	secretLock = ("00": bytes);
	secretKey = ("00": bytes) ];

type router_enum is
  | Open of open_args
  | Close of close_args
  | Expire of expire_args
  | Check of check_args
  | CheckSecretKey of checkSecretKey_args;

(* EventDefinition Open(swapID_ : bytes; withdrawTrader_ : address; secretLock_ : bytes) *)

(* EventDefinition Expire(swapID_ : bytes) *)

(* EventDefinition Close(swapID_ : bytes; secretKey_ : bytes) *)

(* modifier onlyInvalidSwaps inlined *)

(* modifier onlyOpenSwaps inlined *)

(* modifier onlyClosedSwaps inlined *)

(* modifier onlyExpirableSwaps inlined *)

(* modifier onlyWithSecretKey inlined *)

function open (const self : state; const swapID_ : bytes; const withdrawTrader_ : address; const secretLock_ : bytes; const timelock_ : nat) : (list(operation) * state) is
  block {
    assert(((case self.swapStates[swapID_] of | None -> atomicSwapEther_States_INVALID | Some(x) -> x end) = atomicSwapEther_States_INVALID));
    const swap : atomicSwapEther_Swap = record [ timelock = timelock_;
    	value = (amount / 1mutez);
    	ethTrader = sender;
    	withdrawTrader = withdrawTrader_;
    	secretLock = secretLock_;
    	secretKey = ("00": bytes) (* args: 0 *) ];
    self.swaps[swapID_] := swap;
    self.swapStates[swapID_] := atomicSwapEther_States_OPEN;
    (* EmitStatement Open(_swapID, _withdrawTrader, _secretLock) *)
  } with ((nil: list(operation)), self);

function close (const self : state; const swapID_ : bytes; const secretKey_ : bytes) : (list(operation) * state) is
  block {
    assert(((case self.swaps[swapID_] of | None -> atomicSwapEther_Swap_default | Some(x) -> x end).secretLock = sha_256(secretKey_)));
    assert(((case self.swapStates[swapID_] of | None -> atomicSwapEther_States_INVALID | Some(x) -> x end) = atomicSwapEther_States_OPEN));
    const swap : atomicSwapEther_Swap = (case self.swaps[swapID_] of | None -> atomicSwapEther_Swap_default | Some(x) -> x end);
    self.swaps[swapID_].secretKey := secretKey_;
    self.swapStates[swapID_] := atomicSwapEther_States_CLOSED;
    var opList : list(operation) := list transaction(unit, swap.value * 1mutez, (get_contract(swap.withdrawTrader) : contract(unit))) end;
    (* EmitStatement Close(_swapID, _secretKey) *)
  } with (opList, self);

function expire (const self : state; const swapID_ : bytes) : (list(operation) * state) is
  block {
    assert((abs(now - ("1970-01-01T00:00:00Z": timestamp)) >= (case self.swaps[swapID_] of | None -> atomicSwapEther_Swap_default | Some(x) -> x end).timelock));
    assert(((case self.swapStates[swapID_] of | None -> atomicSwapEther_States_INVALID | Some(x) -> x end) = atomicSwapEther_States_OPEN));
    const swap : atomicSwapEther_Swap = (case self.swaps[swapID_] of | None -> atomicSwapEther_Swap_default | Some(x) -> x end);
    self.swapStates[swapID_] := atomicSwapEther_States_EXPIRED;
    var opList : list(operation) := list transaction(unit, swap.value * 1mutez, (get_contract(swap.ethTrader) : contract(unit))) end;
    (* EmitStatement Expire(_swapID) *)
  } with (opList, self);

function check (const self : state; const receiver : contract((nat * nat * address * bytes)); const swapID_ : bytes) : (list(operation)) is
  block {
    const timelock : nat = 0n;
    const value : nat = 0n;
    const withdrawTrader : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    const secretLock : bytes = ("00": bytes);
    const swap : atomicSwapEther_Swap = (case self.swaps[swapID_] of | None -> atomicSwapEther_Swap_default | Some(x) -> x end);
    var opList : list(operation) := list transaction(((swap.timelock, swap.value, swap.withdrawTrader, swap.secretLock)), 0mutez, receiver) end;
  } with (opList);

function checkSecretKey (const self : state; const receiver : contract(bytes); const swapID_ : bytes) : (list(operation)) is
  block {
    assert(((case self.swapStates[swapID_] of | None -> atomicSwapEther_States_INVALID | Some(x) -> x end) = atomicSwapEther_States_CLOSED));
    const secretKey : bytes = ("00": bytes);
    const swap : atomicSwapEther_Swap = (case self.swaps[swapID_] of | None -> atomicSwapEther_Swap_default | Some(x) -> x end);
  } with ((nil: list(operation)));

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Open(match_action) -> open(self, match_action.swapID_, match_action.withdrawTrader_, match_action.secretLock_, match_action.timelock_)
  | Close(match_action) -> close(self, match_action.swapID_, match_action.secretKey_)
  | Expire(match_action) -> expire(self, match_action.swapID_)
  | Check(match_action) -> (check(self, match_action.receiver, match_action.swapID_), self)
  | CheckSecretKey(match_action) -> (checkSecretKey(self, match_action.receiver, match_action.swapID_), self)
  end);
