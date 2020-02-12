config = require("../src/config")
{
  translate_ligo_make_test : make_test
} = require("./util")

describe "translate ligo section", ()->
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
    
    function #{config.reserved}__map (const opList : list(operation); const contractStorage : state) : (list(operation) * state * nat) is
      block {
        contractStorage.allowedIntegers[0n] := True;
        remove 0n from map contractStorage.allowedIntegers;
      } with (opList, contractStorage, 0n);
    
    """
    make_test text_i, text_o
  
  # TODO
  it "nested map"
  ###
  (case contractStorage.addresses[0] of | None -> (map end : map(nat, nat)) | Some(x) -> x end)[0n] := 0n;
  this is not proper assign...
  TODO FIXME
  ###
  # it "nested map", ()->
  #   text_i = """
  #   pragma solidity ^0.5.11;
  #   
  #   contract Map {
  #     mapping(int => mapping(uint => uint)) public addresses;
  #     
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
  #   
  #   function #{config.reserved}__map (const opList : list(operation); const contractStorage : state) : (list(operation) * state * nat) is
  #     block {
  #       contractStorage.allowedIntegers[0][0n] := 0n;
  #     } with (opList, contractStorage, 0);
  #   
  #   """ #"
  #   make_test text_i, text_o