pragma solidity ^0.4.19;

interface token {
    function transferFrom(address from, address receiver, uint amount) public;
}

contract Owned {
    address public owner;

    function Owned() public{
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public{
        owner = newOwner;
    }
}

contract PrivateSale is Owned{
    address public approveAccount;      /// 代币账户
    address public beneficiary;         /// 受益人
    uint public price;                  /// 售价
    uint public deadline;               /// 截止时间
    uint public amountRaised;           /// 总收益
    token public tokenReward;            /// 代币合约
    bool public halted = false;        /// 终止交易
    mapping(address => uint256) public balanceOf;   /// 投资额
    event FundTransfer(address backer, uint amount, bool isContribution);
    event PriceUpdated(uint amount);

    function PrivateSale(
        address tokenFrom,
        address ifSuccessfulSendTo,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) public{
        approveAccount =tokenFrom;
        beneficiary = ifSuccessfulSendTo;
        deadline = now + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 wei;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    function () payable public{
        require(!halted);
        require(now <= deadline);
        uint amount = msg.value;   /// 发送的eth金额
        balanceOf[msg.sender] += amount;  /// 发送者的eth额度
        amountRaised += amount;   /// 总募集的eth
        beneficiary.transfer(amount);   /// 直接把eth转到指定账户
        tokenReward.transferFrom(approveAccount, msg.sender, amount / price * 1 ether);   ///  给投资者发送对应数量的token
        FundTransfer(msg.sender, amount, true);
    }

    function setPrice(uint _price) onlyOwner public returns (bool){
        price = _price;
        PriceUpdated(price);
        return true;
    }

    function halt(bool _halted) onlyOwner public{
        halted = _halted;
    }

}
