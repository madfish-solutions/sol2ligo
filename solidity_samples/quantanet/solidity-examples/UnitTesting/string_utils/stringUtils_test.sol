pragma solidity ^0.5.0;
import "./stringUtils.sol";

contract strTest {
    using stringUtils for string;

    function stringToUintTest() public {
        string memory unum = "1485517484864826648847788999984865484747564568484";
        uint newNum = 1485517484864826648847788999984865484747564568484;
        Assert.equal(unum.stringToUint(), newNum, "working");
    }

    function stringCompareTest() public {
        string memory str_1 = "hello World";
        string memory str_2 = "hello World";
        Assert.ok(str_1.stringCompare(str_2), "working");
    }

    function stringLenTest() public {
        string memory str = "hello World";
        Assert.equal(str.stringLen(), 11, "working");
    }

    function stringConcat() public {
        string memory str_1 = "hello ";
        string memory str_2 = "World";
        Assert.equal(str_1.stringConcat(str_2), "hello World", "working");
    }
}