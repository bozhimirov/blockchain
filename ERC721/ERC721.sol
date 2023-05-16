// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;
import "./IERC721.sol";
import "./IERC165.sol";
import "./IERC721Metadata.sol";
import "./IERC721TokenReceiver.sol";

contract ERC721 is IERC721, IERC165, IERC721Metadata, IERC721TokenReceiver {
    mapping(address => uint256) balance;
    mapping(uint256 => address) owners;
    mapping(address => mapping(address => bool)) private operatorApprovals;
    mapping(uint256 => address) private tokenApprovals;

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "Not valid address");
        return balance[_owner];
    }

    function _ownerOf(uint256 tokenId) internal view returns (address) {
        return owners[tokenId];
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "Invalid token ID");
        return owner;
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool)
    {
        return operatorApprovals[owner][operator];
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        address owner = _ownerOf(tokenId);
        return (spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender);
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        _requireMinted(tokenId);

        return tokenApprovals[tokenId];
    }

    function _requireMinted(uint256 tokenId) internal view {
        require(_exists(tokenId), "Invalid token ID");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 tokenId
    ) external payable {
        _safeTransferFrom(_from, _to, tokenId, "");
    }
    
    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 tokenId,
        bytes memory data
    ) external payable {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Not token owner or approved"
        );
        _safeTransfer(_from, _to, tokenId, data);
    }


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Not token owner or approved"
        );

        _transfer(from, to, tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal  {
        require(_ownerOf(tokenId) == from, "Transfer from incorrect owner");
        require(to != address(0), "Transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        require(_ownerOf(tokenId) == from, "Transfer from incorrect owner");

        delete tokenApprovals[tokenId];

        unchecked {
            
            balance[from] -= 1;
            balance[to] += 1;
        }
        owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "Transfer to non ERC721Receiver implementer");
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(_ownerOf(tokenId) == from, "Transfer from incorrect owner");
        require(to != address(0), "Transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        require(_ownerOf(tokenId) == from, "Transfer from incorrect owner");

        delete tokenApprovals[tokenId];

        unchecked {
            balance[from] -= 1;
            balance[to] += 1;
        }
        owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721TokenReceiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal {}

    
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal  {}

    function _approve(address to, uint256 tokenId) internal  {
        tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function approve(address to, uint256 tokenId) public {
        address owner = _ownerOf(tokenId);
        require(to != owner, "Approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "Approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    
    function getApproved(uint256 tokenId) public view  returns (address) {
        _requireMinted(tokenId);

        return tokenApprovals[tokenId];
    }

    
    function setApprovalForAll(address operator, bool approved) public  {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal  {
        require(owner != operator, "Approve to caller");
        operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

}
