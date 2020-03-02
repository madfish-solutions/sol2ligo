type constructor_args is record
  resolver_ : address;
end;

type totalSupply_args is record
  receiver : contract(unit);
end;

type balanceOf_args is record
  receiver : contract(unit);
  owner_ : address;
end;

type transfer_args is record
  to_ : address;
  value_ : nat;
end;

type transferFrom_args is record
  from_ : address;
  to_ : address;
  value_ : nat;
end;

type transferAndCall_args is record
  receiver_ : address;
  amount_ : nat;
  data_ : bytes;
end;

type approve_args is record
  spender_ : address;
  value_ : nat;
end;

type allowance_args is record
  receiver : contract(unit);
  owner_ : address;
  spender_ : address;
end;

type state is record
  CONTRACT_ADDRESS : address;
  key : bytes;
  resolver : address;
  CONTRACT_TRANSFER_FEES_DISTRIBUTOR : bytes;
  CONTRACT_RECAST_FEES_DISTRIBUTOR : bytes;
  CONTRACT_DEMURRAGE_FEES_DISTRIBUTOR : bytes;
  CONTRACT_SERVICE_DIRECTORY : bytes;
  CONTRACT_SERVICE_MARKETPLACE : bytes;
  CONTRACT_SERVICE_TOKEN_DEMURRAGE : bytes;
  CONTRACT_STORAGE_IDENTITY : bytes;
  CONTRACT_STORAGE_JOB_ID : bytes;
  CONTRACT_STORAGE_GOLD_TOKEN : bytes;
  CONTRACT_STORAGE_PRODUCTS_LIST : bytes;
  CONTRACT_STORAGE_MARKETPLACE : bytes;
  CONTRACT_STORAGE_DIGIX_DIRECTORY : bytes;
  CONTRACT_STORAGE_ASSET_EVENTS : bytes;
  CONTRACT_STORAGE_ASSETS : bytes;
  CONTRACT_CONTROLLER_IDENTITY : bytes;
  CONTRACT_CONTROLLER_JOB_ID : bytes;
  CONTRACT_CONTROLLER_TOKEN_TRANSFER : bytes;
  CONTRACT_CONTROLLER_TOKEN_INFO : bytes;
  CONTRACT_CONTROLLER_TOKEN_CONFIG : bytes;
  CONTRACT_CONTROLLER_TOKEN_APPROVAL : bytes;
  CONTRACT_CONTROLLER_PRODUCTS_LIST : bytes;
  CONTRACT_CONTROLLER_MARKETPLACE_ADMIN : bytes;
  CONTRACT_CONTROLLER_MARKETPLACE : bytes;
  CONTRACT_CONTROLLER_DIGIX_DIRECTORY : bytes;
  CONTRACT_CONTROLLER_ASSETS_EXPLORER : bytes;
  CONTRACT_CONTROLLER_ASSETS_RECAST : bytes;
  CONTRACT_CONTROLLER_ASSETS : bytes;
  CONTRACT_INTERACTIVE_IDENTITY : bytes;
  CONTRACT_INTERACTIVE_MARKETPLACE_INFORMATION : bytes;
  CONTRACT_INTERACTIVE_TOKEN_INFORMATION : bytes;
  CONTRACT_INTERACTIVE_TOKEN_CONFIG : bytes;
  CONTRACT_INTERACTIVE_BULK_WRAPPER : bytes;
  CONTRACT_INTERACTIVE_TOKEN : bytes;
  CONTRACT_INTERACTIVE_PRODUCTS_LIST : bytes;
  CONTRACT_INTERACTIVE_POPADMIN : bytes;
  CONTRACT_INTERACTIVE_MARKETPLACE_ADMIN : bytes;
  CONTRACT_INTERACTIVE_MARKETPLACE : bytes;
  CONTRACT_INTERACTIVE_DIGIX_DIRECTORY : bytes;
  CONTRACT_INTERACTIVE_ASSETS_EXPLORER : bytes;
  STATE_ADMIN_FAILURE : nat;
  STATE_REDEEMED : nat;
  STATE_RECASTED : nat;
  STATE_REPLACEMENT_DELIVERY : nat;
  STATE_REPLACEMENT_ORDER : nat;
  STATE_AUDIT_FAILURE : nat;
  STATE_MINTED : nat;
  STATE_CUSTODIAN_DELIVERY : nat;
  STATE_TRANSFER : nat;
  STATE_VENDOR_ORDER : nat;
  STATE_CREATED : nat;
  STATE_ZERO_UNDEFINED : nat;
  ROLE_FEES_DISTRIBUTION_ADMIN : nat;
  ROLE_KYC_RECASTER : nat;
  ROLE_DOCS_UPLOADER : nat;
  ROLE_FEES_ADMIN : nat;
  ROLE_KYC_ADMIN : nat;
  ROLE_MARKETPLACE_ADMIN : nat;
  ROLE_AUDITOR : nat;
  ROLE_CUSTODIAN : nat;
  ROLE_POPADMIN : nat;
  ROLE_XFERAUTH : nat;
  ROLE_VENDOR : nat;
  ROLE_ROOT : nat;
  ROLE_ZERO_ANYONE : nat;
  ASSET_EVENT_REMINTED : nat;
  ASSET_EVENT_ADMIN_FAILED : nat;
  ASSET_EVENT_FAILED_AUDIT : nat;
  ASSET_EVENT_REDEEMED : nat;
  ASSET_EVENT_RECASTED : nat;
  ASSET_EVENT_MINTED_REPLACEMENT : nat;
  ASSET_EVENT_MINTED : nat;
  ASSET_EVENT_FULFILLED_REPLACEMENT_ORDER : nat;
  ASSET_EVENT_FULFILLED_TRANSFER_ORDER : nat;
  ASSET_EVENT_FULFILLED_VENDOR_ORDER : nat;
  ASSET_EVENT_CREATED_REPLACEMENT_ORDER : nat;
  ASSET_EVENT_CREATED_TRANSFER_ORDER : nat;
  ASSET_EVENT_CREATED_VENDOR_ORDER : nat;
  SECONDS_IN_A_DAY : nat;
  name : string;
  symbol : string;
  decimals : nat;
end;
type state_TokenReceiver is unit;
type state_TokenApprovalController is unit;
type state_TokenTransferController is unit;
type state_TokenInfoController is unit;
type state_TokenLoggerCallback is record
  CONTRACT_ADDRESS : address;
  key : bytes;
  resolver : address;
  CONTRACT_TRANSFER_FEES_DISTRIBUTOR : bytes;
  CONTRACT_RECAST_FEES_DISTRIBUTOR : bytes;
  CONTRACT_DEMURRAGE_FEES_DISTRIBUTOR : bytes;
  CONTRACT_SERVICE_DIRECTORY : bytes;
  CONTRACT_SERVICE_MARKETPLACE : bytes;
  CONTRACT_SERVICE_TOKEN_DEMURRAGE : bytes;
  CONTRACT_STORAGE_IDENTITY : bytes;
  CONTRACT_STORAGE_JOB_ID : bytes;
  CONTRACT_STORAGE_GOLD_TOKEN : bytes;
  CONTRACT_STORAGE_PRODUCTS_LIST : bytes;
  CONTRACT_STORAGE_MARKETPLACE : bytes;
  CONTRACT_STORAGE_DIGIX_DIRECTORY : bytes;
  CONTRACT_STORAGE_ASSET_EVENTS : bytes;
  CONTRACT_STORAGE_ASSETS : bytes;
  CONTRACT_CONTROLLER_IDENTITY : bytes;
  CONTRACT_CONTROLLER_JOB_ID : bytes;
  CONTRACT_CONTROLLER_TOKEN_TRANSFER : bytes;
  CONTRACT_CONTROLLER_TOKEN_INFO : bytes;
  CONTRACT_CONTROLLER_TOKEN_CONFIG : bytes;
  CONTRACT_CONTROLLER_TOKEN_APPROVAL : bytes;
  CONTRACT_CONTROLLER_PRODUCTS_LIST : bytes;
  CONTRACT_CONTROLLER_MARKETPLACE_ADMIN : bytes;
  CONTRACT_CONTROLLER_MARKETPLACE : bytes;
  CONTRACT_CONTROLLER_DIGIX_DIRECTORY : bytes;
  CONTRACT_CONTROLLER_ASSETS_EXPLORER : bytes;
  CONTRACT_CONTROLLER_ASSETS_RECAST : bytes;
  CONTRACT_CONTROLLER_ASSETS : bytes;
  CONTRACT_INTERACTIVE_IDENTITY : bytes;
  CONTRACT_INTERACTIVE_MARKETPLACE_INFORMATION : bytes;
  CONTRACT_INTERACTIVE_TOKEN_INFORMATION : bytes;
  CONTRACT_INTERACTIVE_TOKEN_CONFIG : bytes;
  CONTRACT_INTERACTIVE_BULK_WRAPPER : bytes;
  CONTRACT_INTERACTIVE_TOKEN : bytes;
  CONTRACT_INTERACTIVE_PRODUCTS_LIST : bytes;
  CONTRACT_INTERACTIVE_POPADMIN : bytes;
  CONTRACT_INTERACTIVE_MARKETPLACE_ADMIN : bytes;
  CONTRACT_INTERACTIVE_MARKETPLACE : bytes;
  CONTRACT_INTERACTIVE_DIGIX_DIRECTORY : bytes;
  CONTRACT_INTERACTIVE_ASSETS_EXPLORER : bytes;
  STATE_ADMIN_FAILURE : nat;
  STATE_REDEEMED : nat;
  STATE_RECASTED : nat;
  STATE_REPLACEMENT_DELIVERY : nat;
  STATE_REPLACEMENT_ORDER : nat;
  STATE_AUDIT_FAILURE : nat;
  STATE_MINTED : nat;
  STATE_CUSTODIAN_DELIVERY : nat;
  STATE_TRANSFER : nat;
  STATE_VENDOR_ORDER : nat;
  STATE_CREATED : nat;
  STATE_ZERO_UNDEFINED : nat;
  ROLE_FEES_DISTRIBUTION_ADMIN : nat;
  ROLE_KYC_RECASTER : nat;
  ROLE_DOCS_UPLOADER : nat;
  ROLE_FEES_ADMIN : nat;
  ROLE_KYC_ADMIN : nat;
  ROLE_MARKETPLACE_ADMIN : nat;
  ROLE_AUDITOR : nat;
  ROLE_CUSTODIAN : nat;
  ROLE_POPADMIN : nat;
  ROLE_XFERAUTH : nat;
  ROLE_VENDOR : nat;
  ROLE_ROOT : nat;
  ROLE_ZERO_ANYONE : nat;
  ASSET_EVENT_REMINTED : nat;
  ASSET_EVENT_ADMIN_FAILED : nat;
  ASSET_EVENT_FAILED_AUDIT : nat;
  ASSET_EVENT_REDEEMED : nat;
  ASSET_EVENT_RECASTED : nat;
  ASSET_EVENT_MINTED_REPLACEMENT : nat;
  ASSET_EVENT_MINTED : nat;
  ASSET_EVENT_FULFILLED_REPLACEMENT_ORDER : nat;
  ASSET_EVENT_FULFILLED_TRANSFER_ORDER : nat;
  ASSET_EVENT_FULFILLED_VENDOR_ORDER : nat;
  ASSET_EVENT_CREATED_REPLACEMENT_ORDER : nat;
  ASSET_EVENT_CREATED_TRANSFER_ORDER : nat;
  ASSET_EVENT_CREATED_VENDOR_ORDER : nat;
  SECONDS_IN_A_DAY : nat;
end;
type state_ContractResolver is record
  owner : address;
  locked : bool;
end;

function init_register_contract (const self : state_ContractResolver; const key_ : bytes; const contract_address_ : address) : (list(operation) * state_ContractResolver * bool) is
  block {
    const success_ : bool = False;
  } with ((nil: list(operation)), self, success_);

function unregister_contract (const self : state_ContractResolver; const key_ : bytes) : (list(operation) * state_ContractResolver * bool) is
  block {
    const success_ : bool = False;
  } with ((nil: list(operation)), self, success_);

function res__get_contract (const self : state_ContractResolver; const receiver : contract(unit); const key_ : bytes) : (list(operation)) is
  block {
    const contract_ : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
  } with ((nil: list(operation)));
function res__get_contract (const self : state_ResolverClient; const receiver : contract(unit); const key_ : bytes) : (list(operation)) is
  block {
    const contract_ : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    contract_ := (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, key_);
  } with ((nil: list(operation)));

function destroy (const self : state_ResolverClient) : (list(operation) * state_ResolverClient * bool) is
  block {
    const success_ : bool = False;
    const is_locked_ : bool = (* LIGO unsupported *)contractResolver(self, self.resolver).locked(self);
    assert(not (is_locked_));
    const owner_of_contract_resolver_ : address = (* LIGO unsupported *)contractResolver(self, self.resolver).owner(self);
    assert((sender = owner_of_contract_resolver_));
    success_ := (* LIGO unsupported *)contractResolver(self, self.resolver).unregister_contract(self, self.key);
    assert(success_);
    selfdestruct(owner_of_contract_resolver_);
  } with ((nil: list(operation)), self, success_);

function init (const self : state_ResolverClient; const key_ : bytes; const resolver_ : address) : (state_ResolverClient * bool) is
  block {
    const success_ : bool = False;
    const is_locked_ : bool = (* LIGO unsupported *)contractResolver(self, resolver_).locked(self);
    if bitwise_not(bitwise_xor(is_locked_, False)) then block {
      self.CONTRACT_ADDRESS := self_address;
      self.resolver := resolver_;
      self.key := key_;
      assert((* LIGO unsupported *)contractResolver(self, self.resolver).init_register_contract(self, self.key, self.CONTRACT_ADDRESS));
      success_ := True;
    } else block {
      success_ := False;
    };
  } with (self, success_);

function is_locked (const self : state_ResolverClient) : (bool) is
  block {
    const locked_ : bool = False;
    locked_ := (* LIGO unsupported *)contractResolver(self, self.resolver).locked(self);
  } with (locked_);

function log_mint (const self : state_TokenLoggerCallback; const to_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_CONTROLLER_ASSETS;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);

function log_recast_fees (const self : state_TokenLoggerCallback; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_CONTROLLER_ASSETS_RECAST;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);

function log_recast (const self : state_TokenLoggerCallback; const from_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_CONTROLLER_ASSETS_RECAST;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);

function log_demurrage_fees (const self : state_TokenLoggerCallback; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_SERVICE_TOKEN_DEMURRAGE;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);

function log_move_fees (const self : state_TokenLoggerCallback; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_CONTROLLER_TOKEN_CONFIG;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);

function log_transfer (const self : state_TokenLoggerCallback; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_CONTROLLER_TOKEN_TRANSFER;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);

function log_approve (const self : state_TokenLoggerCallback; const owner_ : address; const spender_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_CONTROLLER_TOKEN_APPROVAL;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);
function get_total_supply (const self : state_TokenInfoController; const receiver : contract(unit)) : (list(operation)) is
  block {
    const total_supply_ : nat = 0n;
  } with ((nil: list(operation)));

function get_allowance (const self : state_TokenInfoController; const receiver : contract(unit); const account_ : address; const spender_ : address) : (list(operation)) is
  block {
    const allowance_ : nat = 0n;
  } with ((nil: list(operation)));

function get_balance (const self : state_TokenInfoController; const receiver : contract(unit); const user_ : address) : (list(operation)) is
  block {
    const actual_balance_ : nat = 0n;
  } with ((nil: list(operation)));
function put_transfer (const self : state_TokenTransferController; const sender_ : address; const recipient_ : address; const spender_ : address; const amount_ : nat; const transfer_from_ : bool) : (list(operation) * state_TokenTransferController * bool) is
  block {
    const success_ : bool = False;
  } with ((nil: list(operation)), self, success_);
function approve (const self : state_TokenApprovalController; const account_ : address; const spender_ : address; const amount_ : nat) : (list(operation) * state_TokenApprovalController * bool) is
  block {
    const success_ : bool = False;
  } with ((nil: list(operation)), self, success_);
function tokenFallback (const self : state_TokenReceiver; const from : address; const res__amount : nat; const data : bytes) : (list(operation) * state_TokenReceiver * bool) is
  block {
    const success : bool = False;
  } with ((nil: list(operation)), self, success);
type router_enum is
  | Constructor of constructor_args
  | TotalSupply of totalSupply_args
  | BalanceOf of balanceOf_args
  | Transfer of transfer_args
  | TransferFrom of transferFrom_args
  | TransferAndCall of transferAndCall_args
  | Approve of approve_args
  | Allowance of allowance_args;

function res__get_contract (const self : state_ResolverClient; const receiver : contract(unit); const key_ : bytes) : (list(operation)) is
  block {
    const contract_ : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    contract_ := (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, key_);
  } with ((nil: list(operation)));

function destroy (const self : state_ResolverClient) : (list(operation) * state_ResolverClient * bool) is
  block {
    const success_ : bool = False;
    const is_locked_ : bool = (* LIGO unsupported *)contractResolver(self, self.resolver).locked(self);
    assert(not (is_locked_));
    const owner_of_contract_resolver_ : address = (* LIGO unsupported *)contractResolver(self, self.resolver).owner(self);
    assert((sender = owner_of_contract_resolver_));
    success_ := (* LIGO unsupported *)contractResolver(self, self.resolver).unregister_contract(self, self.key);
    assert(success_);
    selfdestruct(owner_of_contract_resolver_);
  } with ((nil: list(operation)), self, success_);

function init (const self : state_ResolverClient; const key_ : bytes; const resolver_ : address) : (state_ResolverClient * bool) is
  block {
    const success_ : bool = False;
    const is_locked_ : bool = (* LIGO unsupported *)contractResolver(self, resolver_).locked(self);
    if bitwise_not(bitwise_xor(is_locked_, False)) then block {
      self.CONTRACT_ADDRESS := self_address;
      self.resolver := resolver_;
      self.key := key_;
      assert((* LIGO unsupported *)contractResolver(self, self.resolver).init_register_contract(self, self.key, self.CONTRACT_ADDRESS));
      success_ := True;
    } else block {
      success_ := False;
    };
  } with (self, success_);

function is_locked (const self : state_ResolverClient) : (bool) is
  block {
    const locked_ : bool = False;
    locked_ := (* LIGO unsupported *)contractResolver(self, self.resolver).locked(self);
  } with (locked_);

function log_approve (const self : state_TokenLoggerCallback; const owner_ : address; const spender_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_CONTROLLER_TOKEN_APPROVAL;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);

function log_transfer (const self : state_TokenLoggerCallback; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_CONTROLLER_TOKEN_TRANSFER;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);

function log_move_fees (const self : state_TokenLoggerCallback; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_CONTROLLER_TOKEN_CONFIG;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);

function log_demurrage_fees (const self : state_TokenLoggerCallback; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_SERVICE_TOKEN_DEMURRAGE;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);

function log_recast (const self : state_TokenLoggerCallback; const from_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_CONTROLLER_ASSETS_RECAST;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);

function log_recast_fees (const self : state_TokenLoggerCallback; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_CONTROLLER_ASSETS_RECAST;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);

function log_mint (const self : state_TokenLoggerCallback; const to_ : address; const value_ : nat) : (list(operation) * state_TokenLoggerCallback) is
  block {
    const contract_ : bytes = self.CONTRACT_CONTROLLER_ASSETS;
    assert((sender = (* LIGO unsupported *)contractResolver(self, self.resolver).res__get_contract(self, contract_)));
  } with ((nil: list(operation)), self);

function constructor (const self : state; const resolver_ : address) : (list(operation) * state) is
  block {
    assert(init(self, self.CONTRACT_INTERACTIVE_TOKEN, resolver_));
  } with ((nil: list(operation)), self);

function totalSupply (const self : state; const receiver : contract(unit)) : (list(operation)) is
  block {
    const total_supply_ : nat = 0n;
    total_supply_ := (* LIGO unsupported *)tokenInfoController(self, res__get_contract(self, self.CONTRACT_CONTROLLER_TOKEN_INFO)).get_total_supply(self);
  } with ((nil: list(operation)));

function balanceOf (const self : state; const receiver : contract(unit); const owner_ : address) : (list(operation)) is
  block {
    const res__balance : nat = 0n;
    res__balance := (* LIGO unsupported *)tokenInfoController(self, res__get_contract(self, self.CONTRACT_CONTROLLER_TOKEN_INFO)).get_balance(self, owner_);
  } with ((nil: list(operation)));

function transfer (const self : state; const to_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    success := (* LIGO unsupported *)tokenTransferController(self, res__get_contract(self, self.CONTRACT_CONTROLLER_TOKEN_TRANSFER)).put_transfer(self, sender, to_, 0x0n, value_, False);
  } with ((nil: list(operation)), self, success);

function transferFrom (const self : state; const from_ : address; const to_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    success := (* LIGO unsupported *)tokenTransferController(self, res__get_contract(self, self.CONTRACT_CONTROLLER_TOKEN_TRANSFER)).put_transfer(self, from_, to_, sender, value_, True);
  } with ((nil: list(operation)), self, success);

function transferAndCall (const self : state; const receiver_ : address; const amount_ : nat; const data_ : bytes) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    transfer(self, receiver_, amount_);
    success := (* LIGO unsupported *)tokenReceiver(self, receiver_).tokenFallback(self, sender, amount_, data_);
    assert(success);
  } with ((nil: list(operation)), self, success);

function approve (const self : state; const spender_ : address; const value_ : nat) : (list(operation) * state * bool) is
  block {
    const success : bool = False;
    success := (* LIGO unsupported *)tokenApprovalController(self, res__get_contract(self, self.CONTRACT_CONTROLLER_TOKEN_APPROVAL)).approve(self, sender, spender_, value_);
  } with ((nil: list(operation)), self, success);

function allowance (const self : state; const receiver : contract(unit); const owner_ : address; const spender_ : address) : (list(operation)) is
  block {
    const remaining : nat = 0n;
    remaining := (* LIGO unsupported *)tokenInfoController(self, res__get_contract(self, self.CONTRACT_CONTROLLER_TOKEN_INFO)).get_allowance(self, owner_, spender_);
  } with ((nil: list(operation)));

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Constructor(match_action) -> constructor(self, match_action.resolver_)
  | TotalSupply(match_action) -> (totalSupply(self, match_action.receiver), self)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.receiver, match_action.owner_), self)
  | Transfer(match_action) -> transfer(self, match_action.to_, match_action.value_)
  | TransferFrom(match_action) -> transferFrom(self, match_action.from_, match_action.to_, match_action.value_)
  | TransferAndCall(match_action) -> transferAndCall(self, match_action.receiver_, match_action.amount_, match_action.data_)
  | Approve(match_action) -> approve(self, match_action.spender_, match_action.value_)
  | Allowance(match_action) -> (allowance(self, match_action.receiver, match_action.owner_, match_action.spender_), self)
  end);
