pragma solidity ^0.4.25;

import "./oraclizeAPI.sol";

contract RandomDataSource is usingOraclize {
    
    uint public randomNumber;

    constructor() payable public {
        oraclize_setProof(proofType_Ledger);
        getRandomBytes();
    }

    function __callback(bytes32 _queryId, string _result, bytes _proof) public { 
        require (msg.sender == oraclize_cbAddress());
        if (oraclize_randomDS_proofVerify__returnCode(_queryId, _result, _proof) == 0) {
            uint maxRange = 2 ** (8 * 7); 
            uint randomNum = uint(sha3(_result)) % maxRange;
            randomNumber = randomNum;
        } else {
            // ... Proof verification has failed - handle as necessary...
        }
    }
    
    function getRandomBytes() public payable {
        uint n = 7;
        uint delay = 0;
        uint callbackGas = 200000;
        oraclize_newRandomDSQuery(delay, n, callbackGas);
    }
}