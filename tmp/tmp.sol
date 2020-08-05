pragma solidity ^0.4.22;

library ExactMath {
  function exactAdd(uint self, uint other) internal returns (uint sum) {
    sum = self + other;
    require(sum >= self);
  }
}

contract MathExamples {
  // Add exact uints example.
  function uintExactAddOverflowExample() public {
    var n = uint(~0);
    ExactMath.exactAdd(n,1);
  }
}
