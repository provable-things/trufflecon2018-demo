/*
 *
 * ... RandomComputationExample w/ TLS Notary Proof ...
 * 
 * Note: CAN be done with the Javascript vm (though proof may fail?)
 * Working callback seen here: http://app.oraclize.it/home/check_query?id=a6fe041010e08e3dab6d097c248030d3217aef49d1733f22b11fc561391d81e9
 * Both the Docker file and the python script files get zipped into a file that must be named "archive.zip", 
 * and uploaded to IPFS. The IPFS multihash then returned goes into the `oraclize_query` per above. 
 *
 * ... Docker File Contents ...
 * 
 * FROM frolvlad/alpine-python3
 * MAINTAINER Oralize "info@oraclize.it"
 * 
 * COPY dice-roll.py /
 * 
 * CMD python dice-roll.py
 * 
 * ... dice-roll.py Contents ...
 * 
 * #!/usr/bin/python
 * import random
 * print(random.randint(1,6))
 * 
 **/
pragma solidity ^0.4.25;

// import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "./oraclizeAPI.sol";

contract RandomComputationExample is usingOraclize {
    
    uint public randomNumber;
    event LogNewRandomNumber(string);

    constructor() payable public {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
    }

    function __callback(bytes32 _queryId, string _result, bytes _proof) public { 
        require (msg.sender == oraclize_cbAddress());
        uint rand = parseInt(_result);
        randomNumber = rand;
        LogNewRandomNumber(_result);
    }
    
    function getRandomNumber() public payable {
        oraclize_query("computation", ["QmTRm7ubPAruzwp6Cw2bqqZzgRtWgxoi7mPddF31LB3u7w"]);
    }
}