// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading
import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
  ExampleExternalContract public exampleExternalContract;

  uint256 public constant threshold = 1 ether;

  bool openForWithdraw = false;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }
  event Stake(address,uint256);
  mapping(address=>uint256) public balances;

  uint256 public deadline = block.timestamp + 72 hours;

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake()public payable{
    require(block.timestamp < deadline,"Deadline over");
    balances[msg.sender]+=msg.value;
    emit Stake(msg.sender, msg.value);
    if(address(this).balance >= threshold){
      execute();
    }
    console.log("Contract Balance:",address(this).balance);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() public {
      if(address(this).balance >= threshold){
        exampleExternalContract.complete{value: address(this).balance}();
      }else{
        require(block.timestamp >= deadline, "Deadline not yet reached!");
        openForWithdraw = true;
      }
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public{
    require(!((block.timestamp < deadline) && (address(this).balance >= threshold)), "Conditions not met!");
    execute();
    uint256 depositAmount = balances[msg.sender];
    balances[msg.sender]=0;
    (bool sent,) = msg.sender.call{value: depositAmount}("");
    require(sent,"Something went wrong during withdrawal");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256){
    uint256 tL;     
    unchecked{
      tL = deadline - block.timestamp;
    }
    if(block.timestamp >= deadline){
      return 0;
    }
    return tL;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable{
    stake();
  }
}
