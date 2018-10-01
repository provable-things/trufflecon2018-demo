/*
 *
 * RandomDataSourceExample w/ Ledger Proof & Proofshield...
 * Note: CANNOT be done on the Javascript VM.
 * Note: Use kovan for super fast blocks (get the right ether though)
 *
 **/
pragma solidity ^0.4.25;

import "./oraclizeAPI.sol";
// import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract RandomDataSourceExample is usingOraclize {
    
    uint public randomNumber;
    event LogNewRandomNumber_uint(uint);

    constructor() payable public {
        oraclize_setProof(proofType_Ledger);
    }

    function __callback(bytes32 _queryId, string _result, bytes _proof) public { 
        require (msg.sender == oraclize_cbAddress());
        if (oraclize_randomDS_proofVerify__returnCode(_queryId, _result, _proof) == 0) {
            uint maxRange = 2 ** (8 * 7); 
            uint randomNum = uint(sha3(_result)) % maxRange;
            randomNumber = randomNum;
            emit LogNewRandomNumber_uint(randomNum);
        } else {
            // ... Proof verification has failed! ...
        }
    }
    
    function update() public payable {
        uint N = 7;
        uint delay = 0;
        uint callbackGas = 200000;
        bytes32 queryId = oraclize_newRandomDSQuery(delay, N, callbackGas);
    }
}