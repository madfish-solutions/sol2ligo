type centWallet_Wallet is record
  res__balance : nat;
  linked : map(address, bool);
  debitNonce : nat;
  withdrawNonce : nat;
end;

type constructor_args is unit;
type deposit_args is record
  walletID : bytes;
end;

type getLinkDigest_args is record
  walletID : bytes;
  agent : address;
  callbackAddress : address;
end;

type getWalletDigest_args is record
  name : bytes;
  root : address;
  callbackAddress : address;
end;

type getMessageSigner_args is record
  message : bytes;
  v : nat;
  r : bytes;
  s : bytes;
  callbackAddress : address;
end;

type link_args is record
  walletIDs : map(nat, bytes);
  nameIDs : map(nat, bytes);
  agents : map(nat, address);
  v : map(nat, nat);
  r : map(nat, bytes);
  s : map(nat, bytes);
end;

type getDebitDigest_args is record
  walletID : bytes;
  value : nat;
  nonce : nat;
  callbackAddress : address;
end;

type debit_args is record
  walletIDs : map(nat, bytes);
  values : map(nat, nat);
  nonces : map(nat, nat);
  v : map(nat, nat);
  r : map(nat, bytes);
  s : map(nat, bytes);
end;

type getWithdrawDigest_args is record
  walletID : bytes;
  recipient : address;
  value : nat;
  nonce : nat;
  callbackAddress : address;
end;

type withdraw_args is record
  walletIDs : map(nat, bytes);
  recipients : map(nat, address);
  values : map(nat, nat);
  nonces : map(nat, nat);
  v : map(nat, nat);
  r : map(nat, bytes);
  s : map(nat, bytes);
end;

type settle_args is record
  walletIDs : map(nat, bytes);
  requestIDs : map(nat, nat);
  values : map(nat, nat);
end;

type getNameDigest_args is record
  name : string;
  callbackAddress : address;
end;

type getDebitNonce_args is record
  walletID : bytes;
end;

type getWithdrawNonce_args is record
  walletID : bytes;
end;

type getLinkStatus_args is record
  walletID : bytes;
  member : address;
end;

type getBalance_args is record
  walletID : bytes;
end;

type getEscrowBalance_args is unit;
type addAdmin_args is record
  newAdmin : address;
end;

type removeAdmin_args is record
  oldAdmin : address;
end;

type changeRootAdmin_args is record
  newRootAdmin : address;
end;

type state is record
  admins : map(nat, address);
  wallets : map(bytes, centWallet_Wallet);
  isAdmin : map(address, bool);
  escrowBalance : nat;
end;

const centWallet_Wallet_default : centWallet_Wallet = record [ balance = 0n;
	linked = (map end : map(address, bool));
	debitNonce = 0n;
	withdrawNonce = 0n ];

type router_enum is
  | Constructor of constructor_args
  | Deposit of deposit_args
  | GetLinkDigest of getLinkDigest_args
  | GetWalletDigest of getWalletDigest_args
  | GetMessageSigner of getMessageSigner_args
  | Link of link_args
  | GetDebitDigest of getDebitDigest_args
  | Debit of debit_args
  | GetWithdrawDigest of getWithdrawDigest_args
  | Withdraw of withdraw_args
  | Settle of settle_args
  | GetNameDigest of getNameDigest_args
  | GetDebitNonce of getDebitNonce_args
  | GetWithdrawNonce of getWithdrawNonce_args
  | GetLinkStatus of getLinkStatus_args
  | GetBalance of getBalance_args
  | GetEscrowBalance of getEscrowBalance_args
  | AddAdmin of addAdmin_args
  | RemoveAdmin of removeAdmin_args
  | ChangeRootAdmin of changeRootAdmin_args;

(* modifier onlyAdmin inlined *)

(* modifier onlyRootAdmin inlined *)

(* EventDefinition Deposit(walletID : bytes; res__sender : address; value : nat) *)

(* EventDefinition Link(walletID : bytes; agent : address) *)

(* EventDefinition Debit(walletID : bytes; nonce : nat; value : nat) *)

(* EventDefinition Settle(walletID : bytes; requestID : nat; value : nat) *)

(* EventDefinition Withdraw(walletID : bytes; nonce : nat; value : nat; recipient : address) *)

function constructor (const self : state) : (list(operation) * state) is
  block {
    const tmp_0 : map(nat, address) = self.admins;
    tmp_0[size(tmp_0)] := sender;
    self.isAdmin[sender] := True;
  } with ((nil: list(operation)), self);

function deposit (const self : state; const walletID : bytes) : (list(operation) * state) is
  block {
    self.wallets[walletID].res__balance := ((case self.wallets[walletID] of | None -> centWallet_Wallet_default | Some(x) -> x end).res__balance + (amount / 1mutez));
    (* EmitStatement undefined(walletID, , ) *)
  } with ((nil: list(operation)), self);

function getLinkDigest (const walletID : bytes; const agent : address) : (list(operation) * bytes) is
  block {
    skip
  } with ((nil: list(operation)), sha_256((walletID, agent)));

function getWalletDigest (const name : bytes; const root : address) : (list(operation) * bytes) is
  block {
    skip
  } with ((nil: list(operation)), sha_256((name, root)));

function getMessageSigner (const message : bytes; const v : nat; const r : bytes; const s : bytes) : (list(operation) * address) is
  block {
    const prefix : bytes = 0x2569116104101114101117109328310510311010110032771011151159710310158105150;
    const prefixedMessage : bytes = sha_256((prefix, message));
  } with ((nil: list(operation)), ecrecover(prefixedMessage, v, r, s));

function link (const self : state; const walletIDs : map(nat, bytes); const nameIDs : map(nat, bytes); const agents : map(nat, address); const v : map(nat, nat); const r : map(nat, bytes); const s : map(nat, bytes)) : (list(operation) * state) is
  block {
    assert((case self.isAdmin[sender] of | None -> False | Some(x) -> x end));
    assert((((((size(walletIDs) = size(nameIDs)) and (size(walletIDs) = size(agents))) and (size(walletIDs) = size(v))) and (size(walletIDs) = size(r))) and (size(walletIDs) = size(s))));
    const i : nat = 0n;
    while (i < size(walletIDs)) block {
      const walletID : bytes = (case walletIDs[i] of | None -> ("00": bytes) | Some(x) -> x end);
      const agent : address = (case agents[i] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end);
      const signer : address = getMessageSigner(getLinkDigest(walletID, agent), (case v[i] of | None -> 0n | Some(x) -> x end), (case r[i] of | None -> ("00": bytes) | Some(x) -> x end), (case s[i] of | None -> ("00": bytes) | Some(x) -> x end));
      const wallet : centWallet_Wallet = (case self.wallets[walletID] of | None -> centWallet_Wallet_default | Some(x) -> x end);
      if ((case wallet.linked[signer] of | None -> False | Some(x) -> x end) or (walletID = getWalletDigest((case nameIDs[i] of | None -> ("00": bytes) | Some(x) -> x end), signer))) then block {
        wallet.linked[agent] := True;
        (* EmitStatement undefined(walletID, agent) *)
      } else block {
        skip
      };
      i := i + 1;
    };
  } with ((nil: list(operation)), self);

function getDebitDigest (const walletID : bytes; const value : nat; const nonce : nat) : (list(operation) * bytes) is
  block {
    skip
  } with ((nil: list(operation)), sha_256((walletID, value, nonce)));

function debit (const self : state; const walletIDs : map(nat, bytes); const values : map(nat, nat); const nonces : map(nat, nat); const v : map(nat, nat); const r : map(nat, bytes); const s : map(nat, bytes)) : (list(operation) * state) is
  block {
    assert((case self.isAdmin[sender] of | None -> False | Some(x) -> x end));
    assert((((((size(walletIDs) = size(values)) and (size(walletIDs) = size(nonces))) and (size(walletIDs) = size(v))) and (size(walletIDs) = size(r))) and (size(walletIDs) = size(s))));
    const additionalEscrow : nat = 0n;
    const i : nat = 0n;
    while (i < size(walletIDs)) block {
      const walletID : bytes = (case walletIDs[i] of | None -> ("00": bytes) | Some(x) -> x end);
      const value : nat = (case values[i] of | None -> 0n | Some(x) -> x end);
      const nonce : nat = (case nonces[i] of | None -> 0n | Some(x) -> x end);
      const signer : address = getMessageSigner(getDebitDigest(walletID, value, nonce), (case v[i] of | None -> 0n | Some(x) -> x end), (case r[i] of | None -> ("00": bytes) | Some(x) -> x end), (case s[i] of | None -> ("00": bytes) | Some(x) -> x end));
      const wallet : centWallet_Wallet = (case self.wallets[walletID] of | None -> centWallet_Wallet_default | Some(x) -> x end);
      if (((wallet.debitNonce < nonce) and (wallet.res__balance >= value)) and (case wallet.linked[signer] of | None -> False | Some(x) -> x end)) then block {
        wallet.debitNonce := nonce;
        wallet.res__balance := abs(wallet.res__balance - value);
        (* EmitStatement undefined(walletID, nonce, value) *)
        additionalEscrow := (additionalEscrow + value);
      } else block {
        skip
      };
      i := i + 1;
    };
    self.escrowBalance := (self.escrowBalance + additionalEscrow);
  } with ((nil: list(operation)), self);

function getWithdrawDigest (const walletID : bytes; const recipient : address; const value : nat; const nonce : nat) : (list(operation) * bytes) is
  block {
    skip
  } with ((nil: list(operation)), sha_256((walletID, recipient, value, nonce)));

function withdraw (const self : state; const walletIDs : map(nat, bytes); const recipients : map(nat, address); const values : map(nat, nat); const nonces : map(nat, nat); const v : map(nat, nat); const r : map(nat, bytes); const s : map(nat, bytes)) : (list(operation) * state) is
  block {
    assert((case self.isAdmin[sender] of | None -> False | Some(x) -> x end));
    assert(((((((size(walletIDs) = size(recipients)) and (size(walletIDs) = size(values))) and (size(walletIDs) = size(nonces))) and (size(walletIDs) = size(v))) and (size(walletIDs) = size(r))) and (size(walletIDs) = size(s))));
    const i : nat = 0n;
    while (i < size(walletIDs)) block {
      const walletID : bytes = (case walletIDs[i] of | None -> ("00": bytes) | Some(x) -> x end);
      const recipient : address = (case recipients[i] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end);
      const value : nat = (case values[i] of | None -> 0n | Some(x) -> x end);
      const nonce : nat = (case nonces[i] of | None -> 0n | Some(x) -> x end);
      const signer : address = getMessageSigner(getWithdrawDigest(walletID, recipient, value, nonce), (case v[i] of | None -> 0n | Some(x) -> x end), (case r[i] of | None -> ("00": bytes) | Some(x) -> x end), (case s[i] of | None -> ("00": bytes) | Some(x) -> x end));
      const wallet : centWallet_Wallet = (case self.wallets[walletID] of | None -> centWallet_Wallet_default | Some(x) -> x end);
      if ((((wallet.withdrawNonce < nonce) and (wallet.res__balance >= value)) and (case wallet.linked[signer] of | None -> False | Some(x) -> x end)) and var opList : list(operation) := list transaction(unit, value * 1mutez, (get_contract(recipient) : contract(unit))) end) then block {
        wallet.withdrawNonce := nonce;
        wallet.res__balance := abs(wallet.res__balance - value);
        (* EmitStatement undefined(walletID, nonce, value, recipient) *)
      } else block {
        skip
      };
      i := i + 1;
    };
  } with ((nil: list(operation)), self);

function settle (const self : state; const walletIDs : map(nat, bytes); const requestIDs : map(nat, nat); const values : map(nat, nat)) : (list(operation) * state) is
  block {
    assert((case self.isAdmin[sender] of | None -> False | Some(x) -> x end));
    assert(((size(walletIDs) = size(requestIDs)) and (size(walletIDs) = size(values))));
    const remainingEscrow : nat = self.escrowBalance;
    const i : nat = 0n;
    while (i < size(walletIDs)) block {
      const walletID : bytes = (case walletIDs[i] of | None -> ("00": bytes) | Some(x) -> x end);
      const value : nat = (case values[i] of | None -> 0n | Some(x) -> x end);
      assert((value <= remainingEscrow));
      self.wallets[walletID].res__balance := ((case self.wallets[walletID] of | None -> centWallet_Wallet_default | Some(x) -> x end).res__balance + value);
      remainingEscrow := abs(remainingEscrow - value);
      (* EmitStatement undefined(walletID, , value) *)
      i := i + 1;
    };
    self.escrowBalance := remainingEscrow;
  } with ((nil: list(operation)), self);

function getNameDigest (const name : string) : (list(operation) * bytes) is
  block {
    skip
  } with ((nil: list(operation)), sha_256((name)));

function getDebitNonce (const self : state; const walletID : bytes) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function getWithdrawNonce (const self : state; const walletID : bytes) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function getLinkStatus (const self : state; const walletID : bytes; const member : address) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function getBalance (const self : state; const walletID : bytes) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function getEscrowBalance (const self : state) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function addAdmin (const self : state; const newAdmin : address) : (list(operation) * state) is
  block {
    assert((sender = (case self.admins[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)));
    assert(not ((case self.isAdmin[newAdmin] of | None -> False | Some(x) -> x end)));
    self.isAdmin[newAdmin] := True;
    const tmp_0 : map(nat, address) = self.admins;
    tmp_0[size(tmp_0)] := newAdmin;
  } with ((nil: list(operation)), self);

function removeAdmin (const self : state; const oldAdmin : address) : (list(operation) * state) is
  block {
    assert((sender = (case self.admins[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)));
    assert(((case self.isAdmin[oldAdmin] of | None -> False | Some(x) -> x end) and ((case self.admins[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end) =/= oldAdmin)));
    const found : bool = False;
    const i : nat = 1n;
    while (i < (size(self.admins) - 1n)) block {
      if (not (found) and ((case self.admins[i] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end) = oldAdmin)) then block {
        found := True;
      } else block {
        skip
      };
      if (found) then block {
        self.admins[i] := (case self.admins[(i + 1n)] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end);
      } else block {
        skip
      };
      i := i + 1;
    };
    size(self.admins) := size(self.admins) - 1;
    self.isAdmin[oldAdmin] := False;
  } with ((nil: list(operation)), self);

function changeRootAdmin (const self : state; const newRootAdmin : address) : (list(operation) * state) is
  block {
    assert((sender = (case self.admins[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)));
    if ((case self.isAdmin[newRootAdmin] of | None -> False | Some(x) -> x end) and ((case self.admins[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end) =/= newRootAdmin)) then block {
      removeAdmin(self, newRootAdmin);
    } else block {
      skip
    };
    self.admins[0n] := newRootAdmin;
    self.isAdmin[newRootAdmin] := True;
  } with ((nil: list(operation)), self);

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Constructor(match_action) -> constructor(self)
  | Deposit(match_action) -> deposit(self, match_action.walletID)
  | GetLinkDigest(match_action) -> (getLinkDigest(match_action.walletID, match_action.agent), self)
  | GetWalletDigest(match_action) -> (getWalletDigest(match_action.name, match_action.root), self)
  | GetMessageSigner(match_action) -> (getMessageSigner(match_action.message, match_action.v, match_action.r, match_action.s), self)
  | Link(match_action) -> link(self, match_action.walletIDs, match_action.nameIDs, match_action.agents, match_action.v, match_action.r, match_action.s)
  | GetDebitDigest(match_action) -> (getDebitDigest(match_action.walletID, match_action.value, match_action.nonce), self)
  | Debit(match_action) -> debit(self, match_action.walletIDs, match_action.values, match_action.nonces, match_action.v, match_action.r, match_action.s)
  | GetWithdrawDigest(match_action) -> (getWithdrawDigest(match_action.walletID, match_action.recipient, match_action.value, match_action.nonce), self)
  | Withdraw(match_action) -> 
  | Settle(match_action) -> settle(self, match_action.walletIDs, match_action.requestIDs, match_action.values)
  | GetNameDigest(match_action) -> (getNameDigest(match_action.name), self)
  | GetDebitNonce(match_action) -> (getDebitNonce(self, match_action.walletID), self)
  | GetWithdrawNonce(match_action) -> (getWithdrawNonce(self, match_action.walletID), self)
  | GetLinkStatus(match_action) -> (getLinkStatus(self, match_action.walletID, match_action.member), self)
  | GetBalance(match_action) -> (getBalance(self, match_action.walletID), self)
  | GetEscrowBalance(match_action) -> (getEscrowBalance(self), self)
  | AddAdmin(match_action) -> addAdmin(self, match_action.newAdmin)
  | RemoveAdmin(match_action) -> removeAdmin(self, match_action.oldAdmin)
  | ChangeRootAdmin(match_action) -> changeRootAdmin(self, match_action.newRootAdmin)
  end);
