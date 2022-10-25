pragma solidity ^0.8.4;  //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;

  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() external payable{
    uint256 tokensToTransfer =  msg.value*tokensPerEth;
    yourToken.transfer(msg.sender,tokensToTransfer);
    emit BuyTokens(msg.sender, msg.value, tokensToTransfer);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() external onlyOwner{
    uint256 bal = address(this).balance;
    (bool withdrawn,) = msg.sender.call{value:bal}("");
    // console.log("Withdrew bal: ",bal);
    require(withdrawn, "Something went wrong during withdrawal");
  }


  // ToDo: create a sellTokens(uint256 _amount) function:
  function sellTokens(uint256 _amount)public{
    bool approveStatus = yourToken.approve(address(this), _amount);
    require(approveStatus, "approve failed!");
    bool transferFromStatus = yourToken.transferFrom(msg.sender, address(this), _amount);
    require(transferFromStatus, "transferFrom failed!");
    (bool ethTransferStatus,) = msg.sender.call{value : _amount/tokensPerEth}("");
    require(ethTransferStatus, "Failed to send eth");
    emit SellTokens(msg.sender,_amount/tokensPerEth, _amount);
  }
}
