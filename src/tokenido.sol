// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract IDOContract {
    using SafeERC20 for IERC20;

    // ERC20 token being sold
    IERC20 public token;

    // IDO parameters
    uint256 public constant amounttoken=1000000*10**18;     //AmountToken 1000K
    uint256 public constant presalePrice=0.0001 ether;    // Price of 1 token in wei
    uint256 public constant minbuylimit=0.01 ether;    // Price of 1 token in wei
    uint256 public constant maxbuylimit=0.1 ether;    // Price of 1 token in wei
    // uint256 public constant minbuylimit=1 ether;    // Price of 1 token in wei
    // uint256 public constant maxbuylimit=10 ether;    // Price of 1 token in wei
    uint256 public  presaleEndTime;     // Timestamp when presale ends


    // Mapping to track user balances
    mapping(address => uint256) public balances;

    address public owner;

    // Events
    event ETHWithdrawn(uint256 amount);
    event Presale(address sender,uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event Refund(address indexed user, uint256 amountt);

    constructor(
        IERC20 _token
    ) {
        token = _token;
        presaleEndTime = block.timestamp + 1 days;
        // presaleEndTime = block.timestamp + 300;
        owner=msg.sender;
    }

    // Modifier to check if presale was successful and presale has ended
    modifier onlysuccess() {
        require(address(this).balance >=100 ether, "the totalETH not arrival 100 ether");
        require(block.timestamp > presaleEndTime, "the time not endtime");
        _;
    }

    // Modifier to check if presale was failed and presale has ended
    modifier onlyFailed() {
        require(address(this).balance < 100 ether, "the totalETH more than 100 ether");
        require(block.timestamp > presaleEndTime, "the time not endtime");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender==owner,"not owmer");
        _;
    }

    modifier onlyActive(){
        require(block.timestamp < presaleEndTime && address(this).balance + msg.value < 200 ether,"presale end");
        _;
    }

    // Function to participate in presale
    function presale() external payable onlyActive {
        require(msg.value >= minbuylimit,"min limit");
        require(msg.value + balances[msg.sender] <= maxbuylimit,"max limit");

        balances[msg.sender] += msg.value;

        emit Presale(msg.sender,msg.value);
     
    }

    // Function to claim tokens if presale was successful
    function claim() external onlysuccess{
        require(msg.sender != address(0), "Invalid msg.sender");
        require(balances[msg.sender]>0,"zero token");
        uint256 tokensToSend= amounttoken* balances[msg.sender] /address(this).balance;
        balances[msg.sender] = 0;
        token.safeTransfer(msg.sender, tokensToSend);
        emit Claim(msg.sender, tokensToSend);
        
    }

    // Function to claim ETH if presale was Fail
    function refund()external onlyFailed{
        (bool success, ) = msg.sender.call{value: balances[msg.sender]}("");
        require(success, "Transfer failed");
        emit Refund(msg.sender,balances[msg.sender]);
        balances[msg.sender]=0;    
    }
    // Function for project owner to withdraw ETH after successful presale
    function withdraw() external onlyOwner  onlysuccess{
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
        emit ETHWithdrawn(amount);
    }

    // Fallback function to receive ETH
    receive() external payable {}
}
