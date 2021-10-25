pragma solidity ^0.5.6;

import "./klaytn-contracts/ownership/Ownable.sol";
import "./interfaces/IMixSender.sol";
import "./interfaces/IMix.sol";

contract MixSender is Ownable, IMixSender {

    IMix public mix;
    address public signer;

    mapping(address => mapping(uint256 => uint256[])) public sended;
    mapping(address => mapping(uint256 => mapping(uint256 => bool))) public received;

    constructor(IMix _mix, address _signer) public {
        mix = _mix;
        signer = _signer;
    }

    function setSigner(address _signer) onlyOwner external {
        signer = _signer;
        emit SetSigner(_signer);
    }

    function sendOverHorizon(uint256 toChain, uint256 amount) public returns (uint256) {
        mix.transferFrom(msg.sender, address(this), amount);
        
        uint256[] storage sendedAmounts = sended[msg.sender][toChain];
        uint256 sendId = sendedAmounts.length;
        sendedAmounts.push(amount);
        
        emit SendOverHorizon(msg.sender, amount);
        return sendId;
    }

    function sendCount(address sender, uint256 toChain) external view returns (uint256) {
        return sended[sender][toChain].length;
    }

    function receiveOverHorizon(uint256 fromChain, uint256 sendId, uint256 amount, bytes memory signature) public {
        require(signature.length == 65, "invalid signature length");
        require(received[msg.sender][fromChain][sendId] != true);

        bytes32 hash = keccak256(abi.encodePacked(msg.sender, fromChain, sendId, amount));
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

        mix.transfer(msg.sender, amount);

        received[msg.sender][fromChain][sendId] = true;
        emit ReceiveOverHorizon(msg.sender, amount);
    }
}
