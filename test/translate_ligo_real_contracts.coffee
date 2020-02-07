config = require("../src/config")
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo real contracts section", ()->
  @timeout 10000
  # ###################################################################################################
  #    simple coin
  # ###################################################################################################
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
    type state is record
      balances : map(address, nat);
      #{config.reserved}__initialized : bool;
    end;
    
    type constructor_args is record
      #{config.reserved}__empty_state : int;
    end;
    
    type transfer_args is record
      #{config.reserved}__to : address;
      #{config.reserved}__amount : nat;
    end;
    
    function constructor (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        contractStorage.balances[sender] := 1000000n;
      } with (opList, contractStorage);
    
    function transfer (const opList : list(operation); const contractStorage : state; const #{config.reserved}__to : address; const #{config.reserved}__amount : nat) : (list(operation) * state) is
      block {
        if ((case contractStorage.balances[sender] of | None -> 0n | Some(x) -> x end) >= #{config.reserved}__amount) then {skip} else failwith("Overdrawn balance");
        contractStorage.balances[sender] := abs((case contractStorage.balances[sender] of | None -> 0n | Some(x) -> x end) - #{config.reserved}__amount);
        contractStorage.balances[#{config.reserved}__to] := ((case contractStorage.balances[#{config.reserved}__to] of | None -> 0n | Some(x) -> x end) + #{config.reserved}__amount);
      } with (opList, contractStorage);
    
    type router_enum is
      | Constructor of constructor_args
      | Transfer of transfer_args;
    
    function main (const action : router_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        if (contractStorage.#{config.reserved}__initialized) then block {
          case action of
          | Constructor(match_action) -> block {
            const tmp_0 : (list(operation) * state) = constructor(opList, contractStorage);
            opList := tmp_0.0;
            contractStorage := tmp_0.1;
          }
          | Transfer(match_action) -> block {
            const tmp_1 : (list(operation) * state) = transfer(opList, contractStorage, match_action.#{config.reserved}__to, match_action.#{config.reserved}__amount);
            opList := tmp_1.0;
            contractStorage := tmp_1.1;
          }
          end;
        } else block {
          contractStorage.#{config.reserved}__initialized := True;
        };
      } with (opList, contractStorage);
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
  it "ownable", ()->
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
    type state is record
      #{config.fix_underscore}__owner : address;
      #{config.reserved}__initialized : bool;
    end;
    
    (* EventDefinition OwnershipTransferred *)
    
    (* modifier onlyOwner inlined *)
    
    type owner_args is record
      #{config.reserved}__empty_state : int;
    end;
    
    type isOwner_args is record
      #{config.reserved}__empty_state : int;
    end;
    
    type renounceOwnership_args is record
      #{config.reserved}__empty_state : int;
    end;
    
    type transferOwnership_args is record
      newOwner : address;
    end;
    
    function #{config.fix_underscore}__msgSender (const opList : list(operation); const contractStorage : state) : (list(operation) * state * address) is
      block {
        skip
      } with (opList, contractStorage, sender);
    
    function context_constructor (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        skip
      } with (opList, contractStorage);
    
    function constructor (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const tmp_0 : (list(operation) * state) = context_constructor(opList, contractStorage);
        opList := tmp_0.0;
        contractStorage := tmp_0.1;
        const tmp_1 : (list(operation) * state * address) = #{config.fix_underscore}__msgSender(opList, contractStorage);
        opList := tmp_1.0;
        contractStorage := tmp_1.1;
        const msgSender : address = tmp_1.2;
        contractStorage.#{config.fix_underscore}__owner := msgSender;
        (* EmitStatement *);
      } with (opList, contractStorage);
    
    function owner (const opList : list(operation); const contractStorage : state) : (list(operation) * state * address) is
      block {
        skip
      } with (opList, contractStorage, contractStorage.#{config.fix_underscore}__owner);
    
    function isOwner (const opList : list(operation); const contractStorage : state) : (list(operation) * state * bool) is
      block {
        const tmp_0 : (list(operation) * state * address) = #{config.fix_underscore}__msgSender(opList, contractStorage);
        opList := tmp_0.0;
        contractStorage := tmp_0.1;
      } with (opList, contractStorage, (tmp_0.2 = contractStorage.#{config.fix_underscore}__owner));
    
    function renounceOwnership (const opList : list(operation); const contractStorage : state) : (list(operation) * state) is
      block {
        const tmp_0 : (list(operation) * state * bool) = isOwner(opList, contractStorage);
        opList := tmp_0.0;
        contractStorage := tmp_0.1;
        if tmp_0.2 then {skip} else failwith("Ownable: caller is not the owner");
        (* EmitStatement *);
        contractStorage.#{config.fix_underscore}__owner := ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);
      } with (opList, contractStorage);
    
    function #{config.fix_underscore}__transferOwnership (const opList : list(operation); const contractStorage : state; const newOwner : address) : (list(operation) * state) is
      block {
        if (newOwner =/= ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)) then {skip} else failwith("Ownable: new owner is the zero address");
        (* EmitStatement *);
        contractStorage.#{config.fix_underscore}__owner := newOwner;
      } with (opList, contractStorage);
    
    function transferOwnership (const opList : list(operation); const contractStorage : state; const newOwner : address) : (list(operation) * state) is
      block {
        const tmp_0 : (list(operation) * state * bool) = isOwner(opList, contractStorage);
        opList := tmp_0.0;
        contractStorage := tmp_0.1;
        if tmp_0.2 then {skip} else failwith("Ownable: caller is not the owner");
        const tmp_1 : (list(operation) * state) = #{config.fix_underscore}__transferOwnership(opList, contractStorage, newOwner);
        opList := tmp_1.0;
        contractStorage := tmp_1.1;
      } with (opList, contractStorage);
    
    type router_enum is
      | Owner of owner_args
      | IsOwner of isOwner_args
      | RenounceOwnership of renounceOwnership_args
      | TransferOwnership of transferOwnership_args;
    
    function main (const action : router_enum; const contractStorage : state) : (list(operation) * state) is
      block {
        const opList : list(operation) = (nil: list(operation));
        if (contractStorage.#{config.reserved}__initialized) then block {
          case action of
          | Owner(match_action) -> block {
            const tmp_0 : (list(operation) * state * address) = owner(opList, contractStorage);
            opList := tmp_0.0;
            contractStorage := tmp_0.1;
          }
          | IsOwner(match_action) -> block {
            const tmp_1 : (list(operation) * state * bool) = isOwner(opList, contractStorage);
            opList := tmp_1.0;
            contractStorage := tmp_1.1;
          }
          | RenounceOwnership(match_action) -> block {
            const tmp_2 : (list(operation) * state) = renounceOwnership(opList, contractStorage);
            opList := tmp_2.0;
            contractStorage := tmp_2.1;
          }
          | TransferOwnership(match_action) -> block {
            const tmp_3 : (list(operation) * state) = transferOwnership(opList, contractStorage, match_action.newOwner);
            opList := tmp_3.0;
            contractStorage := tmp_3.1;
          }
          end;
        } else block {
          contractStorage.#{config.reserved}__initialized := True;
        };
      } with (opList, contractStorage);
    """#"
    make_test text_i, text_o, {
      router: true
    }
  
  