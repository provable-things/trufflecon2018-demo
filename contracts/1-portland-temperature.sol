pragma solidity ^0.4.25;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract PortlandTemperature is usingOraclize {
    
    bool public jacketRequired;
    uint public tempUnderWhichJacketRequired = 15;

    constructor() payable public {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        getTemperature();
    }

    function __callback(bytes32 _queryId, string _result, bytes _proof) public { 
        require (msg.sender == oraclize_cbAddress(), "Caller is not an Oraclize address!");
        jacketRequired = parseInt(_result) <= tempUnderWhichJacketRequired;
    }
    
    function getTemperature() payable public {
        oraclize_query("URL", "json(https://fcc-weather-api.glitch.me/api/current?lat=45.51&lon=-122.66).main.temp");
    }
}