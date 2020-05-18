pragma solidity >=0.4.21 <0.6.0;

contract Test_contract {
  function add(int a, int b) public pure returns (int c) {
    c = a + b;
    require(c >= a);
  }
  
  function sub(int a, int b) public pure returns (int c) {
    require(b <= a);
    c = a - b;
  }
  
  function mul(int a, int b) public pure returns (int c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
  
  function div(int a, int b) public pure returns (int c) {
    require(b > 0);
    c = a / b;
  }
}
