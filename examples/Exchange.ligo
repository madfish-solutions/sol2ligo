type assert_args is record
  assertion : bool;
end;

type safeMul_args is record
  a : nat;
  b : nat;
end;

type safeSub_args is record
  a : nat;
  b : nat;
end;

type safeAdd_args is record
  a : nat;
  b : nat;
end;

type setOwner_args is record
  newOwner : address;
end;

type getOwner_args is unit;
type constructor_args is record
  feeAccount_ : address;
end;

type invalidateOrdersBefore_args is record
  user : address;
  nonce : nat;
end;

type setInactivityReleasePeriod_args is record
  expiry : nat;
end;

type setAdmin_args is record
  admin : address;
  isAdmin : bool;
end;

type fallback_args is unit;
type depositToken_args is record
  token : address;
  res__amount : nat;
end;

type deposit_args is unit;
type withdraw_args is record
  token : address;
  res__amount : nat;
end;

type adminWithdraw_args is record
  token : address;
  res__amount : nat;
  user : address;
  nonce : nat;
  v : nat;
  r : bytes;
  s : bytes;
  feeWithdrawal : nat;
end;

type balanceOf_args is record
  receiver : contract(unit);
  token : address;
  user : address;
end;

type trade_args is record
  tradeValues : map(nat, nat);
  tradeAddresses : map(nat, address);
  v : map(nat, nat);
  rs : map(nat, bytes);
end;

type state is record
  owner : address;
  invalidOrder : map(address, nat);
  tokens : map(address, map(address, nat));
  admins : map(address, bool);
  lastActiveTransaction : map(address, nat);
  orderFills : map(bytes, nat);
  feeAccount : address;
  inactivityReleasePeriod : nat;
  traded : map(bytes, bool);
  withdrawn : map(bytes, bool);
end;
type state_Token is record
  standard : bytes;
  name : bytes;
  symbol : bytes;
  totalSupply : nat;
  decimals : nat;
  allowTransactions : bool;
  balanceOf : map(address, nat);
  allowance : map(address, map(address, nat));
end;

function transfer (const self : state_Token; const to_ : address; const value_ : nat) : (list(operation) * state_Token * bool) is
  block {
    const success : bool = False;
  } with ((nil: list(operation)), self, success);

function approveAndCall (const self : state_Token; const spender_ : address; const value_ : nat; const extraData_ : bytes) : (list(operation) * state_Token * bool) is
  block {
    const success : bool = False;
  } with ((nil: list(operation)), self, success);

function approve (const self : state_Token; const spender_ : address; const value_ : nat) : (list(operation) * state_Token * bool) is
  block {
    const success : bool = False;
  } with ((nil: list(operation)), self, success);

function transferFrom (const self : state_Token; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state_Token * bool) is
  block {
    const success : bool = False;
  } with ((nil: list(operation)), self, success);
type router_enum is
  | Assert of assert_args
  | SafeMul of safeMul_args
  | SafeSub of safeSub_args
  | SafeAdd of safeAdd_args
  | SetOwner of setOwner_args
  | GetOwner of getOwner_args
  | Constructor of constructor_args
  | InvalidateOrdersBefore of invalidateOrdersBefore_args
  | SetInactivityReleasePeriod of setInactivityReleasePeriod_args
  | SetAdmin of setAdmin_args
  | Fallback of fallback_args
  | DepositToken of depositToken_args
  | Deposit of deposit_args
  | Withdraw of withdraw_args
  | AdminWithdraw of adminWithdraw_args
  | BalanceOf of balanceOf_args
  | Trade of trade_args;

(* EventDefinition SetOwner(previousOwner : address; newOwner : address) *)

(* modifier onlyOwner inlined *)

(* modifier onlyAdmin inlined *)

(* EventDefinition Order(tokenBuy : address; amountBuy : nat; tokenSell : address; amountSell : nat; expires : nat; nonce : nat; user : address; v : nat; r : bytes; s : bytes) *)

(* EventDefinition Cancel(tokenBuy : address; amountBuy : nat; tokenSell : address; amountSell : nat; expires : nat; nonce : nat; user : address; v : nat; r : bytes; s : bytes) *)

(* EventDefinition Trade(tokenBuy : address; amountBuy : nat; tokenSell : address; amountSell : nat; get : address; give : address) *)

(* EventDefinition Deposit(token : address; user : address; res__amount : nat; res__balance : nat) *)

(* EventDefinition Withdraw(token : address; user : address; res__amount : nat; res__balance : nat) *)

function assert (const self : state; const assertion : bool) : (list(operation) * state) is
  block {
    if (not (assertion)) then block {
      failwith("throw");
    } else block {
      skip
    };
  } with ((nil: list(operation)), self);

function safeMul (const self : state; const a : nat; const b : nat) : (list(operation) * state) is
  block {
    const c : nat = (a * b);
    assert(((a = 0n) or ((c / a) = b)));
  } with ((nil: list(operation)), self);

function safeSub (const self : state; const a : nat; const b : nat) : (list(operation) * state) is
  block {
    assert((b <= a));
  } with ((nil: list(operation)), self);

function safeAdd (const self : state; const a : nat; const b : nat) : (list(operation) * state) is
  block {
    const c : nat = (a + b);
    assert(((c >= a) and (c >= b)));
  } with ((nil: list(operation)), self);

function setOwner (const self : state; const newOwner : address) : (list(operation) * state) is
  block {
    assert((sender = self.owner));
    (* EmitStatement SetOwner(owner, newOwner) *)
    self.owner := newOwner;
  } with ((nil: list(operation)), self);

function getOwner (const self : state) : (list(operation) * state) is
  block {
    const out : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
  } with ((nil: list(operation)), self);

function constructor (const self : state; const feeAccount_ : address) : (list(operation) * state) is
  block {
    self.owner := sender;
    self.feeAccount := feeAccount_;
    self.inactivityReleasePeriod := 100000n;
  } with ((nil: list(operation)), self);

function invalidateOrdersBefore (const self : state; const user : address; const nonce : nat) : (list(operation) * state) is
  block {
    if ((sender =/= self.owner) and not ((case self.admins[sender] of | None -> False | Some(x) -> x end))) then block {
      failwith("throw");
    } else block {
      skip
    };
    if (nonce < (case self.invalidOrder[user] of | None -> 0n | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.invalidOrder[user] := nonce;
  } with ((nil: list(operation)), self);

function setInactivityReleasePeriod (const self : state; const expiry : nat) : (list(operation) * state * bool) is
  block {
    if ((sender =/= self.owner) and not ((case self.admins[sender] of | None -> False | Some(x) -> x end))) then block {
      failwith("throw");
    } else block {
      skip
    };
    const success : bool = False;
    if (expiry > 1000000n) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.inactivityReleasePeriod := expiry;
  } with ((nil: list(operation)), self);

function setAdmin (const self : state; const admin : address; const isAdmin : bool) : (list(operation) * state) is
  block {
    assert((sender = self.owner));
    self.admins[admin] := isAdmin;
  } with ((nil: list(operation)), self);

function fallback (const self : state) : (list(operation) * state) is
  block {
    failwith("throw");
  } with ((nil: list(operation)), self);

function depositToken (const self : state; const token : address; const res__amount : nat) : (list(operation) * state) is
  block {
    (case self.tokens[token] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] := safeAdd(self, (case (case self.tokens[token] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end), res__amount);
    self.lastActiveTransaction[sender] := 0n;
    if (not ((* LIGO unsupported *)token(self, token).transferFrom(self, sender, , res__amount))) then block {
      failwith("throw");
    } else block {
      skip
    };
    (* EmitStatement Deposit(token, sender, amount, ) *)
  } with ((nil: list(operation)), self);

function deposit (const self : state) : (list(operation) * state) is
  block {
    (case self.tokens[("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] := safeAdd(self, (case (case self.tokens[("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end), (amount / 1mutez));
    self.lastActiveTransaction[sender] := 0n;
    (* EmitStatement Deposit(, sender, value, ) *)
  } with ((nil: list(operation)), self);

function withdraw (const self : state; const token : address; const res__amount : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    if (safeSub(self, 0n, (case self.lastActiveTransaction[sender] of | None -> 0n | Some(x) -> x end)) < self.inactivityReleasePeriod) then block {
      failwith("throw");
    } else block {
      skip
    };
    if ((case (case self.tokens[token] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end) < res__amount) then block {
      failwith("throw");
    } else block {
      skip
    };
    (case self.tokens[token] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] := safeSub(self, (case (case self.tokens[token] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end), res__amount);
    if (token = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) then block {
      if (not (var opList : list(operation) := list transaction(unit, res__amount * 1mutez, (get_contract(sender) : contract(unit))) end)) then block {
        failwith("throw");
      } else block {
        skip
      };
    } else block {
      if (not ((* LIGO unsupported *)token(self, token).transfer(self, sender, res__amount))) then block {
        failwith("throw");
      } else block {
        skip
      };
    };
    (* EmitStatement Withdraw(token, sender, amount, ) *)
  } with ((nil: list(operation)), self, success);

function adminWithdraw (const self : state; const token : address; const res__amount : nat; const user : address; const nonce : nat; const v : nat; const r : bytes; const s : bytes; const feeWithdrawal : nat) : (list(operation) * state * bool) is
  block {
    if ((sender =/= self.owner) and not ((case self.admins[sender] of | None -> False | Some(x) -> x end))) then block {
      failwith("throw");
    } else block {
      skip
    };
    const success : bool = False;
    const hash : bytes = sha_256();
    if ((case self.withdrawn[hash] of | None -> False | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.withdrawn[hash] := True;
    if (ecrecover(sha_256("\u0019Ethereum Signed Message:\n32"), v, r, s) =/= user) then block {
      failwith("throw");
    } else block {
      skip
    };
    if (feeWithdrawal > (50n * 1000n)) then block {
      feeWithdrawal := (50n * 1000n);
    } else block {
      skip
    };
    if ((case (case self.tokens[token] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[user] of | None -> 0n | Some(x) -> x end) < res__amount) then block {
      failwith("throw");
    } else block {
      skip
    };
    (case self.tokens[token] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[user] := safeSub(self, (case (case self.tokens[token] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[user] of | None -> 0n | Some(x) -> x end), res__amount);
    (case self.tokens[token] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[self.feeAccount] := safeAdd(self, (case (case self.tokens[token] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[self.feeAccount] of | None -> 0n | Some(x) -> x end), (safeMul(self, feeWithdrawal, res__amount) / (1 * 1000000)));
    res__amount := (safeMul(self, ((1 * 1000000) - feeWithdrawal), res__amount) / (1 * 1000000));
    if (token = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) then block {
      if (not (var opList : list(operation) := list transaction(unit, res__amount * 1mutez, (get_contract(user) : contract(unit))) end)) then block {
        failwith("throw");
      } else block {
        skip
      };
    } else block {
      if (not ((* LIGO unsupported *)token(self, token).transfer(self, user, res__amount))) then block {
        failwith("throw");
      } else block {
        skip
      };
    };
    self.lastActiveTransaction[user] := 0n;
    (* EmitStatement Withdraw(token, user, amount, ) *)
  } with ((nil: list(operation)), self);

function balanceOf (const self : state; const receiver : contract(unit); const token : address; const user : address) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function trade (const self : state; const tradeValues : map(nat, nat); const tradeAddresses : map(nat, address); const v : map(nat, nat); const rs : map(nat, bytes)) : (list(operation) * state * bool) is
  block {
    if ((sender =/= self.owner) and not ((case self.admins[sender] of | None -> False | Some(x) -> x end))) then block {
      failwith("throw");
    } else block {
      skip
    };
    const success : bool = False;
    if ((case self.invalidOrder[(case tradeAddresses[2n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> 0n | Some(x) -> x end) > (case tradeValues[3n] of | None -> 0n | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    const orderHash : bytes = sha_256();
    if (ecrecover(sha_256("\u0019Ethereum Signed Message:\n32"), (case v[0n] of | None -> 0n | Some(x) -> x end), (case rs[0n] of | None -> ("00": bytes) | Some(x) -> x end), (case rs[1n] of | None -> ("00": bytes) | Some(x) -> x end)) =/= (case tradeAddresses[2n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    const tradeHash : bytes = sha_256(orderHash);
    if (ecrecover(sha_256("\u0019Ethereum Signed Message:\n32"), (case v[1n] of | None -> 0n | Some(x) -> x end), (case rs[2n] of | None -> ("00": bytes) | Some(x) -> x end), (case rs[3n] of | None -> ("00": bytes) | Some(x) -> x end)) =/= (case tradeAddresses[3n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    if ((case self.traded[tradeHash] of | None -> False | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.traded[tradeHash] := True;
    if ((case tradeValues[6n] of | None -> 0n | Some(x) -> x end) > (100n * 1000n)) then block {
      tradeValues[6n] := (100n * 1000n);
    } else block {
      skip
    };
    if ((case tradeValues[7n] of | None -> 0n | Some(x) -> x end) > (100n * 1000n)) then block {
      tradeValues[7n] := (100n * 1000n);
    } else block {
      skip
    };
    if (safeAdd(self, (case self.orderFills[orderHash] of | None -> 0n | Some(x) -> x end), (case tradeValues[4n] of | None -> 0n | Some(x) -> x end)) > (case tradeValues[0n] of | None -> 0n | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    if ((case (case self.tokens[(case tradeAddresses[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[(case tradeAddresses[3n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> 0n | Some(x) -> x end) < (case tradeValues[4n] of | None -> 0n | Some(x) -> x end)) then block {
      failwith("throw");
    } else block {
      skip
    };
    if ((case (case self.tokens[(case tradeAddresses[1n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[(case tradeAddresses[2n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> 0n | Some(x) -> x end) < (safeMul(self, (case tradeValues[1n] of | None -> 0n | Some(x) -> x end), (case tradeValues[4n] of | None -> 0n | Some(x) -> x end)) / (case tradeValues[0n] of | None -> 0n | Some(x) -> x end))) then block {
      failwith("throw");
    } else block {
      skip
    };
    (case self.tokens[(case tradeAddresses[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[tradeAddresses[3n]] := safeSub(self, (case (case self.tokens[(case tradeAddresses[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[(case tradeAddresses[3n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> 0n | Some(x) -> x end), (case tradeValues[4n] of | None -> 0n | Some(x) -> x end));
    (case self.tokens[(case tradeAddresses[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[tradeAddresses[2n]] := safeAdd(self, (case (case self.tokens[(case tradeAddresses[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[(case tradeAddresses[2n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> 0n | Some(x) -> x end), (safeMul(self, (case tradeValues[4n] of | None -> 0n | Some(x) -> x end), ((1 * 1000000) - (case tradeValues[6n] of | None -> 0n | Some(x) -> x end))) / (1 * 1000000)));
    (case self.tokens[(case tradeAddresses[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[self.feeAccount] := safeAdd(self, (case (case self.tokens[(case tradeAddresses[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[self.feeAccount] of | None -> 0n | Some(x) -> x end), (safeMul(self, (case tradeValues[4n] of | None -> 0n | Some(x) -> x end), (case tradeValues[6n] of | None -> 0n | Some(x) -> x end)) / (1 * 1000000)));
    (case self.tokens[(case tradeAddresses[1n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[tradeAddresses[2n]] := safeSub(self, (case (case self.tokens[(case tradeAddresses[1n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[(case tradeAddresses[2n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> 0n | Some(x) -> x end), (safeMul(self, (case tradeValues[1n] of | None -> 0n | Some(x) -> x end), (case tradeValues[4n] of | None -> 0n | Some(x) -> x end)) / (case tradeValues[0n] of | None -> 0n | Some(x) -> x end)));
    (case self.tokens[(case tradeAddresses[1n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[tradeAddresses[3n]] := safeAdd(self, (case (case self.tokens[(case tradeAddresses[1n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[(case tradeAddresses[3n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> 0n | Some(x) -> x end), ((safeMul(self, safeMul(self, ((1 * 1000000) - (case tradeValues[7n] of | None -> 0n | Some(x) -> x end)), (case tradeValues[1n] of | None -> 0n | Some(x) -> x end)), (case tradeValues[4n] of | None -> 0n | Some(x) -> x end)) / (case tradeValues[0n] of | None -> 0n | Some(x) -> x end)) / (1 * 1000000)));
    (case self.tokens[(case tradeAddresses[1n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[self.feeAccount] := safeAdd(self, (case (case self.tokens[(case tradeAddresses[1n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[self.feeAccount] of | None -> 0n | Some(x) -> x end), ((safeMul(self, safeMul(self, (case tradeValues[7n] of | None -> 0n | Some(x) -> x end), (case tradeValues[1n] of | None -> 0n | Some(x) -> x end)), (case tradeValues[4n] of | None -> 0n | Some(x) -> x end)) / (case tradeValues[0n] of | None -> 0n | Some(x) -> x end)) / (1 * 1000000)));
    self.orderFills[orderHash] := safeAdd(self, (case self.orderFills[orderHash] of | None -> 0n | Some(x) -> x end), (case tradeValues[4n] of | None -> 0n | Some(x) -> x end));
    self.lastActiveTransaction[tradeAddresses[2n]] := 0n;
    self.lastActiveTransaction[tradeAddresses[3n]] := 0n;
  } with ((nil: list(operation)), self);

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Assert(match_action) -> assert(match_action.assertion)
  | SafeMul(match_action) -> safeMul(self, match_action.a, match_action.b)
  | SafeSub(match_action) -> safeSub(self, match_action.a, match_action.b)
  | SafeAdd(match_action) -> safeAdd(self, match_action.a, match_action.b)
  | SetOwner(match_action) -> setOwner(self, match_action.newOwner)
  | GetOwner(match_action) -> getOwner(self)
  | Constructor(match_action) -> constructor(self, match_action.feeAccount_)
  | InvalidateOrdersBefore(match_action) -> invalidateOrdersBefore(self, match_action.user, match_action.nonce)
  | SetInactivityReleasePeriod(match_action) -> setInactivityReleasePeriod(self, match_action.expiry)
  | SetAdmin(match_action) -> setAdmin(self, match_action.admin, match_action.isAdmin)
  | Fallback(match_action) -> fallback(self)
  | DepositToken(match_action) -> depositToken(self, match_action.token, match_action.res__amount)
  | Deposit(match_action) -> deposit(self)
  | Withdraw(match_action) -> 
  | AdminWithdraw(match_action) -> adminWithdraw(self, match_action.token, match_action.res__amount, match_action.user, match_action.nonce, match_action.v, match_action.r, match_action.s, match_action.feeWithdrawal)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.receiver, match_action.token, match_action.user), self)
  | Trade(match_action) -> trade(self, match_action.tradeValues, match_action.tradeAddresses, match_action.v, match_action.rs)
  end);
