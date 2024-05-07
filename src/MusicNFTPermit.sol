// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import "./IMusicNFTPermit.sol";

abstract contract MusicNFTPermit is ERC721URIStorage, IMusicNFTPermit, EIP712, Nonces {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint tokenId,uint256 value,uint256 nonce,uint256 deadline)");

    error ERC2612ExpiredSignature(uint256 deadline);

    error ERC2612InvalidSigner();

    constructor(string memory name) EIP712(name, "1") {}


    function permit(
        address owner,
        address spender,
        uint tokenId,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, tokenId, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner();
        }

        // 授权
        _setApprovalForAll(owner, spender, true);
    }

    function nonces(address owner) public view virtual override(IMusicNFTPermit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }
}
