/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

/**
 * Smartex
 *
 * Website: https://smartex.network
 * Email: admin@smartex.network
 */

pragma solidity ^0.5.11;

contract Smartex {
    address public creator;
    uint256 public currentUserID;

    mapping(uint256 => uint256) public levelPrice;
    mapping(address => User) public users;
    mapping(uint256 => address) public userAddresses;

    uint256 MAX_LEVEL = 6;
    uint256 REFERRALS_LIMIT = 2;
    uint256 LEVEL_DURATION = 36 days;

    struct User {
        uint256 id;
        uint256 referrerID;
        address[] referrals;
        mapping(uint256 => uint256) levelExpiresAt;
    }

    event RegisterUserEvent(
        address indexed user,
        address indexed referrer,
        uint256 time
    );
    event BuyLevelEvent(
        address indexed user,
        uint256 indexed level,
        uint256 time
    );
    event GetLevelProfitEvent(
        address indexed user,
        address indexed referral,
        uint256 indexed level,
        uint256 time
    );
    event LostLevelProfitEvent(
        address indexed user,
        address indexed referral,
        uint256 indexed level,
        uint256 time
    );

    modifier userNotRegistered() {
        require(users[msg.sender].id == 0, "User is already registered");
        _;
    }

    modifier userRegistered() {
        require(users[msg.sender].id != 0, "User does not exist");
        _;
    }

    modifier validReferrerID(uint256 _referrerID) {
        require(
            _referrerID > 0 && _referrerID <= currentUserID,
            "Invalid referrer ID"
        );
        _;
    }

    modifier validLevel(uint256 _level) {
        require(_level > 0 && _level <= MAX_LEVEL, "Invalid level");
        _;
    }

    modifier validLevelAmount(uint256 _level) {
        require(msg.value == levelPrice[_level], "Invalid level amount");
        _;
    }

    constructor() public {
        levelPrice[1] = 0.5 ether;
        levelPrice[2] = 1 ether;
        levelPrice[3] = 2 ether;
        levelPrice[4] = 4 ether;
        levelPrice[5] = 8 ether;
        levelPrice[6] = 16 ether;

        currentUserID++;

        creator = msg.sender;

        users[creator] = createNewUser(0);
        userAddresses[currentUserID] = creator;

        for (uint256 i = 1; i <= MAX_LEVEL; i++) {
            users[creator].levelExpiresAt[i] = 1 << 37;
        }
    }

    function() external payable {
        uint256 level;

        for (uint256 i = 1; i <= MAX_LEVEL; i++) {
            if (msg.value == levelPrice[i]) {
                level = i;
                break;
            }
        }

        require(level > 0, "Invalid amount has sent");

        if (users[msg.sender].id != 0) {
            buyLevel(level);
            return;
        }

        if (level != 1) {
            revert("Buy first level for 0.5 ETH");
        }

        address referrer = bytesToAddress(msg.data);
        registerUser(users[referrer].id);
    }

    function registerUser(uint256 _referrerID)
        public
        payable
        userNotRegistered()
        validReferrerID(_referrerID)
        validLevelAmount(1)
    {
        if (
            users[userAddresses[_referrerID]].referrals.length >=
            REFERRALS_LIMIT
        ) {
            _referrerID = users[findReferrer(userAddresses[_referrerID])].id;
        }

        currentUserID++;

        users[msg.sender] = createNewUser(_referrerID);
        userAddresses[currentUserID] = msg.sender;
        users[msg.sender].levelExpiresAt[1] = now + LEVEL_DURATION;

        users[userAddresses[_referrerID]].referrals.push(msg.sender);

        transferLevelPayment(1, msg.sender);
        emit RegisterUserEvent(msg.sender, userAddresses[_referrerID], now);
    }

    function buyLevel(uint256 _level)
        public
        payable
        userRegistered()
        validLevel(_level)
        validLevelAmount(_level)
    {
        for (uint256 l = _level - 1; l > 0; l--) {
            require(
                getUserLevelExpiresAt(msg.sender, l) >= now,
                "Buy the previous level"
            );
        }

        if (getUserLevelExpiresAt(msg.sender, _level) == 0) {
            users[msg.sender].levelExpiresAt[_level] = now + LEVEL_DURATION;
        } else {
            users[msg.sender].levelExpiresAt[_level] += LEVEL_DURATION;
        }

        transferLevelPayment(_level, msg.sender);
        emit BuyLevelEvent(msg.sender, _level, now);
    }

    function findReferrer(address _user) public view returns (address) {
        if (users[_user].referrals.length < REFERRALS_LIMIT) {
            return _user;
        }

        address[1024] memory referrals;
        referrals[0] = users[_user].referrals[0];
        referrals[1] = users[_user].referrals[1];

        address referrer;

        for (uint256 i = 0; i < 1024; i++) {
            if (users[referrals[i]].referrals.length < REFERRALS_LIMIT) {
                referrer = referrals[i];
                break;
            }

            if (i >= 512) {
                continue;
            }

            referrals[(i + 1) * 2] = users[referrals[i]].referrals[0];
            referrals[(i + 1) * 2 + 1] = users[referrals[i]].referrals[1];
        }

        require(referrer != address(0), "Referrer was not found");

        return referrer;
    }

    function transferLevelPayment(uint256 _level, address _user) internal {
        uint256 height = _level > 3 ? _level - 3 : _level;
        address referrer = getUserUpline(_user, height);

        if (referrer == address(0)) {
            referrer = creator;
        }

        if (getUserLevelExpiresAt(referrer, _level) < now) {
            emit LostLevelProfitEvent(referrer, msg.sender, _level, now);
            transferLevelPayment(_level, referrer);
            return;
        }

        if (addressToPayable(referrer).send(msg.value)) {
            emit GetLevelProfitEvent(referrer, msg.sender, _level, now);
        }
    }

    function getUserUpline(address _user, uint256 height)
        public
        view
        returns (address)
    {
        if (height <= 0 || _user == address(0)) {
            return _user;
        }

        return
            this.getUserUpline(
                userAddresses[users[_user].referrerID],
                height - 1
            );
    }

    function getUserReferrals(address _user)
        public
        view
        returns (address[] memory)
    {
        return users[_user].referrals;
    }

    function getUserLevelExpiresAt(address _user, uint256 _level)
        public
        view
        returns (uint256)
    {
        return users[_user].levelExpiresAt[_level];
    }

    function createNewUser(uint256 _referrerID)
        private
        view
        returns (User memory)
    {
        return
            User({
                id: currentUserID,
                referrerID: _referrerID,
                referrals: new address[](0)
            });
    }

    function bytesToAddress(bytes memory _addr)
        private
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(_addr, 20))
        }
    }

    function addressToPayable(address _addr)
        private
        pure
        returns (address payable)
    {
        return address(uint160(_addr));
    }
}
