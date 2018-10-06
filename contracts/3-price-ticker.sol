pragma solidity ^0.4.25;

import "./oraclizeFuture.sol";

contract CryptoTicker is usingOraclize__future {

    uint public price;

    constructor () payable {
        oraclize_setProof(proofType_Android | proofShield);
        getPrice();
    }

    function __callback(bytes32 _queryId, string _result, bytes _proof) public {
        require (msg.sender == oraclize_cbAddress(), "Caller is not an Oraclize address!");
        if (oraclize_proofShield_proofVerify__returnCode(_queryId, _result, _proof) == 0) {
            price = parseInt(_result);
        } else {
            // ... Proof has failed - handle as necessary...
        }
    }

    function getPrice() payable public {
        string memory query = "json(https://www.bitstamp.net/api/v2/ticker/ethusd).last";
        bytes32 queryId = oraclize_query("URL", query);
        oraclize_proofShield_commitment[queryId] = keccak256(sha256(query), proofType_Android);
    }
}