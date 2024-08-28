// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenBasedSubscription {
    address public tokenAddress; // Address of the ERC20 token
    uint256 public subscriptionFee; // Fee in tokens
    uint256 public subscriptionDuration; // Duration of subscription in seconds
    mapping(address => uint256) public subscriptionExpiry;

    event Subscribed(address indexed subscriber, uint256 amountPaid, uint256 expiry);

    constructor(address _tokenAddress, uint256 _subscriptionFee, uint256 _subscriptionDuration) {
        tokenAddress = _tokenAddress;
        subscriptionFee = _subscriptionFee;
        subscriptionDuration = _subscriptionDuration;
    }

    function subscribe() public {
        IERC20 token = IERC20(tokenAddress);
        
        // Check if the user has enough tokens and transfer the fee
        require(token.balanceOf(msg.sender) >= subscriptionFee, "Insufficient token balance.");
        require(token.transferFrom(msg.sender, address(this), subscriptionFee), "Token transfer failed.");
        
        // Update subscription expiry
        subscriptionExpiry[msg.sender] = block.timestamp + subscriptionDuration;

        emit Subscribed(msg.sender, subscriptionFee, subscriptionExpiry[msg.sender]);
    }

    function isSubscribed(address user) public view returns (bool) {
        return block.timestamp <= subscriptionExpiry[user];
    }

    function getSubscriptionExpiry(address user) public view returns (uint256) {
        return subscriptionExpiry[user];
    }
}
