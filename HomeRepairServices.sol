// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract HomeRepairServices {
    address admin = payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
    mapping (uint256 => Repairs) public requestOwner;
    mapping (uint256 => uint256) public toPay;
    mapping (uint256 => bool) public paid;
    mapping (address => bool) public auditors;
    mapping (uint256 => bool) public verified;
    mapping (uint256 => uint256) public countOfAuditors;
    mapping (uint256 => mapping (address => bool)) public isConfirmed ;
    // Repairs[] public repairs;
    struct Repairs {
        address user;
        string description;
    }

    function AddRepair (uint id, string memory description) public {
        requestOwner[id].user = msg.sender;
        requestOwner[id].description = description;
    }

    function ApproveRequest(uint id, uint256 money) public  {
        if (msg.sender != admin) {
            revert("Not owner!");
        }

        if (requestOwner[id].user == address(0)) {
            revert("Not valid request!");
        }
        toPay[id] = money;
    }

    function pay(uint256 id) public payable {
        require(toPay[id] != 0, "Not approved!");
        require(msg.value == toPay[id]);

        paid[id] = true;
        
    }

    function setAuditors(address auditor) public {
        require(msg.sender == admin, "Require admin rights");
        auditors[auditor] = true;
    }

    function confirmRepair(uint256 id) public payable {
        require(auditors[msg.sender], "Not auditor");
        require(paid[id] == true, "Not paid"); 
        verified[id] = true;

        require(isConfirmed[id][msg.sender] == false);
        countOfAuditors[id]++;

        if (countOfAuditors[id] > 2) {
            executeRepair(id);
        }

    }

    function executeRepair(uint256 id) public payable {
        require(countOfAuditors[id] >= 2, "Not yet audited!");
        payable(admin).transfer(toPay[id]);
    }

    function moneyBack(uint256 id) public payable {
        payable(requestOwner[id].user).transfer(toPay[id]);
    }

}