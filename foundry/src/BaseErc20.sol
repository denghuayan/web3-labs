// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
/**
完善合约，实现以下功能：

设置 Token 名称（name）："BaseERC20"
设置 Token 符号（symbol）："BERC20"
设置 Token 小数位decimals：18
设置 Token 总量（totalSupply）:100,000,000
允许任何人查看任何地址的 Token 余额（balanceOf）
允许 Token 的所有者将他们的 Token 发送给任何人（transfer）；转帐超出余额时抛出异常(require),并显示错误消息 “ERC20: transfer amount exceeds balance”。
允许 Token 的所有者批准某个地址消费他们的一部分Token（approve）
允许任何人查看一个地址可以从其它账户中转账的代币数量（allowance）
允许被授权的地址消费他们被授权的 Token 数量（transferFrom）；
转帐超出余额时抛出异常(require)，异常信息：“ERC20: transfer amount exceeds balance”
转帐超出授权数量时抛出异常(require)，异常消息：“ERC20: transfer amount exceeds allowance”。
 */

contract BaseERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) balances;
    mapping(address=>mapping(address=>uint256)) allowances;

     event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() public {
        name = "BaseERC20";
        symbol = "BERC20" ;
        decimals = 18;
        totalSupply = 100000000*10**decimals;
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _addr) external view returns (uint256) {
        return balances[_addr];
    }

    function transfer(address to,uint256 value) public returns(bool){
        require(to != address(0),"transfer the zero address");
        require(balances[msg.sender] >= value,"transfer amount exceeds balance");
        require(allowances[msg.sender][to] >= value,"transfer amount exceeds approve amount");
        balances[msg.sender] -= value;
        balances[to] += value;
        allowances[msg.sender][to] -= value;

        emit Transfer(msg.sender, to, value); 
        return true;

    }
    function transferFrom(address from,address to,uint256 value) public returns(bool){
        require(to != address(0),"transfer the zero address");
        require(balances[from] >= value,"transfer amount exceeds balance");
        require(allowances[from][to] >= value,"transfer amount exceeds approve amount");
        balances[from] -= value;
        balances[to] += value;
        allowances[from][to] -= value;
        emit Transfer(from, to, value); 
        return true;
    }
    //approve transfer amount
    function approve(address _spender,uint256 value) public returns(bool){
        require(_spender != address(0),"approve to the zero address");
        allowances[msg.sender][_spender] = value ;
        emit Approval(msg.sender,_spender,value);
        return true;
    }
    function allowance(address _from,address _spender) public view returns(uint256){
        return allowances[_from][_spender];
    }
}