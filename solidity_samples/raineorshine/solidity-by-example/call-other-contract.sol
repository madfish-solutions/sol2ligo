pragma solidity ^0.4.26;
import 'OtherContract.sol'

contract MyContract {
  OtherContract other;
  function MyContract(address otherAddress) {
    other = OtherContract(otherAddress);
  }
  function foo() {
    other.bar();
  }
}