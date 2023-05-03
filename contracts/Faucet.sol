// contracts/Faucet.sol
// SPDX-License-Identifier: MIT

// prefer to write a faucet in a seperate contract to prevent it from getting drained

pragma solidity ^0.8.17;

// we should use an interface to use ERC20 functions
interface IERC20{
    // Define the functions we need to use
    function transfer(address to, uint256 amount) external view returns(bool);
    function balanceOf(address account) external view returns(uint256);
}

contract Faucet {
    address payable owner;
    IERC20 public token;

    // represent 50 with 18 decimal places
    uint256 withdrawlAmount = 50 * (10**18);

    // create a time gate to prevent ppl spamming
    uint256 public accessTime = 1 minutes;
    mapping(address => uint256) nextAccessTime;

    constructor(address tokenAddress) payable{
        // token contains an instance of ERC20 contract
        token = IERC20(tokenAddress);
        
        owner = payable(msg.sender);
    }

    function requestTokens() public {
        require(msg.sender != address(0),"request must not originate from a zero account");
        require(token.balanceOf(address(this)) >= withdrawlAmount, "insufficient balance in faucet");
        require(block.timestamp >= nextAccessTime[msg.sender], "You must wait 1 minute");
        
        // adds 1 minute cd time && transfer tokens
        nextAccessTime[msg.sender] = block.timestamp + accessTime;
        token.transfer(msg.sender, withdrawlAmount);
    }

    receive() external payable{
        
    }
}