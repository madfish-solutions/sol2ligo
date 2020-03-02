type constructor_args is record
  implementation_ : address;
  data_ : bytes;
end;

type admin_args is unit;
type implementation_args is unit;
type changeAdmin_args is record
  newAdmin : address;
end;

type upgradeTo_args is record
  newImplementation : address;
end;

type upgradeToAndCall_args is record
  newImplementation : address;
  data : bytes;
end;

type state is record
  IMPLEMENTATION_SLOT : bytes;
  ADMIN_SLOT : bytes;
end;
type state_UpgradeabilityProxy is record
  IMPLEMENTATION_SLOT : bytes;
end;
type state_AddressUtils is unit;

function addressUtils_isContract (const self : state_AddressUtils; const addr : address) : (bool) is
  block {
    const res__size : nat = 0n;
    (* InlineAssembly {
        size := extcodesize(addr)
    } *)
  } with ((res__size > 0n));
(* EventDefinition Upgraded(implementation : address) *)

function fallback (const self : state_Proxy) : (list(operation) * state_Proxy) is
  block {
    fallback_(self);
  } with ((nil: list(operation)), self);

function fallback_ (const self : state_Proxy) : (state_Proxy) is
  block {
    willFallback_(self);
    delegate_(self, implementation_(self));
  } with (self);

function implementation_ (const self : state_Proxy) : (address) is
  block {
    skip
  } with ();

function delegate_ (const self : state_Proxy; const implementation : address) : (state_Proxy) is
  block {
    (* InlineAssembly {
        calldatacopy(0, 0, calldatasize())
        let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
        returndatacopy(0, 0, returndatasize())
        switch result
        case 0 {
            revert(0, returndatasize())
        }
        default {
            return(0, returndatasize())
        }
    } *)
  } with (self);

function willFallback_ (const self : state_Proxy) : (state_Proxy) is
  block {
    skip
  } with (self);

function setImplementation_ (const self : state_UpgradeabilityProxy; const newImplementation : address) : (list(operation) * state_UpgradeabilityProxy) is
  block {
    assert(addressUtils.isContract(self, newImplementation)) (* "Cannot set a proxy implementation to a non-contract address" *);
    const slot : bytes = self.IMPLEMENTATION_SLOT;
    (* InlineAssembly {
        sstore(slot, newImplementation)
    } *)
  } with ((nil: list(operation)), self);

function constructor (const self : state_UpgradeabilityProxy; const implementation_ : address; const data_ : bytes) : (list(operation) * state_UpgradeabilityProxy) is
  block {
    assert((self.IMPLEMENTATION_SLOT = sha_256("org.zeppelinos.proxy.implementation")));
    setImplementation_(self, implementation_);
    if (size(data_) > 0n) then block {
      assert(var opList : list(operation) := list transaction(undefined, 1mutez, (get_contract(implementation_) : contract(data_))) end);
    } else block {
      skip
    };
  } with ((nil: list(operation)), self);

function implementation_ (const self : state_UpgradeabilityProxy) : (address) is
  block {
    const impl : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    const slot : bytes = self.IMPLEMENTATION_SLOT;
    (* InlineAssembly {
        impl := sload(slot)
    } *)
  } with (impl);

function upgradeTo_ (const self : state_UpgradeabilityProxy; const newImplementation : address) : (state_UpgradeabilityProxy) is
  block {
    setImplementation_(self, newImplementation);
    (* EmitStatement undefined(newImplementation) *)
  } with (self);
type router_enum is
  | Constructor of constructor_args
  | Admin of admin_args
  | Implementation of implementation_args
  | ChangeAdmin of changeAdmin_args
  | UpgradeTo of upgradeTo_args
  | UpgradeToAndCall of upgradeToAndCall_args;

(* EventDefinition AdminChanged(previousAdmin : address; newAdmin : address) *)

(* modifier ifAdmin inlined *)

function fallback (const self : state_Proxy) : (list(operation) * state_Proxy) is
  block {
    fallback_(self);
  } with ((nil: list(operation)), self);

function fallback_ (const self : state_Proxy) : (state_Proxy) is
  block {
    willFallback_(self);
    delegate_(self, implementation_(self));
  } with (self);

function implementation_ (const self : state_Proxy) : (address) is
  block {
    skip
  } with ();

function delegate_ (const self : state_Proxy; const implementation : address) : (state_Proxy) is
  block {
    (* InlineAssembly {
        calldatacopy(0, 0, calldatasize())
        let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
        returndatacopy(0, 0, returndatasize())
        switch result
        case 0 {
            revert(0, returndatasize())
        }
        default {
            return(0, returndatasize())
        }
    } *)
  } with (self);

function willFallback_ (const self : state_Proxy) : (state_Proxy) is
  block {
    skip
  } with (self);

function upgradeTo_ (const self : state_UpgradeabilityProxy; const newImplementation : address) : (state_UpgradeabilityProxy) is
  block {
    setImplementation_(self, newImplementation);
    (* EmitStatement undefined(newImplementation) *)
  } with (self);

function implementation_ (const self : state_UpgradeabilityProxy) : (address) is
  block {
    const impl : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    const slot : bytes = self.IMPLEMENTATION_SLOT;
    (* InlineAssembly {
        impl := sload(slot)
    } *)
  } with (impl);

function upgradeabilityProxy_constructor (const self : state_UpgradeabilityProxy; const implementation_ : address; const data_ : bytes) : (list(operation) * state_UpgradeabilityProxy) is
  block {
    assert((self.IMPLEMENTATION_SLOT = sha_256("org.zeppelinos.proxy.implementation")));
    setImplementation_(self, implementation_);
    if (size(data_) > 0n) then block {
      assert(var opList : list(operation) := list transaction(undefined, 1mutez, (get_contract(implementation_) : contract(data_))) end);
    } else block {
      skip
    };
  } with ((nil: list(operation)), self);

function setImplementation_ (const self : state_UpgradeabilityProxy; const newImplementation : address) : (list(operation) * state_UpgradeabilityProxy) is
  block {
    assert(addressUtils.isContract(self, newImplementation)) (* "Cannot set a proxy implementation to a non-contract address" *);
    const slot : bytes = self.IMPLEMENTATION_SLOT;
    (* InlineAssembly {
        sstore(slot, newImplementation)
    } *)
  } with ((nil: list(operation)), self);

function admin_ (const self : state) : (address) is
  block {
    const adm : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    const slot : bytes = self.ADMIN_SLOT;
    (* InlineAssembly {
        adm := sload(slot)
    } *)
  } with (adm);

function setAdmin_ (const self : state; const newAdmin : address) : (state) is
  block {
    const slot : bytes = self.ADMIN_SLOT;
    (* InlineAssembly {
        sstore(slot, newAdmin)
    } *)
  } with (self);

function constructor (const self : state; const implementation_ : address; const data_ : bytes) : (list(operation) * state) is
  block {
    upgradeabilityProxy_constructor(self);
    assert((self.IMPLEMENTATION_SLOT = sha_256("org.zeppelinos.proxy.implementation")));
    setImplementation_(self, implementation_);
    if (size(data_) > 0n) then block {
      assert(var opList : list(operation) := list transaction(undefined, 1mutez, (get_contract(implementation_) : contract(data_))) end);
    } else block {
      skip
    };
  } with ((nil: list(operation)), self);

function admin (const self : state) : (list(operation)) is
  block {
    if (sender = admin_(self)) then block {
      skip
    } else block {
      fallback_(self);
    };
  } with ((nil: list(operation)));

function implementation (const self : state) : (list(operation)) is
  block {
    if (sender = admin_(self)) then block {
      skip
    } else block {
      fallback_(self);
    };
  } with ((nil: list(operation)));

function changeAdmin (const self : state; const newAdmin : address) : (list(operation) * state) is
  block {
    if (sender = admin_(self)) then block {
      assert((newAdmin =/= ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address))) (* "Cannot change the admin of a proxy to the zero address" *);
      (* EmitStatement undefined(, newAdmin) *)
      setAdmin_(self, newAdmin);
    } else block {
      fallback_(self);
    };
  } with ((nil: list(operation)), self);

function upgradeTo (const self : state; const newImplementation : address) : (list(operation) * state) is
  block {
    if (sender = admin_(self)) then block {
      upgradeTo_(self, newImplementation);
    } else block {
      fallback_(self);
    };
  } with ((nil: list(operation)), self);

function upgradeToAndCall (const self : state; const newImplementation : address; const data : bytes) : (list(operation) * state) is
  block {
    if (sender = admin_(self)) then block {
      upgradeTo_(self, newImplementation);
      assert(var opList : list(operation) := list transaction(undefined, 1mutez, (get_contract(newImplementation) : contract(data))) end);
    } else block {
      fallback_(self);
    };
  } with ((nil: list(operation)), self);

function willFallback_ (const self : state) : (state) is
  block {
    assert((sender =/= admin_(self))) (* "Cannot call fallback function from the proxy admin" *);
    super.willFallback_(self);
  } with (self);

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Constructor(match_action) -> constructor(self, match_action.implementation_, match_action.data_)
  | Admin(match_action) -> (admin(self), self)
  | Implementation(match_action) -> (implementation(self), self)
  | ChangeAdmin(match_action) -> changeAdmin(self, match_action.newAdmin)
  | UpgradeTo(match_action) -> upgradeTo(self, match_action.newImplementation)
  | UpgradeToAndCall(match_action) -> upgradeToAndCall(self, match_action.newImplementation, match_action.data)
  end);
