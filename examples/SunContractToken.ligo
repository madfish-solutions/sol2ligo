type constructor_args is record
  icoAddress_ : address;
end;

type totalSupply_args is record
  receiver : contract(nat);
end;

type balanceOf_args is record
  receiver : contract(nat);
  owner_ : address;
end;

type transfer_args is record
  to_ : address;
  value_ : nat;
end;

type approve_args is record
  spender_ : address;
  value_ : nat;
end;

type approveAndCall_args is record
  spender_ : address;
  value_ : nat;
  extraData_ : bytes;
end;

type transferFrom_args is record
  from_ : address;
  to_ : address;
  value_ : nat;
end;

type allowance_args is record
  receiver : contract(nat);
  owner_ : address;
  spender_ : address;
end;

type mintTokens_args is record
  to_ : address;
  amount_ : nat;
end;

type burnTokens_args is record
  amount_ : nat;
end;

type freezeTransfersUntil_args is record
  frozenUntilBlock_ : nat;
  reason_ : string;
end;

type isRestrictedAddress_args is record
  receiver : contract(bool);
  querryAddress_ : address;
end;

type state is record
  owner : address;
  standard : string;
  name : string;
  symbol : string;
  decimals : nat;
  icoContractAddress : address;
  tokenFrozenUntilBlock : nat;
  supply : nat;
  balances : map(address, nat);
  allowances : map(address, map(address, nat));
  restrictedAddresses : map(address, bool);
end;
type state_tokenRecipient is unit;

function receiveApproval (const self : state_tokenRecipient; const from_ : address; const value_ : nat; const token_ : address; const extraData_ : bytes) : (list(operation) * state_tokenRecipient) is
  block {
    skip
  } with ((nil: list(operation)), self);
type router_enum is
  | Constructor of constructor_args
  | TotalSupply of totalSupply_args
  | BalanceOf of balanceOf_args
  | Transfer of transfer_args
  | Approve of approve_args
  | ApproveAndCall of approveAndCall_args
  | TransferFrom of transferFrom_args
  | Allowance of allowance_args
  | MintTokens of mintTokens_args
  | BurnTokens of burnTokens_args
  | FreezeTransfersUntil of freezeTransfersUntil_args
  | IsRestrictedAddress of isRestrictedAddress_args;

(* EventDefinition Mint(to_ : address; value_ : nat) *)

(* EventDefinition Burn(from_ : address; value_ : nat) *)

(* EventDefinition TokenFrozen(frozenUntilBlock_ : nat; reason_ : string) *)

function allowance (const self : state_IERC20Token; const receiver : contract(nat); const owner_ : address; const spender_ : address) : (list(operation)) is
  block {
    const remaining : nat = 0n;
    var opList : list(operation) := list transaction((remaining), 0mutez, receiver) end;
  } with (opList);

function approve (const self : state_IERC20Token; const spender_ : address; const value_ : nat) : (list(operation) * state_IERC20Token * bool) is
  block {
    const success : bool = False;
  } with (opList, self, success);

function transferFrom (const self : state_IERC20Token; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state_IERC20Token * bool) is
  block {
    const success : bool = False;
  } with ((nil: list(operation)), self, success);

function transfer (const self : state_IERC20Token; const to_ : address; const value_ : nat) : (list(operation) * state_IERC20Token * bool) is
  block {
    const success : bool = False;
  } with ((nil: list(operation)), self, success);

function balanceOf (const self : state_IERC20Token; const receiver : contract(nat); const owner_ : address) : (list(operation)) is
  block {
    const res__balance : nat = 0n;
    var opList : list(operation) := list transaction((res__balance), 0mutez, receiver) end;
  } with (opList);

function totalSupply (const self : state_IERC20Token; const receiver : contract(nat)) : (list(operation)) is
  block {
    const totalSupply : nat = 0n;
    var opList : list(operation) := list transaction((self.totalSupply), 0mutez, receiver) end;
  } with (opList);

function transferOwnership (const self : state_owned; const newOwner : address) : (list(operation) * state_owned) is
  block {
    if (sender =/= self.owner) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.owner := newOwner;
  } with ((nil: list(operation)), self);

function owned_constructor (const self : state_owned) : (list(operation) * state_owned) is
  block {
    self.owner := sender;
  } with ((nil: list(operation)), self);

function constructor (const self : state; const icoAddress_ : address) : (list(operation) * state) is
  block {
    owned_constructor(self);
    self.restrictedAddresses[0x0] := True;
    self.restrictedAddresses[icoAddress_] := True;
    self.restrictedAddresses[self_address] := True;
    self.icoContractAddress := icoAddress_;
  } with ((nil: list(operation)), self);

function totalSupply (const self : state; const receiver : contract(nat)) : (list(operation)) is
  block {
    const totalSupply : nat = 0n;
    var opList : list(operation) := list transaction((self.supply), 0mutez, receiver) end;
  } with (opList);

function balanceOf (const self : state; const receiver : contract(nat); const owner_ : address) : (list(operation)) is
  block {
    const res__balance : nat = 0n;
    var opList : list(operation) := list transaction(((case self.balances[owner_] of | None -> 0n | Some(x) -> x end)), 0mutez, receiver) end;
  } with (opList);

function transfer (const self : state; const to_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    if (0n < self.tokenFrozenUntilBlock) then block {
      failwith("throw");
    } else block {
      skip
    };
    if ((case self.restrictedAddresses[to_] of | None -> False | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    if ((case self.balances[sender] of | None -> 0n | Some(x) -> x end) < value_) then block {
      failwith("throw");
    } else block {
      skip
    };
    if (((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + value_) < (case self.balances[to_] of | None -> 0n | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.balances[sender] := abs((case self.balances[sender] of | None -> 0n | Some(x) -> x end) - value_);
    self.balances[to_] := ((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + value_);
    (* EmitStatement Transfer(sender, _to, _value) *)
  } with (opList, self, True);

function approve (const self : state; const spender_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    if (0n < self.tokenFrozenUntilBlock) then block {
      failwith("throw");
    } else block {
      skip
    };
    (case self.allowances[sender] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[spender_] := value_;
    (* EmitStatement Approval(sender, _spender, _value) *)
  } with (opList, self, True);

function approveAndCall (const self : state; const spender_ : address; const value_ : nat; const extraData_ : bytes) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    const spender : UNKNOWN_TYPE_tokenRecipient = (* LIGO unsupported *)tokenRecipient(self, spender_);
    approve(self, spender_, value_);
    spender.receiveApproval(self, sender, value_, , extraData_);
  } with ((nil: list(operation)), self, True);

function transferFrom (const self : state; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    if (0n < self.tokenFrozenUntilBlock) then block {
      failwith("throw");
    } else block {
      skip
    };
    if ((case self.restrictedAddresses[to_] of | None -> False | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    if ((case self.balances[from_] of | None -> 0n | Some(x) -> x end) < value_) then block {
      failwith("throw");
    } else block {
      skip
    };
    if (((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + value_) < (case self.balances[to_] of | None -> 0n | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    if (value_ > (case (case self.allowances[from_] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.balances[from_] := abs((case self.balances[from_] of | None -> 0n | Some(x) -> x end) - value_);
    self.balances[to_] := ((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + value_);
    (case self.allowances[from_] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] := abs((case (case self.allowances[from_] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end) - value_);
    (* EmitStatement Transfer(_from, _to, _value) *)
  } with (opList, self, True);

function allowance (const self : state; const receiver : contract(nat); const owner_ : address; const spender_ : address) : (list(operation)) is
  block {
    const remaining : nat = 0n;
    var opList : list(operation) := list transaction(((case (case self.allowances[owner_] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[spender_] of | None -> 0n | Some(x) -> x end)), 0mutez, receiver) end;
  } with (opList);

function mintTokens (const self : state; const to_ : address; const amount_ : nat) : (list(operation) * state) is
  block {
    if (sender =/= self.icoContractAddress) then block {
      failwith("throw");
    } else block {
      skip
    };
    if ((case self.restrictedAddresses[to_] of | None -> False | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    if (((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + amount_) < (case self.balances[to_] of | None -> 0n | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.supply := (self.supply + amount_);
    self.balances[to_] := ((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + amount_);
    (* EmitStatement Mint(_to, _amount) *)
    (* EmitStatement Transfer(, _to, _amount) *)
  } with ((nil: list(operation)), self);

function burnTokens (const self : state; const amount_ : nat) : (list(operation) * state) is
  block {
    if (sender =/= self.owner) then block {
      failwith("throw");
    } else block {
      skip
    };
    if ((case self.balances[sender] of | None -> 0n | Some(x) -> x end) < amount_) then block {
      failwith("throw");
    } else block {
      skip
    };
    if (self.supply < amount_) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.supply := abs(self.supply - amount_);
    self.balances[sender] := abs((case self.balances[sender] of | None -> 0n | Some(x) -> x end) - amount_);
    (* EmitStatement Burn(sender, _amount) *)
    (* EmitStatement Transfer(sender, , _amount) *)
  } with ((nil: list(operation)), self);

function freezeTransfersUntil (const self : state; const frozenUntilBlock_ : nat; const reason_ : string) : (list(operation) * state) is
  block {
    if (sender =/= self.owner) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.tokenFrozenUntilBlock := frozenUntilBlock_;
    (* EmitStatement TokenFrozen(_frozenUntilBlock, _reason) *)
  } with ((nil: list(operation)), self);

function isRestrictedAddress (const self : state; const receiver : contract(bool); const querryAddress_ : address) : (list(operation)) is
  block {
    const answer : bool = False;
    var opList : list(operation) := list transaction(((case self.restrictedAddresses[querryAddress_] of | None -> False | Some(x) -> x end)), 0mutez, receiver) end;
  } with (opList);

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Constructor(match_action) -> constructor(self, match_action.icoAddress_)
  | TotalSupply(match_action) -> (totalSupply(self, match_action.receiver), self)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.receiver, match_action.owner_), self)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | ApproveAndCall(match_action) -> approveAndCall(self, match_action.spender_, match_action.value_, match_action.extraData_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Allowance(match_action) -> (allowance(self, match_action.receiver, match_action.owner_, match_action.spender_), self)
  | MintTokens(match_action) -> mintTokens(self, match_action.to_, match_action.amount_)
  | BurnTokens(match_action) -> burnTokens(self, match_action.amount_)
  | FreezeTransfersUntil(match_action) -> freezeTransfersUntil(self, match_action.frozenUntilBlock_, match_action.reason_)
  | IsRestrictedAddress(match_action) -> (isRestrictedAddress(self, match_action.receiver, match_action.querryAddress_), self)
  end);
