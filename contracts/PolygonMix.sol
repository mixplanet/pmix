// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FungibleToken.sol";
import "./interfaces/IPolygonMix.sol";

contract PolygonMix is Ownable, FungibleToken, IPolygonMix {

    address public signer;

    mapping(address => mapping(uint256 => mapping(address => uint256[]))) public sended;
    mapping(address => mapping(uint256 => mapping(address => mapping(uint256 => bool)))) public received;

    constructor(address _signer) FungibleToken("Polygon Mix", "PMIX", "1") {
        signer = _signer;
    }

    function setSigner(address _signer) onlyOwner external {
        signer = _signer;
        emit SetSigner(_signer);
    }

    function sendOverHorizon(uint256 toChain, address receiver, uint256 amount) public override returns (uint256) {
        _burn(msg.sender, amount);
        
        uint256[] storage sendedAmounts = sended[msg.sender][toChain][receiver];
        uint256 sendId = sendedAmounts.length;
        sendedAmounts.push(amount);
        
        emit SendOverHorizon(msg.sender, toChain, receiver, amount);
        return sendId;
    }

    function sendCount(address sender, uint256 toChain, address receiver) external view override returns (uint256) {
        return sended[sender][toChain][receiver].length;
    }

    function receiveOverHorizon(uint256 fromChain, uint256 toChain, address sender, uint256 sendId, uint256 amount, bytes memory signature) public override {

        require(signature.length == 65, "invalid signature length");
        require(received[msg.sender][fromChain][sender][sendId] != true);

        require(toChain == block.chainid);

        bytes32 hash = keccak256(abi.encodePacked(msg.sender, fromChain, toChain, sender, sendId, amount));
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

        require(ecrecover(hash, v, r, s) == signer);

        _mint(msg.sender, amount);

        received[msg.sender][fromChain][sender][sendId] = true;
        emit ReceiveOverHorizon(msg.sender, fromChain, sender, amount);
    }
}