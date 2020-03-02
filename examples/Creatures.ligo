type creatures_Creature is record
  species : nat;
  subSpecies : nat;
  eyeColor : nat;
  timestamp : nat;
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
  receiver : contract(unit);
  id : nat;
end;

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

type router_enum is
  | Transfer of transfer_args
  | Add of add_args
  | GetCreature of getCreature_args;

(* EventDefinition CreateCreature(id : nat; owner : address) *)

(* EventDefinition Transfer(from_ : address; to_ : address; creatureID : nat) *)

function constructor (const self : state_) : (Unit) is
  block {
    permissions_constructor(self);
  } with ();

function newCaller (const self : state_Permissions; const new_ : address) : (list(operation) * state_Permissions) is
  block {
    assert((sender = self.ownerAddress));
    if (new_ =/= ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) then block {
      self.callerAddress := new_;
    } else block {
      skip
    };
  } with ((nil: list(operation)), self);

function newStorage (const self : state_Permissions; const new_ : address) : (list(operation) * state_Permissions) is
  block {
    assert((sender = self.ownerAddress));
    if (new_ =/= ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) then block {
      self.storageAddress := new_;
    } else block {
      skip
    };
  } with ((nil: list(operation)), self);

function transferOwnership (const self : state_Permissions; const newOwner : address) : (list(operation) * state_Permissions) is
  block {
    assert((sender = self.ownerAddress));
    if (newOwner =/= ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) then block {
      self.ownerAddress := newOwner;
    } else block {
      skip
    };
  } with ((nil: list(operation)), self);

function getCaller (const self : state_Permissions; const receiver : contract(unit)) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function getStorageAddress (const self : state_Permissions; const receiver : contract(unit)) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function getOwner (const self : state_Permissions; const receiver : contract(unit)) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function permissions_constructor (const self : state_Permissions) : (list(operation) * state_Permissions) is
  block {
    self.ownerAddress := sender;
  } with ((nil: list(operation)), self);

function transfer (const self : state; const from_ : address; const to_ : address; const tokenId_ : nat) : (list(operation) * state) is
  block {
    assert((sender = self.callerAddress));
    self.creatureIndexToOwner[tokenId_] := to_;
    if (from_ =/= ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) then block {
      (case self.ownershipTokenCount[from_] of | None -> 0n | Some(x) -> x end) := (case self.ownershipTokenCount[from_] of | None -> 0n | Some(x) -> x end) - 1;
    } else block {
      skip
    };
    (case self.ownershipTokenCount[to_] of | None -> 0n | Some(x) -> x end) := (case self.ownershipTokenCount[to_] of | None -> 0n | Some(x) -> x end) + 1;
    (* EmitStatement Transfer(_from, _to, _tokenId) *)
  } with ((nil: list(operation)), self);

function add (const self : state; const owner_ : address; const species_ : nat; const subSpecies_ : nat; const eyeColor_ : nat) : (list(operation) * state) is
  block {
    assert((sender = self.callerAddress));
    const creature_ : creatures_Creature = record [ species = species_;
    	subSpecies = subSpecies_;
    	eyeColor = eyeColor_;
    	timestamp = abs(abs(now - ("1970-01-01T00:00:00Z": timestamp))) ];
    const tmp_0 : map(nat, creatures_Creature) = self.creatures;
    const newCreatureID : nat = (tmp_0[size(tmp_0)] := creature_ - 1n);
    transfer(self, 0, owner_, newCreatureID);
    (* EmitStatement CreateCreature(newCreatureID, _owner) *)
  } with ((nil: list(operation)), self);

function getCreature (const self : state; const receiver : contract(unit); const id : nat) : (list(operation)) is
  block {
    const c : creatures_Creature = (case self.creatures[id] of | None -> creatures_Creature_default | Some(x) -> x end);
    const owner : address = (case self.creatureIndexToOwner[id] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end);
  } with ((nil: list(operation)));

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Transfer(match_action) -> transfer(self, match_action.from_, match_action.to_, match_action.tokenId_)
  | Add(match_action) -> add(self, match_action.owner_, match_action.species_, match_action.subSpecies_, match_action.eyeColor_)
  | GetCreature(match_action) -> (getCreature(self, match_action.receiver, match_action.id), self)
  end);
