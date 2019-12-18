pragma solidity ^0.5.0;
import "./string.sol";

contract StringTest {
    Strings foo;

    function beforeAll() public {
        foo = new Strings();
    }

    function initialValueShouldBeHello() public returns (bool) {
        return Assert.equal(foo.get(), "Hello", "initial value is correct");
    }

    function initialValueShouldNotBeHelloWorld() public returns (bool) {
        return Assert.notEqual(foo.get(), "Hello world", "initial value is correct");
    }
}
