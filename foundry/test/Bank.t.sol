// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test,console} from "forge-std/Test.sol";
import "../src/Bank.sol";

contract BankTest is Test{
    Bank public bank;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public tom = makeAddr("tom");
    address public june = makeAddr("june");
    uint256 public constant INITIAL_BALANCE = 1 ether;

     receive() external payable{

    }
    
    function setUp() public {
        // 给测试用户一些ETH
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(tom, 10 ether);
        vm.deal(june, 10 ether);
        bank = new Bank();
        console.log("admin:",bank.admin());
        vm.deal(bank.admin(),0);
        console.log("bank.admin().balance:%d", bank.admin().balance);
         vm.startPrank(alice);
        bank.deposit{value: INITIAL_BALANCE }() ;
        assertEq(bank.getAmount(),INITIAL_BALANCE);
        vm.stopPrank();

        vm.startPrank(june);
        bank.deposit{value:INITIAL_BALANCE*5}();
        assertEq(bank.getAmount(),INITIAL_BALANCE*5);
        vm.stopPrank();

        vm.startPrank(bob);
        bank.deposit{value:INITIAL_BALANCE*2}();
        assertEq(bank.getAmount(),INITIAL_BALANCE*2);
        vm.stopPrank();

        vm.startPrank(tom);
        bank.deposit{value:INITIAL_BALANCE*3}();
        assertEq(bank.getAmount(),INITIAL_BALANCE*3);
        vm.stopPrank();

        
       
    }

    function test_withdraw() public{
         // 非管理员尝试取款，应该失败
        vm.prank(alice);
        vm.expectRevert("Only admin can withdraw");
        bank.withdraw();
        vm.prank(bank.admin());
        bank.withdraw();
        assertEq(bank.admin().balance,bank.totalAmount());
        console.log("bank.admin().balance:%d", bank.admin().balance);
        vm.expectRevert();
         bank.withdraw();
    }

    function test_topaddress() public view{
        (address[3] memory topaddress, uint[3] memory topamounts) = bank.getTopDepositors();
        assertEq(topamounts[0],INITIAL_BALANCE*5);
        console.log("address0:%s,amount0:%d alice:%s",topaddress[0],topamounts[0],alice);
    }
}