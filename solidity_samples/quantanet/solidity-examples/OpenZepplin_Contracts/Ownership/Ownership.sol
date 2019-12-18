pragma solidity >=0.5.0 <0.6.0;
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract MyContract is Ownable {

    function normalThing()
        public
    {
        // anyone can call this normalThing()
    }

    function specialThing()
        public
        onlyOwner
    {
        // only the owner can call specialThing()!
    }
}
