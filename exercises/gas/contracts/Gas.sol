// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

contract GasContract {
    uint256 immutable tradeFlag = 1;
    //uint256 immutable basicFlag = 0;
    uint256 immutable dividendFlag = 1;
    uint256 public totalSupply; // cannot be updated
    uint256 private paymentCounter;
    uint256 private tradePercent = 12;
    uint256 private tradeMode;
    // Should be boolean?
    uint256 wasLastOdd = 1;

    mapping(address => uint256) private balances;
    mapping(address => Payment[]) private payments;
    mapping(address => uint256) public whitelist;
    mapping(address => uint256) private isOddWhitelistUser;

    address public contractOwner;
    address[5] public administrators;

    bool public isReady = false;

    PaymentType constant defaultPayment = PaymentType.Unknown;
    History[] private paymentHistory; // when a payment was updated

    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }

    struct Payment {
        PaymentType paymentType;
        uint256 paymentID;
        uint256 amount;
        bool adminUpdated;
        string recipientName; // max 8 characters
        address recipient;
        address admin; // administrators address
    }

    struct History {
        uint256 lastUpdate;
        uint256 blockNumber;
        address updatedBy;
    }

    event AddedToWhitelist(address userAddress, uint256 tier);

    modifier onlyAdminOrOwner() {
        require(
            msg.sender == contractOwner || checkForAdmin(msg.sender),
            "Error in Gas contract - onlyAdminOrOwner modifier : revert happened because the originator of the transaction was not the admin, and furthermore he wasn't the owner of the contract, so he cannot run this function"
        );
        _;
    }

    modifier checkIfWhiteListed(address sender) {
        require(
            whitelist[msg.sender] > 0,
            "Gas Contract CheckIfWhiteListed modifier : revert happened because the user is not whitelisted"
        );
        require(
            whitelist[msg.sender] < 4,
            "Gas Contract CheckIfWhiteListed modifier : revert happened because the user's tier is incorrect, it cannot be over 4 as the only tier we have are: 1, 2, 3; therfore 4 is an invalid tier for the whitlist of this contract. make sure whitlist tiers were set correctly"
        );
        _;
    }

    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(
        address admin,
        uint256 ID,
        uint256 amount,
        string recipient
    );
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;

        for (uint256 ii = 0; ii < administrators.length; ii++) {
            require(_admins[ii] != address(0));

            administrators[ii] = _admins[ii];
            if (_admins[ii] == contractOwner) {
                balances[contractOwner] = totalSupply;
            } else {
                balances[_admins[ii]] = 0;
            }
            if (_admins[ii] == contractOwner) {
                emit supplyChanged(_admins[ii], totalSupply);
            } else if (_admins[ii] != contractOwner) {
                emit supplyChanged(_admins[ii], 0);
            }
        }
    }

    function getPaymentHistory()
        public
        payable
        returns (History[] memory paymentHistory_)
    {
        return paymentHistory;
    }

    // Should use a mapping that gets initialized on deployement  
    function checkForAdmin(address _user) public view returns (bool admin_) {
        bool admin = false;
        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (administrators[ii] == _user) {
                admin = true;
            }
        }
        return admin;
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        return balances[_user];
    }

    // TradeFlag and dividendFlag should be booleans 
    function getTradingMode() public pure returns (bool) {
        if (tradeFlag == 1 || dividendFlag == 1) {
            return true;
        } else {
            return false;
        }
    }

    function addHistory(address _updateAddress, bool _tradeMode)
        public
        returns (bool status_, bool tradeMode_)
    {
        History memory history;
        history.blockNumber = block.number;
        history.lastUpdate = block.timestamp;
        history.updatedBy = _updateAddress;
        paymentHistory.push(history);
        bool[] memory status = new bool[](tradePercent);
        for (uint256 i = 0; i < tradePercent; i++) {
            status[i] = true;
        }
        return ((status[0] == true), _tradeMode);
    }

    function getPayments(address _user)
        public
        view
        returns (Payment[] memory payments_)
    {
        require(
            _user != address(0),
            "Gas Contract - getPayments function - User must have a valid non zero address"
        );
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public returns (bool status_) {
        require(
            balances[msg.sender] >= _amount,
            "Gas Contract - Transfer function - Sender has insufficient Balance"
        );
        require(
            bytes(_name).length < 9,
            "Gas Contract - Transfer function -  The recipient name is too long, there is a max length of 8 characters"
        );
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        Payment memory payment;
        payment.admin = address(0);
        payment.adminUpdated = false;
        payment.paymentType = PaymentType.BasicPayment;
        payment.recipient = _recipient;
        payment.amount = _amount;
        payment.recipientName = _name;
        payment.paymentID = ++paymentCounter;
        payments[msg.sender].push(payment);
        bool[] memory status = new bool[](tradePercent);
        for (uint256 i = 0; i < tradePercent; i++) {
            status[i] = true;
        }
        return (status[0] == true);
    }

    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
    ) public onlyAdminOrOwner {
        require(
            _ID > 0,
            "Gas Contract - Update Payment function - ID must be greater than 0"
        );
        require(
            _amount > 0,
            "Gas Contract - Update Payment function - Amount must be greater than 0"
        );
        require(
            _user != address(0),
            "Gas Contract - Update Payment function - Administrator must have a valid non zero address"
        );
        uint256 i = 0;
        for (i; i < payments[_user].length; i++) {
            if (payments[_user][i].paymentID == _ID) {
                payments[_user][i].adminUpdated = true;
                payments[_user][i].admin = _user;
                payments[_user][i].paymentType = _type;
                payments[_user][i].amount = _amount;
                //bool tradingMode = getTradingMode();
                addHistory(_user, getTradingMode());
                emit PaymentUpdated(
                    msg.sender,
                    _ID,
                    _amount,
                    payments[_user][i].recipientName
                );
            }
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        public
        onlyAdminOrOwner
    {
        require(
            _tier < 255,
            "Gas Contract - addToWhitelist function -  tier level should not be greater than 255"
        );
        whitelist[_userAddrs] = _tier;
        if (_tier > 3) {
            whitelist[_userAddrs] -= _tier;
            whitelist[_userAddrs] = 3;
        } else if (_tier == 1) {
            whitelist[_userAddrs] -= _tier;
            whitelist[_userAddrs] = 1;
        } else if (_tier > 0 && _tier < 3) {
            whitelist[_userAddrs] -= _tier;
            whitelist[_userAddrs] = 2;
        }
        uint256 wasLastAddedOdd = wasLastOdd;
        if (wasLastAddedOdd == 1) {
            wasLastOdd = 0;
            isOddWhitelistUser[_userAddrs] = wasLastAddedOdd;
        } else if (wasLastAddedOdd == 0) {
            wasLastOdd = 1;
            isOddWhitelistUser[_userAddrs] = wasLastAddedOdd;
        } else {
            revert("Contract hacked, imposible, call help");
        }
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public checkIfWhiteListed(msg.sender) {
        require(
            balances[msg.sender] >= _amount,
            "Gas Contract - whiteTransfers function - Sender has insufficient Balance"
        );
        require(
            _amount > 3,
            "Gas Contract - whiteTransfers function - amount to send have to be bigger than 3"
        );
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        balances[msg.sender] += whitelist[msg.sender];
        balances[_recipient] -= whitelist[msg.sender];


        emit WhiteListTransfer(_recipient);
    }
}
