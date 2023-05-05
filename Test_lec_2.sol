// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

// contract Test {
//     uint256[3] public arr = [1, 2, 3];
//     uint256 public a;

//     // function addNumber() external returns (uint256) {
//     //     uint256 res;
//     //     for (uint256 i = 0; i < arr.length; i++) {
//     //         res += arr[i];
//     //     }
//     //     arr[1] = 5;
//     //     return res;

//     // }

//     // function getArray() external returns (uint256[] memory){

//     // }

//     function storageArray() external  view returns (uint256){
//         // uint256[3] storage numbers = arr;

//         // numbers[0] = 2;

//         uint256 x = a;
//         // x = 2;
//         return x + x + x;
//     }
//     function memoryArray() external view {
        

//         uint256[3] memory numbers = arr;

//         numbers[0] = 2;
//     }


// }


// contract Test1 {
//     uint256[] public arr = [1, 2, 3, 4, 5];

//     function addNumber() external returns (uint256) {
//         uint256 res;
//         for (uint256 i = 0; i < arr.length; i++) {
//             res += arr[i];
//         }
        
//         arr.push(5);
        
//         arr.pop();
//         return res;
        
//     }

//     function getLenght() external view returns (uint256) {
//         return arr.length;
//     }

//     function myFunction(uint[] calldata myArray) external pure returns (uint256) {
//         // myArray[0] = 5;
//         return myArray[0]; 
//     }

// }


contract Test2 {
    uint256[] public arr = [1, 2, 3, 4, 5];

   
    function checkRes() external returns (uint256 x) {
        uint256[] storage arrRef = arr;
        arrRef[0] = 2;
        return arr[0]; 
    }

    function checkRes1() external view returns (uint256 x, uint256 y) {
        uint256[] memory arrRef = arr;
        arrRef[0] = 2;
        return (arrRef[0], arr[0]); 
    }

    function checkArr(uint256[] calldata arr2) external  pure  returns (uint256) {
        return arr2[0];
    }

    function addNumber(uint256 value) external pure returns (uint256) {
        uint256[] memory arr3;
        // cannot push in memory 
        // arr3.push(value);
        return arr3.length;
    }
    function addNumber2() external view returns (uint256[] memory) {
        uint256[] memory arrCopy = arr;
        return arrCopy;
    }

}

contract TestTwo {
    //state variables
    uint256 storageVar;
    uint256[] storageArr = [1, 2];
    function test() external  view returns (uint256){
        //local variables
        uint256 memoryVar = storageVar;
        uint256[] storage arrReference = storageArr;
        uint256[] memory arrCopy = storageArr;

        
        uint256[] memory arrCopyRef = arrCopy;

        arrCopyRef[0] = 5;

        return arrCopy[0];
    }
}

contract StringTest {

    function test() external pure returns (string memory, bytes32, bytes memory) {
        string memory hello = "Hello world!";
        bytes32 helloTwo = "Hello world!";
        bytes memory helloThree = "Hello world! sadsadasdasdadsada";

        return (hello, helloTwo, helloThree);
    }
}

contract Animal {
    function live() external pure returns (bool){
        return true;
    }
}

contract Dog is Animal{
    function bark() external pure returns (uint256){
        return  1;
    }
}


contract Math {
    function sum(uint256 a, uint256 b) internal pure virtual returns (uint256) {
        return a + b;
    }
  
}

contract VoteContract is Math{
    function sum(uint256 a, uint256 b) internal pure override returns (uint256) {
        return a + b + b;
    }
}

abstract contract VotingMechanism {
    function getResult() external virtual ;
}

contract Voting is Math, VotingMechanism {
    uint256 positive;

    function getResult() external override {
        positive += 1;
    }
}

interface Token {
    struct Coin { string obverse; string reverse; }    function transfer(address recipient, uint256 amount) external;
}

contract MyToken is Token {
    function transfer(address recipient, uint256 amount) external{

    }

}


contract Owned {
    address payable owner;

    constructor() { owner = payable(msg.sender); }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _; //here is func logic code after the check//
    }

    function register() public payable onlyOwner {
        // require(msg.sender == owner, "not owner"); == onlyOwner
    }
}


contract InfoFeed {
    function info() public payable  returns (uint256 ret) {
        return 42;
    }
}

contract Consumer {
    InfoFeed feed;
    function setFeed (InfoFeed addr) public {
        feed = addr;
    }

    function callFeed() public {
        feed.info{value:10, gas: 800}();
    }
}



//libraries//

struct Data {mapping (uint256 => bool) flags;}

library Set {
    function insert(Data storage self, uint256 value) public returns (bool) {
        if (self.flags[value]) return false;
        self.flags[value] = true; return true;
    }
}

contract C {
    using Set for Data;
    Data knownValues;

    function register(uint256 value) public {
        // require(Set.insert(knownValues, value));
        require(knownValues.insert(value));
    }
}