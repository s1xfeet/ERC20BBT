// contracts/BubbleTeaToken.sol
// SPDX-License-Identifier: MIT

/* TOKEN DESIGN
- initial supply - send % of init supply to owner to create LP, airdrop
- capped / max supply(777,777,777,777) - fixed supply creates scarcity and provides value to assets, if its a token in a game then allow it to be generated in the game
- minting strat - how will new tokens be rewarded? 
- block reward - implement a mining reward by sending a small amount of tokens to the node that includes a block that contains our token tx
- burnable - increase value of remaing, similar to stock buyback

TODO 
1. init supply send to owner - 777,777,777

2. max supply cap at 777,777,777,777

3. Make token burnable and create a block reward to distribute new supply to miners
*/

pragma solidity ^0.8.17;

// import the ERC20 via link
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// makes sure the cap supply is abided 
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

// makes the function burnable
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract BBT is ERC20Capped, ERC20Burnable{
    address payable public owner;
    uint256 public blockReward;
    // pass in the initial supply of the token to constructor
    // call the ERC20 constructor and pass in 'name of token', 'token symbol'
    constructor(uint256 cap, uint256 reward) ERC20("BubbleTea", "BBT") ERC20Capped(cap * (10**decimals())){
        // ensure owner is receiving a payable address
        owner = payable(msg.sender);

        //set initial block reward when contract is deployed
        blockReward = reward * (10**decimals());
        // create this token and send to owner, decimals accounts for decimal places, 18
        _mint(owner, 777777777 * (10 ** decimals()));
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20Capped, ERC20) {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }

    // rewards the miner
    function mintMinerReward() internal{
        // takes the address and amount
        _mint(block.coinbase, blockReward);
    }

    function _beforeTokenTransfer(address from, address to,uint256 amount)internal virtual override{
        // check if its a valid address using 'address(0)', don't send another reward for the reward
        if(from != address(0) && to != block.coinbase && block.coinbase != address(0)){
            mintMinerReward();
        }
        // implement the function from the parent contract after the check
        super._beforeTokenTransfer(from, to, amount);   
    }

    function setBlockReward(uint reward) public onlyOwner{
        blockReward = reward * (10**decimals());
    }

    function destroy() public onlyOwner{
        selfdestruct(owner);
    }

    // create reuseable modifier to only allow owner access
    modifier onlyOwner{
        require(msg.sender == owner, 'Only the owner can call this function');
        _;
    }
}