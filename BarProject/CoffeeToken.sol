// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title Contract for Beer NFT Creation
///@author Stanislav Bozhimirov
///@notice This is a basic contract for token creation with predefined data

contract CoffeeToken is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    ///@dev for the ERC721 token is used predefined info, can be changed before deploying
    constructor() ERC721("CoffeeToken", "CoffeE") {}

    string private uri =
        "ipfs://QmUNo3djMSTeuJP5SK1uyMJMQbdgP4C1tNXqv49QJc1psj";

    ///@notice mint Token to specified address
    ///@dev automatic increment of token id, adding token URI upon minting
    ///@param to address to receiver of the token
    function safeMint(address to) external {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    
     /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOfNFT(uint256 tokenId) public view returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    // The following functions are overrides required by Solidity.

    function _burn(
        uint256 tokenId
    ) internal  override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public  view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title Contract for Beer NFT Creation
///@author Stanislav Bozhimirov
///@notice This is a basic contract for token creation with predefined data

contract CoffeeToken is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    ///@dev for the ERC721 token is used predefined info, can be changed before deploying
    constructor() ERC721("CoffeeToken", "CoffeE") {}

    string private uri =
        "ipfs://QmUNo3djMSTeuJP5SK1uyMJMQbdgP4C1tNXqv49QJc1psj";

    ///@notice mint Token to specified address
    ///@dev automatic increment of token id, adding token URI upon minting
    ///@param to address to receiver of the token
    function safeMint(address to) external returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    // The following functions are overrides required by Solidity.

    function _burn(
        uint256 tokenId
    ) internal  override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public  view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
