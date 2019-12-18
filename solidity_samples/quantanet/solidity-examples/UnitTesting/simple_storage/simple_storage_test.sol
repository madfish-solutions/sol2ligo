pragma solidity ^0.5.0;
import "./simple_storage.sol";

contract StorageTest {
    SimpleStorage foo;

    function beforeAll() public {
        foo = new SimpleStorage();
    }

    function initialValueShouldBe_100() public returns (bool) {
        return Assert.equal(foo.get(), 100, "initial value is not correct");
    }

    function initialValueShouldBe_200() public returns (bool) {
        return Assert.equal(foo.get(), 200, "initial value is not correct");
    }
}

contract StorageTest2 {
    SimpleStorage foo;
    uint i = 0;

    function beforeEach() public {
        foo = new SimpleStorage();
        if (i == 1) {
            foo.set(200);
        }
        i += 1;
    }

    function initialValueShouldBe_100() public returns (bool) {
        return Assert.equal(foo.get(), 100, "initial value is not correct");
    }

    function initialValueShouldBe_200() public returns (bool) {
        return Assert.equal(foo.get(), 200, "initial value is not correct");
    }
}
