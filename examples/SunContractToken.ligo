Field_access {
  t:
   Var {
     name: [32m'spender'[39m,
     line: [33m0[39m,
     left_unpack: [33mfalse[39m,
     pos: [33m0[39m,
     type:
      Type { nest_list: [], field_hash: {}, main: [32m'tokenRecipient'[39m } },
  name: [32m'receiveApproval'[39m,
  line: [33m0[39m,
  pos: [33m0[39m }
Type { nest_list: [], field_hash: {}, main: [32m'tokenRecipient'[39m }
type receiveApproval_args is record
  from_ : address;
  value_ : nat;
  token_ : address;
  extraData_ : bytes;
end;

type allowance_args is record
  owner_ : address;
  spender_ : address;
end;

type approve_args is record
  spender_ : address;
  value_ : nat;
end;

type transferFrom_args is record
  from_ : address;
  to_ : address;
  value_ : nat;
end;

type transfer_args is record
  to_ : address;
  value_ : nat;
end;

type balanceOf_args is record
  owner_ : address;
end;

type totalSupply_args is unit;
type transferOwnership_args is record
  newOwner : address;
end;

type constructor_args is record
  icoAddress_ : address;
end;

type totalSupply_args is unit;
type balanceOf_args is record
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
  querryAddress_ : address;
end;

type receiveApproval_args is record
  from_ : address;
  value_ : nat;
  token_ : address;
  extraData_ : bytes;
end;

type allowance_args is record
  owner_ : address;
  spender_ : address;
end;

type approve_args is record
  spender_ : address;
  value_ : nat;
end;

type transferFrom_args is record
  from_ : address;
  to_ : address;
  value_ : nat;
end;

type transfer_args is record
  to_ : address;
  value_ : nat;
end;

type balanceOf_args is record
  owner_ : address;
end;

type totalSupply_args is unit;
type transferOwnership_args is record
  newOwner : address;
end;

type constructor_args is record
  icoAddress_ : address;
end;

type totalSupply_args is unit;
type balanceOf_args is record
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

type router_enum is
  | ReceiveApproval of receiveApproval_args
  | Allowance of allowance_args
  | Approve of approve_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | BalanceOf of balanceOf_args
  | TotalSupply of totalSupply_args
  | TransferOwnership of transferOwnership_args
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

function receiveApproval (const self : state; const from_ : address; const value_ : nat; const token_ : address; const extraData_ : bytes) : (list(operation) * state) is
  block {
    skip
  } with ((nil: list(operation)), self);

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | ReceiveApproval(match_action) -> receiveApproval(self, match_action.from_, match_action.value_, match_action.token_, match_action.extraData_)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | TransferOwnership(match_action) -> transferOwnership(self, match_action.newOwner)
  | Constructor(match_action) -> constructor(self, match_action.icoAddress_)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | ApproveAndCall(match_action) -> approveAndCall(self, match_action.spender_, match_action.value_, match_action.extraData_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | MintTokens(match_action) -> mintTokens(self, match_action.to_, match_action.amount_)
  | BurnTokens(match_action) -> burnTokens(self, match_action.amount_)
  | FreezeTransfersUntil(match_action) -> freezeTransfersUntil(self, match_action.frozenUntilBlock_, match_action.reason_)
  | IsRestrictedAddress(match_action) -> (isRestrictedAddress(self, match_action.querryAddress_), self)
  end);
type router_enum is
  | ReceiveApproval of receiveApproval_args
  | Allowance of allowance_args
  | Approve of approve_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | BalanceOf of balanceOf_args
  | TotalSupply of totalSupply_args
  | TransferOwnership of transferOwnership_args
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

function allowance (const self : state; const owner_ : address; const spender_ : address) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function approve (const self : state; const spender_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
  } with ((nil: list(operation)), self, success);

function transferFrom (const self : state; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
  } with ((nil: list(operation)), self, success);

function transfer (const self : state; const to_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
  } with ((nil: list(operation)), self, success);

function balanceOf (const self : state; const owner_ : address) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function totalSupply (const self : state) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function transferOwnership (const self : state; const newOwner : address) : (list(operation) * state) is
  block {
    if (sender =/= self.owner) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.owner := newOwner;
  } with ((nil: list(operation)), self);

function owned_constructor (const self : state) : (list(operation) * state) is
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

function totalSupply (const self : state) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function balanceOf (const self : state; const owner_ : address) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

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
  } with ((nil: list(operation)), self);

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
  } with ((nil: list(operation)), self);

function approveAndCall (const self : state; const spender_ : address; const value_ : nat; const extraData_ : bytes) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    const spender : UNKNOWN_TYPE_tokenRecipient = (* address contract to type_cast is not supported yet (we need enum action type for each contract) *);
    approve(self, spender_, value_);
    spender.receiveApproval(self, sender, value_, , extraData_);
  } with ((nil: list(operation)), self);

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
  } with ((nil: list(operation)), self);

function allowance (const self : state; const owner_ : address; const spender_ : address) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

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

function isRestrictedAddress (const self : state; const querryAddress_ : address) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | ReceiveApproval(match_action) -> receiveApproval(self, match_action.from_, match_action.value_, match_action.token_, match_action.extraData_)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | TransferOwnership(match_action) -> transferOwnership(self, match_action.newOwner)
  | Constructor(match_action) -> constructor(self, match_action.icoAddress_)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | ApproveAndCall(match_action) -> approveAndCall(self, match_action.spender_, match_action.value_, match_action.extraData_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | MintTokens(match_action) -> mintTokens(self, match_action.to_, match_action.amount_)
  | BurnTokens(match_action) -> burnTokens(self, match_action.amount_)
  | FreezeTransfersUntil(match_action) -> freezeTransfersUntil(self, match_action.frozenUntilBlock_, match_action.reason_)
  | IsRestrictedAddress(match_action) -> (isRestrictedAddress(self, match_action.querryAddress_), self)
  end);
