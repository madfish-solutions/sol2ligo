config = require("../src/config")
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo real contracts section", ()->
  # all these tests are ridiculously broken
  return
  @timeout 10000
  # ###################################################################################################
  #    simple coin
  # ###################################################################################################
  # NOTE initialized is removed
  it "simple coin", ()->
    text_i = """
    pragma solidity >=0.5.0 <0.6.0;
    
    contract SimpleCoin {
        mapping(address => uint) public balances;
        
        constructor() public {
            balances[msg.sender] = 1000000;
        }
        
        function transfer(address to, uint amount) public {
            require(balances[msg.sender] >= amount, "Overdrawn balance");
            balances[msg.sender] -= amount;
            balances[to] += amount;
        }
    }
    """#"
    
    text_o = """
    type constructor_args is record
      #{config.empty_state} : int;
    end;
    
    type transfer_args is record
      #{config.reserved}__to : address;
      #{config.reserved}__amount : nat;
    end;
    
    type state is record
      balances : map(address, nat);
    end;
    
    function constructor (const contract_storage : state) : (list(operation) * state) is
      block {
        contract_storage.balances[sender] := 1000000n;
      } with (contract_storage);
    
    function transfer (const contract_storage : state; const #{config.reserved}__to : address; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        if ((case contract_storage.balances[sender] of | None -> 0n | Some(x) -> x end) >= #{config.reserved}__amount) then {skip} else failwith("Overdrawn balance");
        contract_storage.balances[sender] := abs((case contract_storage.balances[sender] of | None -> 0n | Some(x) -> x end) - #{config.reserved}__amount);
        contract_storage.balances[#{config.reserved}__to] := ((case contract_storage.balances[#{config.reserved}__to] of | None -> 0n | Some(x) -> x end) + #{config.reserved}__amount);
      } with (contract_storage);
    
    type router_enum is
      | Constructor of constructor_args
      | Transfer of transfer_args;
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        if (contract_storage.reserved__initialized) then block {
          case action of
          | Constructor(match_action) -> block {
            const tmp_0 : (list(operation) * state) = constructor(contract_storage);
            opList := tmp_0.0;
            contract_storage := tmp_0.1;
          }
          | Transfer(match_action) -> block {
            const tmp_1 : (list(operation) * state) = transfer(contract_storage, match_action.#{config.reserved}__to, match_action.#{config.reserved}__amount);
            opList := tmp_1.0;
            contract_storage := tmp_1.1;
          }
          end;
        } else block {
          contract_storage.reserved__initialized := True;
        };
      } with (contract_storage);
    """#"
    make_test text_i, text_o, {
      router: true
    }
  
  # ###################################################################################################
  #    ownable
  # ###################################################################################################
  ###
    fixes:
      this removed
      decl order swapped for transferOwnership, _transferOwnership
      msg.data removed
  ###
  it "ownable (BROKEN isOwner transaction)", ()->
    text_i = """
    pragma solidity ^0.5.0;
    
    contract Context {
        // Empty internal constructor, to prevent people from mistakenly deploying
        // an instance of this contract, which should be used via inheritance.
        constructor () internal { }
        // solhint-disable-previous-line no-empty-blocks
    
        function _msgSender() internal view returns (address payable) {
            return msg.sender;
        }
    }
    /**
    * @dev Contract module which provides a basic access control mechanism, where
    * there is an account (an owner) that can be granted exclusive access to
    * specific functions.
    *
    * This module is used through inheritance. It will make available the modifier
    * `onlyOwner`, which can be applied to your functions to restrict their use to
    * the owner.
    */
    contract Ownable is Context {
        address private _owner;
    
        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
        /**
        * @dev Initializes the contract setting the deployer as the initial owner.
        */
        constructor () internal {
            address msgSender = _msgSender();
            _owner = msgSender;
            emit OwnershipTransferred(address(0), msgSender);
        }
    
        /**
        * @dev Returns the address of the current owner.
        */
        function owner() public view returns (address) {
            return _owner;
        }
    
        /**
        * @dev Throws if called by any account other than the owner.
        */
        modifier onlyOwner() {
            require(isOwner(), "Ownable: caller is not the owner");
            _;
        }
    
        /**
        * @dev Returns true if the caller is the current owner.
        */
        function isOwner() public view returns (bool) {
            return _msgSender() == _owner;
        }
    
        /**
        * @dev Leaves the contract without owner. It will not be possible to call
        * `onlyOwner` functions anymore. Can only be called by the current owner.
        *
        * NOTE: Renouncing ownership will leave the contract without an owner,
        * thereby removing any functionality that is only available to the owner.
        */
        function renounceOwnership() public onlyOwner {
            emit OwnershipTransferred(_owner, address(0));
            _owner = address(0);
        }
    
        /**
        * @dev Transfers ownership of the contract to a new account (`newOwner`).
        */
        function _transferOwnership(address newOwner) internal {
            require(newOwner != address(0), "Ownable: new owner is the zero address");
            emit OwnershipTransferred(_owner, newOwner);
            _owner = newOwner;
        }
    
        /**
        * @dev Transfers ownership of the contract to a new account (`newOwner`).
        * Can only be called by the current owner.
        */
        function transferOwnership(address newOwner) public onlyOwner {
            _transferOwnership(newOwner);
        }
    }
    """#"
    
    text_o = """
    type owner_args is record
      receiver : contract(address);
    end;
    
    type isOwner_args is record
      receiver : contract(bool);
    end;
    
    type renounceOwnership_args is unit;
    
    type transferOwnership_args is record
      newOwner : address;
    end;
    
    type state is record
      owner_ : address;
    end;
    
    const burn_address : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
    type router_enum is
      | Owner of owner_args
     | IsOwner of isOwner_args
     | RenounceOwnership of renounceOwnership_args
     | TransferOwnership of transferOwnership_args;
    
    (* EventDefinition OwnershipTransferred(previousOwner : address; newOwner : address) *)
    
    (* modifier onlyOwner inlined *)
    
    function msgSender_ (const contract_storage : state) : (list(operation) * state * address) is
      block {
        skip
      } with (contract_storage, sender);
    
    function context_constructor (const contract_storage : state) : (list(operation) * state) is
      block {
        skip
      } with (contract_storage);
    
    function constructor (const contract_storage : state) : (list(operation) * state) is
      block {
        const tmp_0 : (list(operation) * state) = context_constructor(contract_storage);
        opList := tmp_0.0;
        contract_storage := tmp_0.1;
        const tmp_1 : (list(operation) * state * address) = msgSender_(contract_storage);
        opList := tmp_1.0;
        contract_storage := tmp_1.1;
        const msgSender : address = tmp_1.2;
        contract_storage.owner_ := msgSender;
        (* EmitStatement *);
      } with (contract_storage);
    
    function owner (const contract_storage : state) : (list(operation) * state * address) is
      block {
        skip
      } with (contract_storage, contract_storage.owner_);
    
    function isOwner (const contract_storage : state; const receiver : contract(bool)) : (list(operation) * state * bool) is
      block {
        const tmp_0 : (list(operation) * state * address) = msgSender_(contract_storage);
        opList := tmp_0.0;
        contract_storage := tmp_0.1;
      } with (contract_storage, (tmp_0.2 = contract_storage.owner_));
    
    function renounceOwnership (const contract_storage : state) : (list(operation) * state) is
      block {
        assert(isOwner(contract_storage)) (* "Ownable: caller is not the owner" *);
        (* EmitStatement OwnershipTransferred(_owner, ) *);
        contract_storage.owner_ := burn_address;
      } with ((nil: list(operation)), contract_storage);
    
    function transferOwnership_ (const contract_storage : state; const newOwner : address) : (state) is
      block {
        assert((newOwner =/= burn_address)) (* "Ownable: new owner is the zero address" *);
        (* EmitStatement OwnershipTransferred(_owner, newOwner) *)
        contract_storage.owner_ := newOwner;
      } with (contract_storage);
    
    function transferOwnership (const contract_storage : state; const newOwner : address) : (list(operation) * state) is
      block {
        assert(isOwner(contract_storage)) (* "Ownable: caller is not the owner" *);
        transferOwnership_(contract_storage, newOwner);
      } with ((nil: list(operation)), contract_storage);
    
    function main (const action : router_enum; const contract_storage : state) : (list(operation) * state) is
      (case action of
      | Owner(match_action) -> (owner(contract_storage, match_action.receiver), contract_storage)
      | IsOwner(match_action) -> (isOwner(contract_storage, match_action.receiver), contract_storage)
      | RenounceOwnership(match_action) -> renounceOwnership(contract_storage)
      | TransferOwnership(match_action) -> transferOwnership(contract_storage, match_action.newOwner)
      end);
    """#"
    make_test text_i, text_o, {
      router: true
    }
  
  