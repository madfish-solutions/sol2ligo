pragma solidity >=0.5.0 <0.6.0;

contract Payable {
    mapping(address => uint256) public vault;
    event Deposit(
        address indexed _from,
        uint _value
    );

    function deposit() public payable {
        vault[msg.sender] = msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}
