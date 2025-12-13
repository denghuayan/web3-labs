// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13 ;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenBank {
    ERC20 public token;

    mapping(address => uint256) deposits;

    event Deposit(address indexed user,uint256 amount);
    event WithDraw(address indexed user,uint256 amount);

    constructor(address _tokenAddress){
        require(_tokenAddress != address(0),"token address cannot zero address");
        token = ERC20(_tokenAddress);
    }

    function deposit(uint256 amount) external{
        require(amount >0 , "amount must be greater than zero");
        //检查用户是否有足够的token
        require(token.balanceOf(msg.sender) > amount,"insufficient token balance");

        bool success = token.transferFrom(msg.sender,address(this),amount);
        require(success,"transfer failed");

        deposits[msg.sender] += amount;

        emit Deposit(msg.sender,amount);

    }

    function withDraw(uint256 amount) external{
        require(amount > 0, " withdraw amount must be greater than zero");
        
        // 检查用户是否有足够的存款
        require(deposits[msg.sender] >= amount, "insufficient deposit balance");

        deposits[msg.sender] -= amount;

        bool success = token.transfer(msg.sender,amount);
        require(success,"transfer failed");

       emit WithDraw(msg.sender,amount);

    }

}
