// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

contract GasContract {
    uint256 public immutable totalSupply; // cannot be updated
    uint256 private paymentCounter;
    address private contractOwner;
    address[5] public administrators;

    mapping(address => uint256) private balances;
    mapping(address => Payment[]) private payments;
    mapping(address => uint256) public whitelist;

    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend
    }

    struct Payment {
        PaymentType paymentType;
        uint256 paymentID;
        uint256 amount;
    }

    event Transfer(address recipient, uint256 amount);

    constructor(address[5] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;
        administrators = _admins;
        balances[msg.sender] = _totalSupply;
    }

    function balanceOf(address _user) external view returns (uint256 balance_) {
        return balances[_user];
    }

    // TradeFlag and dividendFlag should be bool
    function getTradingMode() external pure returns (bool) {
        return true;
    }

    function getPayments(address _user)
        external
        view
        returns (Payment[] memory payments_)
    {
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string memory name
    ) external {
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        payments[msg.sender].push(
            Payment(PaymentType.BasicPayment, ++paymentCounter, _amount)
        );
        emit Transfer(_recipient, _amount);
    }

    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
    ) external {
        payments[_user][_ID].paymentType = _type;
        payments[_user][_ID].amount = _amount;
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) external {
        whitelist[_userAddrs] = _tier;
    }

    function whiteTransfer(address _recipient, uint256 _amount) external {
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
    }
}
