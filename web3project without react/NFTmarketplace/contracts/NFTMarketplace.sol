// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./NFT.sol";

contract NFTMarketplace is NFT {
    struct Sale {
        address seller;
        uint256 price;
    }

    event NFTListed(
        address indexed collection,
        uint256 indexed id,
        uint256 price
    );

    //collection => id => price
    mapping(address => mapping(uint256 => Sale)) public nftSales;
    mapping(address => uint256) public profits;

    function listNFTForSale(
        address collection,
        uint256 id,
        uint256 price
    ) external {
        require(price != 0, "price must be greater than 0");
        require(
            nftSales[collection][id].price == 0,
            "NFT is already listed for sale"
        );
        nftSales[collection][id] = Sale({seller: msg.sender, price: price});

        emit NFTListed(collection, id, price);

        IERC721(collection).transferFrom(msg.sender, address(this), id);
    }

    function unlistNFT(address collection, uint256 id, address to) external {
        Sale memory sale = nftSales[collection][id];
        require(sale.price != 0, "NFT is not listed for sale");
        require(sale.seller == msg.sender, "Only owner can unlist NFT");
        delete nftSales[collection][id];

        IERC721(msg.sender).safeTransferFrom(address(this), to, id);
    }

    function purchaseNFT(
        address collection,
        uint256 id,
        address to
    ) external payable {
        Sale memory sale = nftSales[collection][id];
        require(sale.price != 0, "NFT is not listed for sale");
        require(msg.value == sale.price, "Incorrect price");
        // sale.price = 0; not clomplete see below

        // nftSales[collection][id] = Sale({
        //     seller: address(0),
        //     price: 0});  more correct as below
        delete nftSales[collection][id];

        profits[sale.seller] += msg.value;
        console.log("seller: %s", sale.seller);

        IERC721(collection).safeTransferFrom(address(this), to, id);
    }

    function claimProfit() external {
        uint256 profit = profits[msg.sender];
        console.log("claimProfit()");
        console.log("profit: %s", profit);
        console.log("msg.sender: %s", msg.sender);
        require(
            address(this).balance >= profit,
            "Address: insufficient balance"
        );
        require(profit != 0, "No profit to claim");
        profits[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: profit}("");
        require(
            success,
            "Address: unable to send value, recepient may have reverted"
        );
    }
}
