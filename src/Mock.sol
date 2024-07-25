// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    // 构造函数，初始化名称为 MockERC20，符号为 MOCK 的 ERC20 代币
    constructor(uint256 initialSupply) ERC20("MockERC20", "MOCK") {
        _mint(msg.sender, initialSupply); // 合约创建者将初始供应量分配给合约创建者
    }

    // 用于测试目的的函数，方便增加代币供应量
    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}