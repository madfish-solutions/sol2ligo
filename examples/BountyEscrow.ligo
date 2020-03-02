type constructor_args is unit;
type fallback_args is unit;
type payout_args is record
  ids : map(nat, nat);
  recipients : map(nat, address);
  amounts : map(nat, nat);
end;

type deauthorize_args is record
  agent : address;
end;

type authorize_args is record
  agent : address;
end;

type state is record
  admin : address;
  authorizations : map(address, bool);
end;

type router_enum is
  | Constructor of constructor_args
  | Fallback of fallback_args
  | Payout of payout_args
  | Deauthorize of deauthorize_args
  | Authorize of authorize_args;

(* EventDefinition Bounty(res__sender : address; res__amount : nat) *)

(* EventDefinition Payout(id : nat; success : bool) *)

(* modifier onlyAdmin inlined *)

(* modifier authorized inlined *)

function constructor (const self : state) : (list(operation) * state) is
  block {
    self.admin := sender;
  } with ((nil: list(operation)), self);

function fallback (const self : state) : (list(operation) * state) is
  block {
    (* EmitStatement Bounty(sender, value) *)
  } with ((nil: list(operation)), self);

function payout (const self : state; const ids : map(nat, nat); const recipients : map(nat, address); const amounts : map(nat, nat)) : (list(operation) * state) is
  block {
    assert(((sender = self.admin) or (case self.authorizations[sender] of | None -> False | Some(x) -> x end)));
    assert(((size(ids) = size(recipients)) and (size(ids) = size(amounts))));
    const i : nat = 0n;
    while (i < size(recipients)) block {
      (* EmitStatement Payout(, ) *)
      i := i + 1;
    };
  } with ((nil: list(operation)), self);

function deauthorize (const self : state; const agent : address) : (list(operation) * state) is
  block {
    assert((sender = self.admin));
    self.authorizations[agent] := False;
  } with ((nil: list(operation)), self);

function authorize (const self : state; const agent : address) : (list(operation) * state) is
  block {
    assert((sender = self.admin));
    self.authorizations[agent] := True;
  } with ((nil: list(operation)), self);

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Constructor(match_action) -> constructor(self)
  | Fallback(match_action) -> fallback(self)
  | Payout(match_action) -> payout(self, match_action.ids, match_action.recipients, match_action.amounts)
  | Deauthorize(match_action) -> deauthorize(self, match_action.agent)
  | Authorize(match_action) -> authorize(self, match_action.agent)
  end);
