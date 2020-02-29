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
type transfer_args is record
  to_ : address;
  value_ : nat;
end;

type transferFrom_args is record
  from_ : address;
  to_ : address;
  value_ : nat;
end;

type balanceOf_args is record
  owner_ : address;
end;

type approve_args is record
  spender_ : address;
  value_ : nat;
end;

type allowance_args is record
  owner_ : address;
  spender_ : address;
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
type allowance_args is record
  owner_ : address;
  spender_ : address;
end;

type approve_args is record
  spender_ : address;
  value_ : nat;
end;

type balanceOf_args is record
  owner_ : address;
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

type constructor_args is unit;
type create_args is record
  account : address;
  res__amount : nat;
end;

type destroy_args is record
  account : address;
  res__amount : nat;
end;

type accountLevel_args is record
  user : address;
end;

type setAccountLevel_args is record
  user : address;
  level : nat;
end;

type accountLevel_args is record
  user : address;
end;

type constructor_args is record
  admin_ : address;
  feeAccount_ : address;
  accountLevelsAddr_ : address;
  feeMake_ : nat;
  feeTake_ : nat;
  feeRebate_ : nat;
end;

type fallback_args is unit;
type changeAdmin_args is record
  admin_ : address;
end;

type changeAccountLevelsAddr_args is record
  accountLevelsAddr_ : address;
end;

type changeFeeAccount_args is record
  feeAccount_ : address;
end;

type changeFeeMake_args is record
  feeMake_ : nat;
end;

type changeFeeTake_args is record
  feeTake_ : nat;
end;

type changeFeeRebate_args is record
  feeRebate_ : nat;
end;

type deposit_args is unit;
type withdraw_args is record
  res__amount : nat;
end;

type depositToken_args is record
  token : address;
  res__amount : nat;
end;

type withdrawToken_args is record
  token : address;
  res__amount : nat;
end;

type balanceOf_args is record
  token : address;
  user : address;
end;

type order_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
end;

type trade_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
  res__amount : nat;
end;

type availableVolume_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
end;

type testTrade_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
  res__amount : nat;
  res__sender : address;
end;

type amountFilled_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
end;

type cancelOrder_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  v : nat;
  r : bytes;
  s : bytes;
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
type transfer_args is record
  to_ : address;
  value_ : nat;
end;

type transferFrom_args is record
  from_ : address;
  to_ : address;
  value_ : nat;
end;

type balanceOf_args is record
  owner_ : address;
end;

type approve_args is record
  spender_ : address;
  value_ : nat;
end;

type allowance_args is record
  owner_ : address;
  spender_ : address;
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
type allowance_args is record
  owner_ : address;
  spender_ : address;
end;

type approve_args is record
  spender_ : address;
  value_ : nat;
end;

type balanceOf_args is record
  owner_ : address;
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

type constructor_args is unit;
type create_args is record
  account : address;
  res__amount : nat;
end;

type destroy_args is record
  account : address;
  res__amount : nat;
end;

type accountLevel_args is record
  user : address;
end;

type setAccountLevel_args is record
  user : address;
  level : nat;
end;

type accountLevel_args is record
  user : address;
end;

type constructor_args is record
  admin_ : address;
  feeAccount_ : address;
  accountLevelsAddr_ : address;
  feeMake_ : nat;
  feeTake_ : nat;
  feeRebate_ : nat;
end;

type fallback_args is unit;
type changeAdmin_args is record
  admin_ : address;
end;

type changeAccountLevelsAddr_args is record
  accountLevelsAddr_ : address;
end;

type changeFeeAccount_args is record
  feeAccount_ : address;
end;

type changeFeeMake_args is record
  feeMake_ : nat;
end;

type changeFeeTake_args is record
  feeTake_ : nat;
end;

type changeFeeRebate_args is record
  feeRebate_ : nat;
end;

type deposit_args is unit;
type withdraw_args is record
  res__amount : nat;
end;

type depositToken_args is record
  token : address;
  res__amount : nat;
end;

type withdrawToken_args is record
  token : address;
  res__amount : nat;
end;

type balanceOf_args is record
  token : address;
  user : address;
end;

type order_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
end;

type trade_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
  res__amount : nat;
end;

type availableVolume_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
end;

type testTrade_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
  res__amount : nat;
  res__sender : address;
end;

type amountFilled_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
end;

type cancelOrder_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  v : nat;
  r : bytes;
  s : bytes;
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
type transfer_args is record
  to_ : address;
  value_ : nat;
end;

type transferFrom_args is record
  from_ : address;
  to_ : address;
  value_ : nat;
end;

type balanceOf_args is record
  owner_ : address;
end;

type approve_args is record
  spender_ : address;
  value_ : nat;
end;

type allowance_args is record
  owner_ : address;
  spender_ : address;
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
type allowance_args is record
  owner_ : address;
  spender_ : address;
end;

type approve_args is record
  spender_ : address;
  value_ : nat;
end;

type balanceOf_args is record
  owner_ : address;
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

type constructor_args is unit;
type create_args is record
  account : address;
  res__amount : nat;
end;

type destroy_args is record
  account : address;
  res__amount : nat;
end;

type accountLevel_args is record
  user : address;
end;

type setAccountLevel_args is record
  user : address;
  level : nat;
end;

type accountLevel_args is record
  user : address;
end;

type constructor_args is record
  admin_ : address;
  feeAccount_ : address;
  accountLevelsAddr_ : address;
  feeMake_ : nat;
  feeTake_ : nat;
  feeRebate_ : nat;
end;

type fallback_args is unit;
type changeAdmin_args is record
  admin_ : address;
end;

type changeAccountLevelsAddr_args is record
  accountLevelsAddr_ : address;
end;

type changeFeeAccount_args is record
  feeAccount_ : address;
end;

type changeFeeMake_args is record
  feeMake_ : nat;
end;

type changeFeeTake_args is record
  feeTake_ : nat;
end;

type changeFeeRebate_args is record
  feeRebate_ : nat;
end;

type deposit_args is unit;
type withdraw_args is record
  res__amount : nat;
end;

type depositToken_args is record
  token : address;
  res__amount : nat;
end;

type withdrawToken_args is record
  token : address;
  res__amount : nat;
end;

type balanceOf_args is record
  token : address;
  user : address;
end;

type order_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
end;

type trade_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
  res__amount : nat;
end;

type availableVolume_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
end;

type testTrade_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
  res__amount : nat;
  res__sender : address;
end;

type amountFilled_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
end;

type cancelOrder_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  v : nat;
  r : bytes;
  s : bytes;
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
type transfer_args is record
  to_ : address;
  value_ : nat;
end;

type transferFrom_args is record
  from_ : address;
  to_ : address;
  value_ : nat;
end;

type balanceOf_args is record
  owner_ : address;
end;

type approve_args is record
  spender_ : address;
  value_ : nat;
end;

type allowance_args is record
  owner_ : address;
  spender_ : address;
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
type allowance_args is record
  owner_ : address;
  spender_ : address;
end;

type approve_args is record
  spender_ : address;
  value_ : nat;
end;

type balanceOf_args is record
  owner_ : address;
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

type constructor_args is unit;
type create_args is record
  account : address;
  res__amount : nat;
end;

type destroy_args is record
  account : address;
  res__amount : nat;
end;

type accountLevel_args is record
  user : address;
end;

type setAccountLevel_args is record
  user : address;
  level : nat;
end;

type accountLevel_args is record
  user : address;
end;

type constructor_args is record
  admin_ : address;
  feeAccount_ : address;
  accountLevelsAddr_ : address;
  feeMake_ : nat;
  feeTake_ : nat;
  feeRebate_ : nat;
end;

type fallback_args is unit;
type changeAdmin_args is record
  admin_ : address;
end;

type changeAccountLevelsAddr_args is record
  accountLevelsAddr_ : address;
end;

type changeFeeAccount_args is record
  feeAccount_ : address;
end;

type changeFeeMake_args is record
  feeMake_ : nat;
end;

type changeFeeTake_args is record
  feeTake_ : nat;
end;

type changeFeeRebate_args is record
  feeRebate_ : nat;
end;

type deposit_args is unit;
type withdraw_args is record
  res__amount : nat;
end;

type depositToken_args is record
  token : address;
  res__amount : nat;
end;

type withdrawToken_args is record
  token : address;
  res__amount : nat;
end;

type balanceOf_args is record
  token : address;
  user : address;
end;

type order_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
end;

type trade_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
  res__amount : nat;
end;

type availableVolume_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
end;

type testTrade_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
  res__amount : nat;
  res__sender : address;
end;

type amountFilled_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  user : address;
  v : nat;
  r : bytes;
  s : bytes;
end;

type cancelOrder_args is record
  tokenGet : address;
  amountGet : nat;
  tokenGive : address;
  amountGive : nat;
  expires : nat;
  nonce : nat;
  v : nat;
  r : bytes;
  s : bytes;
end;

type state is record
  name : string;
  decimals : nat;
  balances : map(address, nat);
  allowed : map(address, map(address, nat));
  totalSupply : nat;
  name : string;
  decimals : nat;
  totalSupply : nat;
  allowed : map(address, map(address, nat));
  balances : map(address, nat);
  minter : address;
  accountLevels : map(address, nat);
  admin : address;
  feeAccount : address;
  accountLevelsAddr : address;
  feeMake : nat;
  feeTake : nat;
  feeRebate : nat;
  tokens : map(address, map(address, nat));
  orders : map(address, map(bytes, bool));
  orderFills : map(address, map(bytes, nat));
end;

type router_enum is
  | Allowance of allowance_args
  | Approve of approve_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | BalanceOf of balanceOf_args
  | TotalSupply of totalSupply_args
  | Transfer of transfer_args
  | TransferFrom of transferFrom_args
  | BalanceOf of balanceOf_args
  | Approve of approve_args
  | Allowance of allowance_args
  | Allowance of allowance_args
  | Approve of approve_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | BalanceOf of balanceOf_args
  | TotalSupply of totalSupply_args
  | Allowance of allowance_args
  | Approve of approve_args
  | BalanceOf of balanceOf_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | Constructor of constructor_args
  | Create of create_args
  | Destroy of destroy_args
  | AccountLevel of accountLevel_args
  | SetAccountLevel of setAccountLevel_args
  | AccountLevel of accountLevel_args
  | Constructor of constructor_args
  | Fallback of fallback_args
  | ChangeAdmin of changeAdmin_args
  | ChangeAccountLevelsAddr of changeAccountLevelsAddr_args
  | ChangeFeeAccount of changeFeeAccount_args
  | ChangeFeeMake of changeFeeMake_args
  | ChangeFeeTake of changeFeeTake_args
  | ChangeFeeRebate of changeFeeRebate_args
  | Deposit of deposit_args
  | Withdraw of withdraw_args
  | DepositToken of depositToken_args
  | WithdrawToken of withdrawToken_args
  | BalanceOf of balanceOf_args
  | Order of order_args
  | Trade of trade_args
  | AvailableVolume of availableVolume_args
  | TestTrade of testTrade_args
  | AmountFilled of amountFilled_args
  | CancelOrder of cancelOrder_args;

function allowance (const self : state; const owner_ : address; const spender_ : address) : (list(operation) * nat) is
  block {
    const remaining : nat = 0n;
  } with ((nil: list(operation)), remaining);

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

function balanceOf (const self : state; const owner_ : address) : (list(operation) * nat) is
  block {
    const res__balance : nat = 0n;
  } with ((nil: list(operation)), res__balance);

function totalSupply (const self : state) : (list(operation) * nat) is
  block {
    const supply : nat = 0n;
  } with ((nil: list(operation)), supply);

function transfer (const self : state; const to_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    if (((case self.balances[sender] of | None -> 0n | Some(x) -> x end) >= value_) and (((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + value_) > (case self.balances[to_] of | None -> 0n | Some(x) -> x end))) then block {
      self.balances[sender] := abs((case self.balances[sender] of | None -> 0n | Some(x) -> x end) - value_);
      self.balances[to_] := ((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + value_);
      (* EmitStatement Transfer(sender, _to, _value) *)
    } with ((nil: list(operation)), self); else block {
      skip
    } with ((nil: list(operation)), self);;
  } with ((nil: list(operation)), self, success);

function transferFrom (const self : state; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    if ((((case self.balances[from_] of | None -> 0n | Some(x) -> x end) >= value_) and ((case (case self.allowed[from_] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end) >= value_)) and (((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + value_) > (case self.balances[to_] of | None -> 0n | Some(x) -> x end))) then block {
      self.balances[to_] := ((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + value_);
      self.balances[from_] := abs((case self.balances[from_] of | None -> 0n | Some(x) -> x end) - value_);
      (case self.allowed[from_] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] := abs((case (case self.allowed[from_] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end) - value_);
      (* EmitStatement Transfer(_from, _to, _value) *)
    } with ((nil: list(operation)), self); else block {
      skip
    } with ((nil: list(operation)), self);;
  } with ((nil: list(operation)), self, success);

function balanceOf (const self : state; const owner_ : address) : (list(operation) * nat) is
  block {
    const res__balance : nat = 0n;
  } with ((nil: list(operation)));

function approve (const self : state; const spender_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    (case self.allowed[sender] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[spender_] := value_;
    (* EmitStatement Approval(sender, _spender, _value) *)
  } with ((nil: list(operation)), self);

function allowance (const self : state; const owner_ : address; const spender_ : address) : (list(operation) * nat) is
  block {
    const remaining : nat = 0n;
  } with ((nil: list(operation)));

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | Constructor(match_action) -> constructor(self)
  | Create(match_action) -> create(self, match_action.account, match_action.res__amount)
  | Destroy(match_action) -> destroy(self, match_action.account, match_action.res__amount)
  | AccountLevel(match_action) -> (accountLevel(self, match_action.user), self)
  | SetAccountLevel(match_action) -> setAccountLevel(self, match_action.user, match_action.level)
  | AccountLevel(match_action) -> (accountLevel(self, match_action.user), self)
  | Constructor(match_action) -> constructor(self, match_action.admin_, match_action.feeAccount_, match_action.accountLevelsAddr_, match_action.feeMake_, match_action.feeTake_, match_action.feeRebate_)
  | Fallback(match_action) -> fallback(self)
  | ChangeAdmin(match_action) -> changeAdmin(self, match_action.admin_)
  | ChangeAccountLevelsAddr(match_action) -> changeAccountLevelsAddr(self, match_action.accountLevelsAddr_)
  | ChangeFeeAccount(match_action) -> changeFeeAccount(self, match_action.feeAccount_)
  | ChangeFeeMake(match_action) -> changeFeeMake(self, match_action.feeMake_)
  | ChangeFeeTake(match_action) -> changeFeeTake(self, match_action.feeTake_)
  | ChangeFeeRebate(match_action) -> changeFeeRebate(self, match_action.feeRebate_)
  | Deposit(match_action) -> deposit(self)
  | Withdraw(match_action) -> 
  | DepositToken(match_action) -> depositToken(self, match_action.token, match_action.res__amount)
  | WithdrawToken(match_action) -> 
  | BalanceOf(match_action) -> (balanceOf(self, match_action.token, match_action.user), self)
  | Order(match_action) -> order(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce)
  | Trade(match_action) -> trade(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s, match_action.res__amount)
  | AvailableVolume(match_action) -> (availableVolume(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s), self)
  | TestTrade(match_action) -> (testTrade(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s, match_action.res__amount, match_action.res__sender), self)
  | AmountFilled(match_action) -> (amountFilled(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s), self)
  | CancelOrder(match_action) -> cancelOrder(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.v, match_action.r, match_action.s)
  end);
type router_enum is
  | Allowance of allowance_args
  | Approve of approve_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | BalanceOf of balanceOf_args
  | TotalSupply of totalSupply_args
  | Transfer of transfer_args
  | TransferFrom of transferFrom_args
  | BalanceOf of balanceOf_args
  | Approve of approve_args
  | Allowance of allowance_args
  | Allowance of allowance_args
  | Approve of approve_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | BalanceOf of balanceOf_args
  | TotalSupply of totalSupply_args
  | Allowance of allowance_args
  | Approve of approve_args
  | BalanceOf of balanceOf_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | Constructor of constructor_args
  | Create of create_args
  | Destroy of destroy_args
  | AccountLevel of accountLevel_args
  | SetAccountLevel of setAccountLevel_args
  | AccountLevel of accountLevel_args
  | Constructor of constructor_args
  | Fallback of fallback_args
  | ChangeAdmin of changeAdmin_args
  | ChangeAccountLevelsAddr of changeAccountLevelsAddr_args
  | ChangeFeeAccount of changeFeeAccount_args
  | ChangeFeeMake of changeFeeMake_args
  | ChangeFeeTake of changeFeeTake_args
  | ChangeFeeRebate of changeFeeRebate_args
  | Deposit of deposit_args
  | Withdraw of withdraw_args
  | DepositToken of depositToken_args
  | WithdrawToken of withdrawToken_args
  | BalanceOf of balanceOf_args
  | Order of order_args
  | Trade of trade_args
  | AvailableVolume of availableVolume_args
  | TestTrade of testTrade_args
  | AmountFilled of amountFilled_args
  | CancelOrder of cancelOrder_args;

function allowance (const self : state; const owner_ : address; const spender_ : address) : (list(operation) * nat) is
  block {
    const remaining : nat = 0n;
  } with ((nil: list(operation)), remaining);

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

function balanceOf (const self : state; const owner_ : address) : (list(operation) * nat) is
  block {
    const res__balance : nat = 0n;
  } with ((nil: list(operation)), res__balance);

function totalSupply (const self : state) : (list(operation) * nat) is
  block {
    const supply : nat = 0n;
  } with ((nil: list(operation)), supply);

function allowance (const self : state; const owner_ : address; const spender_ : address) : (list(operation) * nat) is
  block {
    const remaining : nat = 0n;
  } with ((nil: list(operation)));

function approve (const self : state; const spender_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    (case self.allowed[sender] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[spender_] := value_;
    (* EmitStatement Approval(sender, _spender, _value) *)
  } with ((nil: list(operation)), self);

function balanceOf (const self : state; const owner_ : address) : (list(operation) * nat) is
  block {
    const res__balance : nat = 0n;
  } with ((nil: list(operation)));

function transferFrom (const self : state; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    if ((((case self.balances[from_] of | None -> 0n | Some(x) -> x end) >= value_) and ((case (case self.allowed[from_] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end) >= value_)) and (((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + value_) > (case self.balances[to_] of | None -> 0n | Some(x) -> x end))) then block {
      self.balances[to_] := ((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + value_);
      self.balances[from_] := abs((case self.balances[from_] of | None -> 0n | Some(x) -> x end) - value_);
      (case self.allowed[from_] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] := abs((case (case self.allowed[from_] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end) - value_);
      (* EmitStatement Transfer(_from, _to, _value) *)
    } with ((nil: list(operation)), self); else block {
      skip
    } with ((nil: list(operation)), self);;
  } with ((nil: list(operation)), self, success);

function transfer (const self : state; const to_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    if (((case self.balances[sender] of | None -> 0n | Some(x) -> x end) >= value_) and (((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + value_) > (case self.balances[to_] of | None -> 0n | Some(x) -> x end))) then block {
      self.balances[sender] := abs((case self.balances[sender] of | None -> 0n | Some(x) -> x end) - value_);
      self.balances[to_] := ((case self.balances[to_] of | None -> 0n | Some(x) -> x end) + value_);
      (* EmitStatement Transfer(sender, _to, _value) *)
    } with ((nil: list(operation)), self); else block {
      skip
    } with ((nil: list(operation)), self);;
  } with ((nil: list(operation)), self, success);

function safeAdd (const self : state; const a : nat; const b : nat) : (state * nat) is
  block {
    const c : nat = (a + b);
    assert(((c >= a) and (c >= b)));
  } with (self, c);

function safeSub (const self : state; const a : nat; const b : nat) : (state * nat) is
  block {
    assert((b <= a));
  } with (self, abs(a - b));

function safeMul (const self : state; const a : nat; const b : nat) : (state * nat) is
  block {
    const c : nat = (a * b);
    assert(((a = 0n) or ((c / a) = b)));
  } with (self, c);

function assert (const self : state; const assertion : bool) : (state) is
  block {
    if (not (assertion)) then block {
      failwith("throw");
    } else block {
      skip
    };
  } with (self);

function constructor (const self : state) : (list(operation) * state) is
  block {
    self.minter := sender;
  } with ((nil: list(operation)), self);

function create (const self : state; const account : address; const res__amount : nat) : (list(operation) * state) is
  block {
    if (sender =/= self.minter) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.balances[account] := safeAdd(self, (case self.balances[account] of | None -> 0n | Some(x) -> x end), res__amount);
    self.totalSupply := safeAdd(self, self.totalSupply, res__amount);
  } with ((nil: list(operation)), self);

function destroy (const self : state; const account : address; const res__amount : nat) : (list(operation) * state) is
  block {
    if (sender =/= self.minter) then block {
      failwith("throw");
    } else block {
      skip
    };
    if ((case self.balances[account] of | None -> 0n | Some(x) -> x end) < res__amount) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.balances[account] := safeSub(self, (case self.balances[account] of | None -> 0n | Some(x) -> x end), res__amount);
    self.totalSupply := safeSub(self, self.totalSupply, res__amount);
  } with ((nil: list(operation)), self);

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | Constructor(match_action) -> constructor(self)
  | Create(match_action) -> create(self, match_action.account, match_action.res__amount)
  | Destroy(match_action) -> destroy(self, match_action.account, match_action.res__amount)
  | AccountLevel(match_action) -> (accountLevel(self, match_action.user), self)
  | SetAccountLevel(match_action) -> setAccountLevel(self, match_action.user, match_action.level)
  | AccountLevel(match_action) -> (accountLevel(self, match_action.user), self)
  | Constructor(match_action) -> constructor(self, match_action.admin_, match_action.feeAccount_, match_action.accountLevelsAddr_, match_action.feeMake_, match_action.feeTake_, match_action.feeRebate_)
  | Fallback(match_action) -> fallback(self)
  | ChangeAdmin(match_action) -> changeAdmin(self, match_action.admin_)
  | ChangeAccountLevelsAddr(match_action) -> changeAccountLevelsAddr(self, match_action.accountLevelsAddr_)
  | ChangeFeeAccount(match_action) -> changeFeeAccount(self, match_action.feeAccount_)
  | ChangeFeeMake(match_action) -> changeFeeMake(self, match_action.feeMake_)
  | ChangeFeeTake(match_action) -> changeFeeTake(self, match_action.feeTake_)
  | ChangeFeeRebate(match_action) -> changeFeeRebate(self, match_action.feeRebate_)
  | Deposit(match_action) -> deposit(self)
  | Withdraw(match_action) -> 
  | DepositToken(match_action) -> depositToken(self, match_action.token, match_action.res__amount)
  | WithdrawToken(match_action) -> 
  | BalanceOf(match_action) -> (balanceOf(self, match_action.token, match_action.user), self)
  | Order(match_action) -> order(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce)
  | Trade(match_action) -> trade(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s, match_action.res__amount)
  | AvailableVolume(match_action) -> (availableVolume(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s), self)
  | TestTrade(match_action) -> (testTrade(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s, match_action.res__amount, match_action.res__sender), self)
  | AmountFilled(match_action) -> (amountFilled(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s), self)
  | CancelOrder(match_action) -> cancelOrder(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.v, match_action.r, match_action.s)
  end);
type router_enum is
  | Allowance of allowance_args
  | Approve of approve_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | BalanceOf of balanceOf_args
  | TotalSupply of totalSupply_args
  | Transfer of transfer_args
  | TransferFrom of transferFrom_args
  | BalanceOf of balanceOf_args
  | Approve of approve_args
  | Allowance of allowance_args
  | Allowance of allowance_args
  | Approve of approve_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | BalanceOf of balanceOf_args
  | TotalSupply of totalSupply_args
  | Allowance of allowance_args
  | Approve of approve_args
  | BalanceOf of balanceOf_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | Constructor of constructor_args
  | Create of create_args
  | Destroy of destroy_args
  | AccountLevel of accountLevel_args
  | SetAccountLevel of setAccountLevel_args
  | AccountLevel of accountLevel_args
  | Constructor of constructor_args
  | Fallback of fallback_args
  | ChangeAdmin of changeAdmin_args
  | ChangeAccountLevelsAddr of changeAccountLevelsAddr_args
  | ChangeFeeAccount of changeFeeAccount_args
  | ChangeFeeMake of changeFeeMake_args
  | ChangeFeeTake of changeFeeTake_args
  | ChangeFeeRebate of changeFeeRebate_args
  | Deposit of deposit_args
  | Withdraw of withdraw_args
  | DepositToken of depositToken_args
  | WithdrawToken of withdrawToken_args
  | BalanceOf of balanceOf_args
  | Order of order_args
  | Trade of trade_args
  | AvailableVolume of availableVolume_args
  | TestTrade of testTrade_args
  | AmountFilled of amountFilled_args
  | CancelOrder of cancelOrder_args;

function accountLevel (const self : state; const user : address) : (list(operation) * nat) is
  block {
    skip
  } with ((nil: list(operation)));

function setAccountLevel (const self : state; const user : address; const level : nat) : (list(operation) * state) is
  block {
    self.accountLevels[user] := level;
  } with ((nil: list(operation)), self);

function accountLevel (const self : state; const user : address) : (list(operation) * nat) is
  block {
    skip
  } with ((nil: list(operation)));

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | Constructor(match_action) -> constructor(self)
  | Create(match_action) -> create(self, match_action.account, match_action.res__amount)
  | Destroy(match_action) -> destroy(self, match_action.account, match_action.res__amount)
  | AccountLevel(match_action) -> (accountLevel(self, match_action.user), self)
  | SetAccountLevel(match_action) -> setAccountLevel(self, match_action.user, match_action.level)
  | AccountLevel(match_action) -> (accountLevel(self, match_action.user), self)
  | Constructor(match_action) -> constructor(self, match_action.admin_, match_action.feeAccount_, match_action.accountLevelsAddr_, match_action.feeMake_, match_action.feeTake_, match_action.feeRebate_)
  | Fallback(match_action) -> fallback(self)
  | ChangeAdmin(match_action) -> changeAdmin(self, match_action.admin_)
  | ChangeAccountLevelsAddr(match_action) -> changeAccountLevelsAddr(self, match_action.accountLevelsAddr_)
  | ChangeFeeAccount(match_action) -> changeFeeAccount(self, match_action.feeAccount_)
  | ChangeFeeMake(match_action) -> changeFeeMake(self, match_action.feeMake_)
  | ChangeFeeTake(match_action) -> changeFeeTake(self, match_action.feeTake_)
  | ChangeFeeRebate(match_action) -> changeFeeRebate(self, match_action.feeRebate_)
  | Deposit(match_action) -> deposit(self)
  | Withdraw(match_action) -> 
  | DepositToken(match_action) -> depositToken(self, match_action.token, match_action.res__amount)
  | WithdrawToken(match_action) -> 
  | BalanceOf(match_action) -> (balanceOf(self, match_action.token, match_action.user), self)
  | Order(match_action) -> order(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce)
  | Trade(match_action) -> trade(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s, match_action.res__amount)
  | AvailableVolume(match_action) -> (availableVolume(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s), self)
  | TestTrade(match_action) -> (testTrade(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s, match_action.res__amount, match_action.res__sender), self)
  | AmountFilled(match_action) -> (amountFilled(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s), self)
  | CancelOrder(match_action) -> cancelOrder(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.v, match_action.r, match_action.s)
  end);
type router_enum is
  | Allowance of allowance_args
  | Approve of approve_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | BalanceOf of balanceOf_args
  | TotalSupply of totalSupply_args
  | Transfer of transfer_args
  | TransferFrom of transferFrom_args
  | BalanceOf of balanceOf_args
  | Approve of approve_args
  | Allowance of allowance_args
  | Allowance of allowance_args
  | Approve of approve_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | BalanceOf of balanceOf_args
  | TotalSupply of totalSupply_args
  | Allowance of allowance_args
  | Approve of approve_args
  | BalanceOf of balanceOf_args
  | TransferFrom of transferFrom_args
  | Transfer of transfer_args
  | Constructor of constructor_args
  | Create of create_args
  | Destroy of destroy_args
  | AccountLevel of accountLevel_args
  | SetAccountLevel of setAccountLevel_args
  | AccountLevel of accountLevel_args
  | Constructor of constructor_args
  | Fallback of fallback_args
  | ChangeAdmin of changeAdmin_args
  | ChangeAccountLevelsAddr of changeAccountLevelsAddr_args
  | ChangeFeeAccount of changeFeeAccount_args
  | ChangeFeeMake of changeFeeMake_args
  | ChangeFeeTake of changeFeeTake_args
  | ChangeFeeRebate of changeFeeRebate_args
  | Deposit of deposit_args
  | Withdraw of withdraw_args
  | DepositToken of depositToken_args
  | WithdrawToken of withdrawToken_args
  | BalanceOf of balanceOf_args
  | Order of order_args
  | Trade of trade_args
  | AvailableVolume of availableVolume_args
  | TestTrade of testTrade_args
  | AmountFilled of amountFilled_args
  | CancelOrder of cancelOrder_args;

(* EventDefinition Order(tokenGet : address; amountGet : nat; tokenGive : address; amountGive : nat; expires : nat; nonce : nat; user : address) *)

(* EventDefinition Cancel(tokenGet : address; amountGet : nat; tokenGive : address; amountGive : nat; expires : nat; nonce : nat; user : address; v : nat; r : bytes; s : bytes) *)

(* EventDefinition Trade(tokenGet : address; amountGet : nat; tokenGive : address; amountGive : nat; get : address; give : address) *)

(* EventDefinition Deposit(token : address; user : address; res__amount : nat; res__balance : nat) *)

(* EventDefinition Withdraw(token : address; user : address; res__amount : nat; res__balance : nat) *)

function safeAdd (const self : state; const a : nat; const b : nat) : (state * nat) is
  block {
    const c : nat = (a + b);
    assert(((c >= a) and (c >= b)));
  } with (self, c);

function safeSub (const self : state; const a : nat; const b : nat) : (state * nat) is
  block {
    assert((b <= a));
  } with (self, abs(a - b));

function safeMul (const self : state; const a : nat; const b : nat) : (state * nat) is
  block {
    const c : nat = (a * b);
    assert(((a = 0n) or ((c / a) = b)));
  } with (self, c);

function assert (const self : state; const assertion : bool) : (state) is
  block {
    if (not (assertion)) then block {
      failwith("throw");
    } else block {
      skip
    };
  } with (self);

function constructor (const self : state; const admin_ : address; const feeAccount_ : address; const accountLevelsAddr_ : address; const feeMake_ : nat; const feeTake_ : nat; const feeRebate_ : nat) : (list(operation) * state) is
  block {
    self.admin := admin_;
    self.feeAccount := feeAccount_;
    self.accountLevelsAddr := accountLevelsAddr_;
    self.feeMake := feeMake_;
    self.feeTake := feeTake_;
    self.feeRebate := feeRebate_;
  } with ((nil: list(operation)), self);

function fallback (const self : state) : (list(operation) * state) is
  block {
    failwith("throw");
  } with ((nil: list(operation)), self);

function changeAdmin (const self : state; const admin_ : address) : (list(operation) * state) is
  block {
    if (sender =/= self.admin) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.admin := admin_;
  } with ((nil: list(operation)), self);

function changeAccountLevelsAddr (const self : state; const accountLevelsAddr_ : address) : (list(operation) * state) is
  block {
    if (sender =/= self.admin) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.accountLevelsAddr := accountLevelsAddr_;
  } with ((nil: list(operation)), self);

function changeFeeAccount (const self : state; const feeAccount_ : address) : (list(operation) * state) is
  block {
    if (sender =/= self.admin) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.feeAccount := feeAccount_;
  } with ((nil: list(operation)), self);

function changeFeeMake (const self : state; const feeMake_ : nat) : (list(operation) * state) is
  block {
    if (sender =/= self.admin) then block {
      failwith("throw");
    } else block {
      skip
    };
    if (feeMake_ > self.feeMake) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.feeMake := feeMake_;
  } with ((nil: list(operation)), self);

function changeFeeTake (const self : state; const feeTake_ : nat) : (list(operation) * state) is
  block {
    if (sender =/= self.admin) then block {
      failwith("throw");
    } else block {
      skip
    };
    if ((feeTake_ > self.feeTake) or (feeTake_ < self.feeRebate)) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.feeTake := feeTake_;
  } with ((nil: list(operation)), self);

function changeFeeRebate (const self : state; const feeRebate_ : nat) : (list(operation) * state) is
  block {
    if (sender =/= self.admin) then block {
      failwith("throw");
    } else block {
      skip
    };
    if ((feeRebate_ < self.feeRebate) or (feeRebate_ > self.feeTake)) then block {
      failwith("throw");
    } else block {
      skip
    };
    self.feeRebate := feeRebate_;
  } with ((nil: list(operation)), self);

function deposit (const self : state) : (list(operation) * state) is
  block {
    (case self.tokens[0] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] := safeAdd(self, (case (case self.tokens[0] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end), (amount / 1mutez));
    (* EmitStatement Deposit(, sender, value, ) *)
  } with ((nil: list(operation)), self);

function withdraw (const self : state; const res__amount : nat) : (list(operation) * state) is
  block {
    if ((case (case self.tokens[0] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end) < res__amount) then block {
      failwith("throw");
    } else block {
      skip
    };
    (case self.tokens[0] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] := safeSub(self, (case (case self.tokens[0] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end), res__amount);
    (* EmitStatement Withdraw(, sender, amount, ) *)
  } with ((nil: list(operation)), self);

function depositToken (const self : state; const token : address; const res__amount : nat) : (list(operation) * state) is
  block {
    if (token = 0) then block {
      failwith("throw");
    } else block {
      skip
    };
    if (not ((* LIGO unsupported *)token(self, token).transferFrom(self, sender, , res__amount))) then block {
      failwith("throw");
    } else block {
      skip
    };
    (case self.tokens[token] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] := safeAdd(self, (case (case self.tokens[token] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end), res__amount);
    (* EmitStatement Deposit(token, sender, amount, ) *)
  } with ((nil: list(operation)), self);

function withdrawToken (const self : state; const token : address; const res__amount : nat) : (list(operation) * state) is
  block {
    if (token = 0) then block {
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
    if (not ((* LIGO unsupported *)token(self, token).transfer(self, sender, res__amount))) then block {
      failwith("throw");
    } else block {
      skip
    };
    (* EmitStatement Withdraw(token, sender, amount, ) *)
  } with ((nil: list(operation)), self);

function balanceOf (const self : state; const token : address; const user : address) : (list(operation) * nat) is
  block {
    skip
  } with ((nil: list(operation)));

function order (const self : state; const tokenGet : address; const amountGet : nat; const tokenGive : address; const amountGive : nat; const expires : nat; const nonce : nat) : (list(operation) * state) is
  block {
    const hash : bytes = sha_256();
    (case self.orders[sender] of | None -> (map end : map(bytes, bool)) | Some(x) -> x end)[hash] := True;
    (* EmitStatement Order(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, sender) *)
  } with ((nil: list(operation)), self);

function tradeBalances (const self : state; const tokenGet : address; const amountGet : nat; const tokenGive : address; const amountGive : nat; const user : address; const res__amount : nat) : (list(operation) * state) is
  block {
    const feeMakeXfer : nat = (safeMul(self, res__amount, self.feeMake) / (1 * 1000000));
    const feeTakeXfer : nat = (safeMul(self, res__amount, self.feeTake) / (1 * 1000000));
    const feeRebateXfer : nat = 0n;
    if (self.accountLevelsAddr =/= 0x0) then block {
      const accountLevel : nat = (* LIGO unsupported *)accountLevels(self, self.accountLevelsAddr).accountLevel(self, user);
      if (accountLevel = 1n) then block {
        feeRebateXfer := (safeMul(self, res__amount, self.feeRebate) / (1 * 1000000));
      } else block {
        skip
      };
      if (accountLevel = 2n) then block {
        feeRebateXfer := feeTakeXfer;
      } else block {
        skip
      };
    } else block {
      skip
    };
    (case self.tokens[tokenGet] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] := safeSub(self, (case (case self.tokens[tokenGet] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end), safeAdd(self, res__amount, feeTakeXfer));
    (case self.tokens[tokenGet] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[user] := safeAdd(self, (case (case self.tokens[tokenGet] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[user] of | None -> 0n | Some(x) -> x end), safeSub(self, safeAdd(self, res__amount, feeRebateXfer), feeMakeXfer));
    (case self.tokens[tokenGet] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[self.feeAccount] := safeAdd(self, (case (case self.tokens[tokenGet] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[self.feeAccount] of | None -> 0n | Some(x) -> x end), safeSub(self, safeAdd(self, feeMakeXfer, feeTakeXfer), feeRebateXfer));
    (case self.tokens[tokenGive] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[user] := safeSub(self, (case (case self.tokens[tokenGive] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[user] of | None -> 0n | Some(x) -> x end), (safeMul(self, amountGive, res__amount) / amountGet));
    (case self.tokens[tokenGive] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] := safeAdd(self, (case (case self.tokens[tokenGive] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[sender] of | None -> 0n | Some(x) -> x end), (safeMul(self, amountGive, res__amount) / amountGet));
  } with ((nil: list(operation)), self);

function trade (const self : state; const tokenGet : address; const amountGet : nat; const tokenGive : address; const amountGive : nat; const expires : nat; const nonce : nat; const user : address; const v : nat; const r : bytes; const s : bytes; const res__amount : nat) : (list(operation) * state) is
  block {
    const hash : bytes = sha_256();
    if not (((((case (case self.orders[user] of | None -> (map end : map(bytes, bool)) | Some(x) -> x end)[hash] of | None -> False | Some(x) -> x end) or (ecrecover(sha_256("\u0019Ethereum Signed Message:\n32"), v, r, s) = user)) and (0n <= expires)) and (safeAdd(self, (case (case self.orderFills[user] of | None -> (map end : map(bytes, nat)) | Some(x) -> x end)[hash] of | None -> 0n | Some(x) -> x end), res__amount) <= amountGet))) then block {
      failwith("throw");
    } else block {
      skip
    };
    tradeBalances(self, tokenGet, amountGet, tokenGive, amountGive, user, res__amount);
    (case self.orderFills[user] of | None -> (map end : map(bytes, nat)) | Some(x) -> x end)[hash] := safeAdd(self, (case (case self.orderFills[user] of | None -> (map end : map(bytes, nat)) | Some(x) -> x end)[hash] of | None -> 0n | Some(x) -> x end), res__amount);
    (* EmitStatement Trade(tokenGet, amount, tokenGive, , user, sender) *)
  } with ((nil: list(operation)), self);

function availableVolume (const self : state; const tokenGet : address; const amountGet : nat; const tokenGive : address; const amountGive : nat; const expires : nat; const nonce : nat; const user : address; const v : nat; const r : bytes; const s : bytes) : (list(operation) * nat) is
  block {
    const hash : bytes = sha_256();
    if not ((((case (case self.orders[user] of | None -> (map end : map(bytes, bool)) | Some(x) -> x end)[hash] of | None -> False | Some(x) -> x end) or (ecrecover(sha_256("\u0019Ethereum Signed Message:\n32"), v, r, s) = user)) and (0n <= expires))) then block {
      skip
    } with ((nil: list(operation))); else block {
      skip
    };
    const available1 : nat = safeSub(self, amountGet, (case (case self.orderFills[user] of | None -> (map end : map(bytes, nat)) | Some(x) -> x end)[hash] of | None -> 0n | Some(x) -> x end));
    const available2 : nat = (safeMul(self, (case (case self.tokens[tokenGive] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[user] of | None -> 0n | Some(x) -> x end), amountGet) / amountGive);
    if (available1 < available2) then block {
      skip
    } with ((nil: list(operation))); else block {
      skip
    };
  } with ((nil: list(operation)));

function testTrade (const self : state; const tokenGet : address; const amountGet : nat; const tokenGive : address; const amountGive : nat; const expires : nat; const nonce : nat; const user : address; const v : nat; const r : bytes; const s : bytes; const res__amount : nat; const res__sender : address) : (list(operation) * bool) is
  block {
    if not ((((case (case self.tokens[tokenGet] of | None -> (map end : map(address, nat)) | Some(x) -> x end)[res__sender] of | None -> 0n | Some(x) -> x end) >= res__amount) and (availableVolume(self, tokenGet, amountGet, tokenGive, amountGive, expires, nonce, user, v, r, s) >= res__amount))) then block {
      skip
    } with ((nil: list(operation))); else block {
      skip
    };
  } with ((nil: list(operation)));

function amountFilled (const self : state; const tokenGet : address; const amountGet : nat; const tokenGive : address; const amountGive : nat; const expires : nat; const nonce : nat; const user : address; const v : nat; const r : bytes; const s : bytes) : (list(operation) * nat) is
  block {
    const hash : bytes = sha_256();
  } with ((nil: list(operation)));

function cancelOrder (const self : state; const tokenGet : address; const amountGet : nat; const tokenGive : address; const amountGive : nat; const expires : nat; const nonce : nat; const v : nat; const r : bytes; const s : bytes) : (list(operation) * state) is
  block {
    const hash : bytes = sha_256();
    if not (((case (case self.orders[sender] of | None -> (map end : map(bytes, bool)) | Some(x) -> x end)[hash] of | None -> False | Some(x) -> x end) or (ecrecover(sha_256("\u0019Ethereum Signed Message:\n32"), v, r, s) = sender))) then block {
      failwith("throw");
    } else block {
      skip
    };
    (case self.orderFills[sender] of | None -> (map end : map(bytes, nat)) | Some(x) -> x end)[hash] := amountGet;
    (* EmitStatement Cancel(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, sender, v, r, s) *)
  } with ((nil: list(operation)), self);

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | Allowance(match_action) -> (allowance(self, match_action.owner_, match_action.spender_), self)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.owner_), self)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | Constructor(match_action) -> constructor(self)
  | Create(match_action) -> create(self, match_action.account, match_action.res__amount)
  | Destroy(match_action) -> destroy(self, match_action.account, match_action.res__amount)
  | AccountLevel(match_action) -> (accountLevel(self, match_action.user), self)
  | SetAccountLevel(match_action) -> setAccountLevel(self, match_action.user, match_action.level)
  | AccountLevel(match_action) -> (accountLevel(self, match_action.user), self)
  | Constructor(match_action) -> constructor(self, match_action.admin_, match_action.feeAccount_, match_action.accountLevelsAddr_, match_action.feeMake_, match_action.feeTake_, match_action.feeRebate_)
  | Fallback(match_action) -> fallback(self)
  | ChangeAdmin(match_action) -> changeAdmin(self, match_action.admin_)
  | ChangeAccountLevelsAddr(match_action) -> changeAccountLevelsAddr(self, match_action.accountLevelsAddr_)
  | ChangeFeeAccount(match_action) -> changeFeeAccount(self, match_action.feeAccount_)
  | ChangeFeeMake(match_action) -> changeFeeMake(self, match_action.feeMake_)
  | ChangeFeeTake(match_action) -> changeFeeTake(self, match_action.feeTake_)
  | ChangeFeeRebate(match_action) -> changeFeeRebate(self, match_action.feeRebate_)
  | Deposit(match_action) -> deposit(self)
  | Withdraw(match_action) -> 
  | DepositToken(match_action) -> depositToken(self, match_action.token, match_action.res__amount)
  | WithdrawToken(match_action) -> 
  | BalanceOf(match_action) -> (balanceOf(self, match_action.token, match_action.user), self)
  | Order(match_action) -> order(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce)
  | Trade(match_action) -> trade(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s, match_action.res__amount)
  | AvailableVolume(match_action) -> (availableVolume(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s), self)
  | TestTrade(match_action) -> (testTrade(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s, match_action.res__amount, match_action.res__sender), self)
  | AmountFilled(match_action) -> (amountFilled(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.user, match_action.v, match_action.r, match_action.s), self)
  | CancelOrder(match_action) -> cancelOrder(self, match_action.tokenGet, match_action.amountGet, match_action.tokenGive, match_action.amountGive, match_action.expires, match_action.nonce, match_action.v, match_action.r, match_action.s)
  end);
