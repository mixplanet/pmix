// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FungibleToken.sol";
import "./interfaces/IPolygonMix.sol";

contract PolygonMix is Ownable, FungibleToken, IPolygonMix {
    
    mapping(address => mapping(uint256 => uint256[])) private burned;
    mapping(address => mapping(uint256 => mapping(uint256 => bool))) private minted;

    constructor() FungibleToken("Polygon Mix", "PMIX", "1") {}

    function burn(uint256 toChain, uint256 amount) public override returns (uint256) {
        
        balances[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
        
        uint256[] storage burnedAmounts = burned[msg.sender][toChain];
        uint256 burnId = burnedAmounts.length;
        burnedAmounts.push(amount);
        
        emit Burn(msg.sender, amount);
        return burnId;
    }

    function burnCount(uint256 toChain) external view override returns (uint256) {
        return burned[msg.sender][toChain].length;
    }

    function mint(uint256 fromChain, uint256 burnId, uint256 amount, bytes memory signature) public override {
        require(signature.length == 65, "invalid signature length");

        bytes32 hash = keccak256(abi.encodePacked(msg.sender, fromChain, burnId, amount));
        hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28, "invalid signature version");

        require(ecrecover(hash, v, r, s) == ORACLE);

        balances[msg.sender] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);

        minted[msg.sender][fromChain][burnId] = true;
        emit Mint(msg.sender, amount);
    }

    function checkMinted(uint256 fromChain, uint256 burnId) external view override returns (bool) {
        return minted[msg.sender][fromChain][burnId];
    }
}