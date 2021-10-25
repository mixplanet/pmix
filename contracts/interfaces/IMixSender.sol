pragma solidity ^0.5.6;

interface IMixSender {

    event SetSigner(address indexed signer);
    event SendOverHorizon(address indexed sender, uint256 amount);
    event ReceiveOverHorizon(address indexed receiver, uint256 amount);

    function signer() external view returns (address);
    function sendOverHorizon(uint256 toChain, uint256 amount) external returns (uint256 sendId);
    function sended(address sender, uint256 toChain, uint256 index) external view returns (uint256 amount);
    function sendCount(address sender, uint256 toChain) external view returns (uint256);
    function receiveOverHorizon(uint256 fromChain, uint256 sendId, uint256 amount, bytes calldata signature) external;
    function received(address receiver, uint256 fromChain, uint256 sendId) external view returns (bool);
}