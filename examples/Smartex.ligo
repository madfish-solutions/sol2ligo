FLAG need_prevent_deploy
type smartex_User is record
  id : nat;
  referrerID : nat;
  referrals : map(nat, address);
  levelExpiresAt : map(nat, nat);
end;

type fallback_args is unit;
type getUserLevelExpiresAt_args is record
  receiver : contract(unit);
  user_ : address;
  level_ : nat;
end;

type getUserUpline_args is record
  receiver : contract(unit);
  user_ : address;
  height : nat;
end;

type buyLevel_args is record
  level_ : nat;
end;

type findReferrer_args is record
  receiver : contract(unit);
  user_ : address;
end;

type registerUser_args is record
  referrerID_ : nat;
end;

type fallback_args is unit;
type getUserReferrals_args is record
  receiver : contract(unit);
  user_ : address;
end;

type state is record
  creator : address;
  currentUserID : nat;
  levelPrice : map(nat, nat);
  users : map(address, smartex_User);
  userAddresses : map(nat, address);
  MAX_LEVEL : nat;
  REFERRALS_LIMIT : nat;
  LEVEL_DURATION : nat;
end;

const smartex_User_default : smartex_User = record [ id = 0n;
	referrerID = 0n;
	referrals = (map end : map(nat, address));
	levelExpiresAt = (map end : map(nat, nat)) ];

type router_enum is
  | Fallback of fallback_args
  | GetUserLevelExpiresAt of getUserLevelExpiresAt_args
  | GetUserUpline of getUserUpline_args
  | BuyLevel of buyLevel_args
  | FindReferrer of findReferrer_args
  | RegisterUser of registerUser_args
  | Fallback of fallback_args
  | GetUserReferrals of getUserReferrals_args;

(* EventDefinition RegisterUserEvent(user : address; referrer : address; time : nat) *)

(* EventDefinition BuyLevelEvent(user : address; level : nat; time : nat) *)

(* EventDefinition GetLevelProfitEvent(user : address; referral : address; level : nat; time : nat) *)

(* EventDefinition LostLevelProfitEvent(user : address; referral : address; level : nat; time : nat) *)

(* modifier userNotRegistered inlined *)

(* modifier userRegistered inlined *)

(* modifier validReferrerID inlined *)

(* modifier validLevel inlined *)

(* modifier validLevelAmount inlined *)

function fallback (const self : state) : (list(operation) * state) is
  block {
    self.levelPrice[1n] := (0.5n * 1000000n);
    self.levelPrice[2n] := (1n * 1000000n);
    self.levelPrice[3n] := (2n * 1000000n);
    self.levelPrice[4n] := (4n * 1000000n);
    self.levelPrice[5n] := (8n * 1000000n);
    self.levelPrice[6n] := (16n * 1000000n);
    self.currentUserID := self.currentUserID + 1;
    self.creator := sender;
    self.users[self.creator] := createNewUser(self, 0);
    self.userAddresses[self.currentUserID] := self.creator;
    const i : nat = 1n;
    while (i <= self.MAX_LEVEL) block {
      (case self.users[self.creator] of | None -> smartex_User_default | Some(x) -> x end).levelExpiresAt[i] := bitwise_lsl(1n, 37n);
      i := i + 1;
    };
  } with ((nil: list(operation)), self);

function addressToPayable (const _addr : address) : (address) is
  block {
    skip
  } with ((abs(addr_) : address));

function getUserLevelExpiresAt (const self : state; const receiver : contract(unit); const user_ : address; const level_ : nat) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function getUserUpline (const self : state; const receiver : contract(unit); const user_ : address; const height : nat) : (list(operation)) is
  block {
    if ((height <= 0n) or (user_ = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address))) then block {
      skip
    } with ((nil: list(operation))); else block {
      skip
    };
  } with ((nil: list(operation)));

function transferLevelPayment (const self : state; const level_ : nat; const user_ : address) : (state) is
  block {
    const height : nat = (case (level_ > 3n) of | True -> (level_ - 3n) | False -> level_ end);
    const referrer : address = getUserUpline(self, user_, height);
    if (referrer = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) then block {
      referrer := self.creator;
    } else block {
      skip
    };
    if (getUserLevelExpiresAt(self, referrer, level_) < abs(now - ("1970-01-01T00:00:00Z": timestamp))) then block {
      (* EmitStatement undefined(referrer, , _level, now) *)
      transferLevelPayment(self, level_, referrer);
    } with (self); else block {
      skip
    };
    if (var opList : list(operation) := list transaction(unit, (amount / 1mutez) * 1mutez, (get_contract(addressToPayable(referrer)) : contract(unit))) end) then block {
      (* EmitStatement undefined(referrer, , _level, now) *)
    } else block {
      skip
    };
  } with (self);

function buyLevel (const self : state; const level_ : nat) : (list(operation) * state) is
  block {
    assert(((amount / 1mutez) = (case self.levelPrice[level_] of | None -> 0n | Some(x) -> x end))) (* "Invalid level amount" *);
    assert(((level_ > 0n) and (level_ <= self.MAX_LEVEL))) (* "Invalid level" *);
    assert(((case self.users[sender] of | None -> smartex_User_default | Some(x) -> x end).id =/= 0n)) (* "User does not exist" *);
    const l : nat = (level_ - 1n);
    while (l > 0n) block {
      assert((getUserLevelExpiresAt(self, sender, l) >= abs(now - ("1970-01-01T00:00:00Z": timestamp)))) (* "Buy the previous level" *);
      l := l - 1;
    };
    if (getUserLevelExpiresAt(self, sender, level_) = 0) then block {
      (case self.users[sender] of | None -> smartex_User_default | Some(x) -> x end).levelExpiresAt[level_] := (abs(now - ("1970-01-01T00:00:00Z": timestamp)) + self.LEVEL_DURATION);
    } else block {
      (case self.users[sender] of | None -> smartex_User_default | Some(x) -> x end).levelExpiresAt[level_] := ((case (case self.users[sender] of | None -> smartex_User_default | Some(x) -> x end).levelExpiresAt[level_] of | None -> 0n | Some(x) -> x end) + self.LEVEL_DURATION);
    };
    transferLevelPayment(self, level_, sender);
    (* EmitStatement undefined(, _level, now) *)
  } with ((nil: list(operation)), self);

function createNewUser (const self : state; const referrerID_ : nat) : (smartex_User) is
  block {
    skip
  } with (record [ id = self.currentUserID;
  	referrerID = referrerID_;
  	referrals = map end (* args: 0 *) ]);

function findReferrer (const self : state; const receiver : contract(unit); const user_ : address) : (list(operation)) is
  block {
    if (size((case self.users[user_] of | None -> smartex_User_default | Some(x) -> x end).referrals) < self.REFERRALS_LIMIT) then block {
      skip
    } with ((nil: list(operation))); else block {
      skip
    };
    const referrals : map(nat, address) = (map end : map(nat, address));
    referrals[0n] := (case (case self.users[user_] of | None -> smartex_User_default | Some(x) -> x end).referrals[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end);
    referrals[1n] := (case (case self.users[user_] of | None -> smartex_User_default | Some(x) -> x end).referrals[1n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end);
    const referrer : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    const i : nat = 0n;
    while (i < 1024n) block {
      if (size((case self.users[(case referrals[i] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> smartex_User_default | Some(x) -> x end).referrals) < self.REFERRALS_LIMIT) then block {
        referrer := (case referrals[i] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end);
        (* CRITICAL WARNING break is not supported *);
      } else block {
        skip
      };
      if (i >= 512n) then block {
        (* CRITICAL WARNING continue is not supported *);
      } else block {
        skip
      };
      referrals[((i + 1n) * 2n)] := (case (case self.users[(case referrals[i] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> smartex_User_default | Some(x) -> x end).referrals[0n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end);
      referrals[(((i + 1n) * 2n) + 1n)] := (case (case self.users[(case referrals[i] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> smartex_User_default | Some(x) -> x end).referrals[1n] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end);
      i := i + 1;
    };
    assert((referrer =/= ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address))) (* "Referrer was not found" *);
  } with ((nil: list(operation)));

function registerUser (const self : state; const referrerID_ : nat) : (list(operation) * state) is
  block {
    const level_ : nat = 1n;
    assert(((amount / 1mutez) = (case self.levelPrice[level_] of | None -> 0n | Some(x) -> x end))) (* "Invalid level amount" *);
    assert(((referrerID_ > 0n) and (referrerID_ <= self.currentUserID))) (* "Invalid referrer ID" *);
    assert(((case self.users[sender] of | None -> smartex_User_default | Some(x) -> x end).id = 0n)) (* "User is already registered" *);
    if (size((case self.users[(case self.userAddresses[referrerID_] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> smartex_User_default | Some(x) -> x end).referrals) >= self.REFERRALS_LIMIT) then block {
      referrerID_ := (case self.users[findReferrer(self, (case self.userAddresses[referrerID_] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end))] of | None -> smartex_User_default | Some(x) -> x end).id;
    } else block {
      skip
    };
    self.currentUserID := self.currentUserID + 1;
    self.users[sender] := createNewUser(self, referrerID_);
    self.userAddresses[self.currentUserID] := sender;
    (case self.users[sender] of | None -> smartex_User_default | Some(x) -> x end).levelExpiresAt[1n] := (abs(now - ("1970-01-01T00:00:00Z": timestamp)) + self.LEVEL_DURATION);
    const tmp_2 : map(nat, address) = (case self.users[(case self.userAddresses[referrerID_] of | None -> ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) | Some(x) -> x end)] of | None -> smartex_User_default | Some(x) -> x end).referrals;
    tmp_2[size(tmp_2)] := sender;
    transferLevelPayment(self, 1, sender);
    (* EmitStatement undefined(, , now) *)
  } with ((nil: list(operation)), self);

function bytesToAddress (const _addr : bytes) : (address) is
  block {
    const addr : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    (* InlineAssembly { addr := mload(add(_addr, 20)) } *)
  } with (addr);

function fallback (const self : state) : (list(operation) * state) is
  block {
    const level : nat = 0n;
    const i : nat = 1n;
    while (i <= self.MAX_LEVEL) block {
      if ((amount / 1mutez) = (case self.levelPrice[i] of | None -> 0n | Some(x) -> x end)) then block {
        level := i;
        (* CRITICAL WARNING break is not supported *);
      } else block {
        skip
      };
      i := i + 1;
    };
    assert((level > 0n)) (* "Invalid amount has sent" *);
    if ((case self.users[sender] of | None -> smartex_User_default | Some(x) -> x end).id =/= 0n) then block {
      buyLevel(self, level);
    } with ((nil: list(operation)), self); else block {
      skip
    };
    if (level =/= 1n) then block {
      failwith("Buy first level for 0.5 ETH");
    } else block {
      skip
    };
    const referrer : address = bytesToAddress(("00": bytes));
    registerUser(self, (case self.users[referrer] of | None -> smartex_User_default | Some(x) -> x end).id);
  } with ((nil: list(operation)), self);

function getUserReferrals (const self : state; const receiver : contract(unit); const user_ : address) : (list(operation)) is
  block {
    skip
  } with ((nil: list(operation)));

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Fallback(match_action) -> fallback(self)
  | GetUserLevelExpiresAt(match_action) -> (getUserLevelExpiresAt(self, match_action.receiver, match_action.user_, match_action.level_), self)
  | GetUserUpline(match_action) -> (getUserUpline(self, match_action.receiver, match_action.user_, match_action.height), self)
  | BuyLevel(match_action) -> buyLevel(self, match_action.level_)
  | FindReferrer(match_action) -> (findReferrer(self, match_action.receiver, match_action.user_), self)
  | RegisterUser(match_action) -> registerUser(self, match_action.referrerID_)
  | Fallback(match_action) -> fallback(self)
  | GetUserReferrals(match_action) -> (getUserReferrals(self, match_action.receiver, match_action.user_), self)
  end);
