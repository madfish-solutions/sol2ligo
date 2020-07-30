config = require("../src/config")
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section map", ()->
  @timeout 10000
  # https://github.com/madfish-solutions/Solidity-Dry-Runner/blob/master/contracts/Mappings.ligo
  # https://github.com/madfish-solutions/Solidity-Dry-Runner/blob/master/contracts/Mappings.sol
  # ###################################################################################################
  #    array
  # ###################################################################################################
  it "map", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Map {
      mapping(uint => bool) public allowedIntegers;
      
      function map() public returns (uint) {
        allowedIntegers[0] = true;
        delete allowedIntegers[0];
        return 0;
      }
    }
    """
    text_o = """
    type state is record
      allowedIntegers : map(nat, bool);
    end;
    
    function #{config.reserved}__map (const #{config.contract_storage} : state) : (state * nat) is
      block {
        #{config.contract_storage}.allowedIntegers[0n] := True;
        remove 0n from map #{config.contract_storage}.allowedIntegers;
      } with (#{config.contract_storage}, 0n);
    
    """
    make_test text_i, text_o
  
  # TODO
  it "nested map"
  ###
  (case #{config.contract_storage}.addresses[0] of | None -> (map end : map(nat, nat)) | Some(x) -> x end)[0n] := 0n;
  this is not proper assign...
  TODO FIXME
  ###
  # it "nested map", ()->
  #   text_i = """
  #   pragma solidity ^0.5.11;
    
  #   contract Map {
  #     mapping(int => mapping(uint => uint)) public addresses;
      
  #     function map() public returns (uint) {
  #       addresses[0][0] = 0;
  #       return 0;
  #     }
  #   }
  #   """#"
  #   text_o = """
  #   type state is record
  #     allowedIntegers : map(int, bool);
  #   end;
    
  #   function #{config.reserved}__map (const #{config.contract_storage} : state) : (state * nat) is
  #     block {
  #       #{config.contract_storage}.allowedIntegers[0][0n] := 0n;
  #     } with (#{config.contract_storage}, 0);
    
  #   """ #"
  #   make_test text_i, text_o
  it "nested map", ()->
    text_i = """
    pragma solidity ^0.4.24;

    contract Expr {
        mapping(address => mapping(uint256 => bool)) foo0;
        function expr() public {
            uint8[1][2] memory foo1 = [[0], [0]];
        }
    }
    """#"
    text_o = """
    type state is record
      foo0 : map(address, map(nat, bool));
    end;
    
    function expr (const #{config.reserved}__unit : unit) : (unit) is
      block {
        const foo1 : map(nat, map(nat, nat)) = map
          0n -> map
            0n -> 0n;
          end;
          1n -> map
            0n -> 0n;
          end;
        end;
      } with (unit);
    
    """ #"
    make_test text_i, text_o

  it "array nested in map", ()->
    text_i = """
    pragma solidity ^0.4.16;

    contract NestedArrays {
        mapping (address => uint[]) nested_mapping;

        function nest(uint dummy) public {
            nested_mapping[address(0)] = [0];
        }
    }
    """#"
    text_o = """
    type state is record
      nested_mapping : map(address, map(nat, nat));
    end;

    function nest (const self : state; const dummy : nat) : (state) is
      block {
        self.nested_mapping[("#{config.default_address}" : address)] := map
          0n -> 0n;
        end;
      } with (self);
    """ #"
    make_test text_i, text_o

  it "triple nested map", ()->
    text_i = """
    pragma solidity ^0.5.11;
    
    contract Map {
      mapping(int => mapping(uint => mapping(uint => uint))) public threefold;

      function test() public returns (uint) {
        threefold[0][1][2] = 0;
        if (threefold[4][5][6] == 25) {
          threefold[7][8][9] = threefold[10][11][12];
        }
        return 0;
      }
    }
    """#"
    text_o = """
    type state is record
      threefold : map(int, map(nat, map(nat, nat)));
    end;

    function test (const self : state) : (nat) is
      block {
        const temp_idx_access0 : map(nat, map(nat, nat)) = (case self.threefold[0] of | None -> (map end : map(nat, map(nat, nat))) | Some(x) -> x end);
        const temp_idx_access1 : map(nat, nat) = (case temp_idx_access0[1n] of | None -> (map end : map(nat, nat)) | Some(x) -> x end);
        temp_idx_access1[2n] := 0n;
        const temp_idx_access0 : map(nat, map(nat, nat)) = (case self.threefold[4] of | None -> (map end : map(nat, map(nat, nat))) | Some(x) -> x end);
        const temp_idx_access1 : map(nat, nat) = (case temp_idx_access0[5n] of | None -> (map end : map(nat, nat)) | Some(x) -> x end);
        if ((case temp_idx_access1[6n] of | None -> 0n | Some(x) -> x end) = 25n) then block {
          const temp_idx_access0 : map(nat, map(nat, nat)) = (case self.threefold[7] of | None -> (map end : map(nat, map(nat, nat))) | Some(x) -> x end);
          const temp_idx_access1 : map(nat, nat) = (case temp_idx_access0[8n] of | None -> (map end : map(nat, nat)) | Some(x) -> x end);
          const temp_idx_access2 : map(nat, map(nat, nat)) = (case self.threefold[10] of | None -> (map end : map(nat, map(nat, nat))) | Some(x) -> x end);
          const temp_idx_access3 : map(nat, nat) = (case temp_idx_access2[11n] of | None -> (map end : map(nat, nat)) | Some(x) -> x end);
          temp_idx_access1[9n] := (case temp_idx_access3[12n] of | None -> 0n | Some(x) -> x end);
        } else block {
          skip
        };
      } with (0n);
    """ #"
    make_test text_i, text_o