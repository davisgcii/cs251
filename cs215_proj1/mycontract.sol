// SPDX-License-Identifier: UNLICENSED

// DO NOT MODIFY BELOW THIS
pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract Splitwise {
  
  mapping (address => mapping (address => uint32)) debts;
  mapping (address => uint32) totalOwed;
  mapping (address => address[]) neighbors;

  function lookup(address debtor, address creditor) public view returns(uint32) {
    return debts[debtor][creditor];
  }

  function getTotalOwed(address user) public view returns(uint32) {
    return totalOwed[user];
  }

  function isValidPath(address[] calldata path) private view returns(bool) {
    for (uint32 i = 0; i < path.length; i++) {
      // ensures that the path is closed and that the smallest edge is valid
      if (debts[path[i]][path[(i + 1) % path.length]] <= 0) {
        return false;
      }
    }
    return true;
  }

  function removeNeighbor(address debtor, address creditor) private {
    for (uint32 i = 0; i < neighbors[debtor].length; i++) {
      if (neighbors[debtor][i] == creditor) {
        delete neighbors[debtor][i];
      }
    }
  }

  function getNeighbors(address debtor) public view returns(address[] memory) {
    return neighbors[debtor];
  }

  function getSmallestEdge(address[] calldata path) private view returns(uint32){
    uint32 smallEdge = lookup(path[0], path[1]);
    uint32 edge;

    for (uint32 i = 0; i < path.length; i++) {
      edge = debts[path[i]][path[(i + 1) % path.length]];
      if (edge < smallEdge) {
        smallEdge = edge;
      }
    }
    return smallEdge;
  }

  function addIOU(address creditor, uint32 amount, address[] calldata path) public {
    require(creditor != msg.sender, 'Cannot send IOU to yourself!');
    require(amount > 0);

    if (path.length > 0) { // if a path is provided by the client TODO: should be > 1?

      // ensure provided payment path starts with the sender
      require (path[0] == creditor, 'First value in the path must be the creditor');
      
      if (debts[msg.sender][creditor] == 0) {
        neighbors[msg.sender].push(creditor);
      }

      debts[msg.sender][creditor] += amount; // add debt and then
      totalOwed[msg.sender] += amount;
      
      uint32 smallEdge = getSmallestEdge(path);

      require (isValidPath(path), 'Provided path was invalid'); // verify path is closed
      
      for (uint32 i = 0; i < path.length; i++) { // resolve the loop
        debts[path[i]][path[(i + 1) % path.length]] -= smallEdge;

        if (debts[path[i]][path[(i + 1) % path.length]] == 0) { // remove neighbor if
          removeNeighbor(path[i], path[(i + 1) % path.length]); // no remaining debt
        }

        totalOwed[path[i]] -= smallEdge;
      }
    }
    else {
      if (debts[msg.sender][creditor] == 0) {
        neighbors[msg.sender].push(creditor);
      }
      debts[msg.sender][creditor] += amount;
      totalOwed[msg.sender] += amount;
    }
  }
}
