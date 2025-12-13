// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";

contract Bank {
    uint8 private constant TOP_COUNT = 3;
    //total amount
    uint public totalAmount;
    address public immutable admin;
    mapping(address =>uint) public amounts;
    //前3名adress
    address[3] public topAddress;

    constructor(){
        admin = msg.sender;
    }

    receive() external payable{
        handDeposit();
    }

    fallback() external {

    }
    // 存款函数
    function deposit() external payable {
        handDeposit();
    }

    function handDeposit()  internal {
        amounts[msg.sender] += msg.value;
        totalAmount += msg.value;
        updateTopAddress(msg.sender);
    }

    function updateTopAddress(address sender) private {
        uint senderAmount = amounts[sender];
        // sender 在topAddress中
        for(uint8 i =0; i < TOP_COUNT;i++){
            if(topAddress[i] == sender){
                _updateRanking();
                return;
            }
        }
        //sender不在topAddress中
        uint8 j = 0;
        for(;j<TOP_COUNT;j++){
            if(topAddress[j] == address(0)){
                break;
            }else{
                uint amount = amounts[topAddress[j]];
                if(senderAmount>amount){
                    break;
                }
            }
        }

        if(j<TOP_COUNT){
        
            for(uint i =2; i> j ; i--){
                topAddress[i] = topAddress[i-1];
            }
            topAddress[j] = sender;
       
        }

    }

    function _updateRanking() internal {
        for (uint8 i = 1; i < TOP_COUNT; i++) {
            address key = topAddress[i];
            if (key == address(0)) continue; // 跳过空地址
            
            uint keyDeposit = amounts[key];
            int8 j = int8(i) - 1;
            
            while (j >= 0 && (topAddress[uint8(j)] == address(0) || amounts[topAddress[uint8(j)]] < keyDeposit)) {
                topAddress[uint8(j + 1)] = topAddress[uint8(j)];
                j--;
            }
            
            topAddress[uint8(j + 1)] = key;
        }
    }

    // 获取前3名存款人及其存款金额
    function getTopDepositors() external view returns (address[3] memory, uint[3] memory) {
        uint[3] memory values;
        for (uint8 i = 0; i < TOP_COUNT; i++) {
            values[i] = amounts[topAddress[i]];
        }
        return (topAddress, values);
    }
    
    // 只有管理员可以提取所有ETH
    function withdraw() external {
        // 检查调用者是否为管理员
        require(msg.sender == admin, "Only admin can withdraw");
        
        // 获取合约余额
        uint balance = address(this).balance;
        
        // 确保有余额可提取
        require(balance > 0, "No balance to withdraw");
        
        // 将所有ETH转给管理员
        (bool success, ) = admin.call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    function getAmount() external view returns (uint) {
        return amounts[msg.sender];
    }
}