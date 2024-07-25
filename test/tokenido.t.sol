// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Test, console,StdUtils} from "forge-std/Test.sol";
import {IDOContract} from "../src/tokenido.sol";
import {MockERC20} from"../src/Mock.sol";

contract IDOContractTest is Test {
    using SafeERC20 for ERC20;

    MockERC20 public token;
    IDOContract public idoContract;
    address public owner = makeAddr("owner");
    address public user = makeAddr("user");

    uint256 public constant amounttoken=1000000*10**18;     //AmountToken 1000K
    uint256 public constant presalePrice=0.0001 ether;    // Price of 1 token in wei
    uint256 public constant minbuylimit=0.01 ether;    // Price of 1 token in wei
    uint256 public constant maxbuylimit=0.1 ether; 

    function setUp() public {
        vm.startPrank(owner);
        token = new MockERC20(10000000000*10**18);
        idoContract = new IDOContract(
            token
        );
        token.transfer(address(idoContract), 1000000*10**18);
        vm.stopPrank();
    }
    // 测试用户成功进行正常预售
    function testPresaleSuccess() public {
        uint256 ethAmount = 0.1 ether;
        vm.startPrank(user);
        vm.deal(user, ethAmount);
        idoContract.presale{value: 0.1 ether}();
        vm.stopPrank();

        // Assert balances
        assert(idoContract.balances(user)==ethAmount);
        console.log(address(this));
    }
    // 测试用户失败进行预售，转账金额<0.01 ether或者>0.1 ether
     function testPresaleFail() public {
        uint256 ethAmount = 0.001 ether;
        vm.startPrank(user);
        vm.deal(user, ethAmount);
        vm.expectRevert("min limit");
        idoContract.presale{value: 0.001 ether}();
        vm.stopPrank();

    }
    // 测试项目成功预售，用户成功claim token
    function testsuccesspresaleandlClaim() public {

        uint256 ethAmount = 99.99 ether;
        vm.deal(address(idoContract), ethAmount);
        vm.startPrank(user);
        vm.deal(user,0.1 ether);
        idoContract.presale{value: 0.1 ether}();
        vm.warp(block.timestamp + 10 days + 1);
        idoContract.claim();
        console.log(token.balanceOf(user));
        vm.stopPrank();
        assert(token.balanceOf(user) > 0);
        
    }
    //测试项目预售失败，用户成功claim eth
    function testpresaleandclaimETH() public {
        uint256 ethAmount = 90 ether;
        vm.deal(address(idoContract), ethAmount);
        vm.startPrank(user);
        vm.deal(user,0.05 ether);
        idoContract.presale{value: 0.05 ether}();
        vm.warp(block.timestamp + 30 days);
        idoContract.refund();
        vm.stopPrank();
        console.log(idoContract.balances(user));

        assertEq(idoContract.balances(user),0);
        assertEq(user.balance,0.05 ether);
        
        //eth返还给user，balance设置为0
    }
    //测试项目成功预售，项目方提现成功
    function testWithdraw() public {
        uint256 ethAmount = 101 ether;
        vm.deal(address(idoContract), ethAmount);
        vm.startPrank(owner);
        vm.warp(block.timestamp + 30 days + 1);
        idoContract.withdraw();
        vm.stopPrank();
        // console.log(address(idoContract).balance);
        assertEq(address(idoContract).balance,0);
      
    }
}
