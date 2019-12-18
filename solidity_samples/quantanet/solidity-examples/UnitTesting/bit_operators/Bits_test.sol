pragma solidity ^0.5.0;
import "./Bits.sol";

contract bitsTest {
    using Bits for *;
    
    function setBitTest() public {
        uint a = 35; // 35 in binary 00100011 and 01100011 is 99
        Assert.equal(a.setBit(6), 99, "working");
    }

    function clearBitTest() public {
        uint a = 35; // 35 in binary 00100011 and 00000011 is 3
        Assert.equal(a.clearBit(5), 3, "working");
    }

    function toggleBitTest() public {
        uint a = 35; // 35 in binary 00100011 and 01100011 is 99
        Assert.equal(a.toggleBit(6), 99, "working");
    }

    function bitSetTest() public {
        uint a = 35; // 35 in binary 00100011 and 5th bit is set
        Assert.ok(a.bitSet(5), "working");
    }

    function bitEqual() public {
        uint a = 3; // 3 in binary 11 and 2 in binary 10 1th bit is equal
        uint b = 2;
        Assert.ok(a.bitEqual(b, 1), "working");
    }

    function bitsliceTest() public {
        uint a = 35; // 35 in binary 00100011 and index 0 to 4 is 3
        Assert.equal(a.bits(0, 4), uint(3), "Working");
    }
}