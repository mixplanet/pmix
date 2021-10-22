// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IFungibleToken.sol";

interface IPolygonMix is IFungibleToken {
    function burn(uint256 toChain, uint256 amount) external returns (uint256 burnId);
    function burnCount(uint256 toChain) external view returns (uint256);
    function mint(uint256 fromChain, uint256 burnId, uint256 amount, bytes memory signature) external;
    function checkMinted(uint256 fromChain, uint256 burnId) external view returns (bool);
}