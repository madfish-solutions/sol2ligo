pragma solidity ^0.5.0;
import "./SafeMath.sol";

contract safeMathTest {
    using SafeMath for uint;

    uint i = 2**254 - 2;
    uint j = 2;
    
    function addTest() public returns(bool) {
        return Assert.equal(i.add(j), 2**254, "working");
    }

    function subTest() public returns(bool) {
        return Assert.equal(i.sub(j), (2**254 - 4), "working");
    }

    function divTest() public returns(bool) {
        return Assert.equal(i.div(j), (2**253 - 1), "working");
    }

    function mulTest() public returns(bool) {
        return Assert.equal(j.mul(i), (2**255 - 4), "working");
    }

    function modTest() public returns(bool) {
        return Assert.equal(i.mod(j), 0, "working");
    }
}