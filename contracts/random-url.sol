/*
   Oraclize ProofShield example
   This contract uses the URL-datasource to securely call off-chain a Web API.
   It uses the ProofShield technology to send back to the contract an on-chain verifiable authenticity proof.
*/

pragma solidity ^0.4.11;
// import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "./oraclizeAPI.sol";


// ORACLIZE_API FOLLOWS: FOR THE ACTUAL EXAMPLE CODE, LOOK AT THE BOTTOM!

contract usingOraclize__future is usingOraclize {
    
    modifier oraclize_proofShield_proofVerify(bytes32 _queryId, string _query, string _result, bytes _proof) {

        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)

        require((_proof[0] == "L") && (_proof[1] == "P") && (_proof[2] == 1));

        bool proofVerified = oraclize_proofShield_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        require(proofVerified);

        _;

    }

    function oraclize_proofShield_proofVerify__returnCode(bytes32 _queryId, string _result, bytes _proof) internal returns (uint8){

        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)

        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) return 1;

        bool proofVerified = oraclize_proofShield_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        if (proofVerified == false) return 2;

        return 0;

    }

    function oraclize_proofShield_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){

        uint offset = 3+65+32+ uint(proof[3+65+1])+2;

        // Step 2: verify the APPKEY1 provenance (must be signed by Ledger)

        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";

        bytes memory tosign1 = new bytes(1+65);

        tosign1[0] = 0xFE;

        copyBytes(proof, 3, 65, tosign1, 1);

        bytes memory sig1 = new bytes(uint(proof[3+65+1])+2);

        copyBytes(proof, 3+65, sig1.length, sig1, 0);

        if (verifySig(sha256(tosign1), sig1, LEDGERKEY) == false) return false;



        // Step 3: verify the attestation signature, APPKEY1 must sign the message from the correct ledger app (CODEHASH)

        bytes memory tosign2 = new bytes(130);

        copyBytes(proof, offset, 98, tosign2, 0);

        bytes memory sig2 = new bytes(uint(proof[offset+98+1])+2);

        copyBytes(proof, offset+98, sig2.length, sig2, 0);

        bytes memory CODEHASH = hex"f9d90c24eafd50fbca9558ca1f93b80cb7ffa4edb775d9dc73c3cec20df21521";

        copyBytes(CODEHASH, 0, 32, tosign2, 98);

        bytes memory appkey1_pubkey = new bytes(64);

        copyBytes(proof, 3+1, 64, appkey1_pubkey, 0);

        if (verifySig(sha256(tosign2), sig2, appkey1_pubkey) == false) return false;

        

        // Step 4: check proof verification status

        if (proof[offset+33] != 0) return false;

        

        // Step 5: check queryid match

        bytes memory vresulth = new bytes(32);

        copyBytes(proof, offset, 32, vresulth, 0);

        if (keccak256(vresulth) != keccak256(sha256(context_name, queryId))) return false;

        

        // Step 6: check result match

        copyBytes(proof, offset+66, 32, vresulth, 0);

        if (keccak256(vresulth) != keccak256(sha256(result))) return false;

        

        // Step 7: check query match

        copyBytes(proof, offset+34, 32, vresulth, 0);

        if (keccak256(vresulth, proof[offset+32]) != oraclize_proofShield_commitment[queryId]) return false;

        delete oraclize_proofShield_commitment[queryId];

        return true;

    }
    
    mapping (bytes32 => bytes32) oraclize_proofShield_commitment;

    byte constant proofShield = 0x0F;
    byte constant proofShield_Ledger = 0x0F;
}
/*
 *
 * ... RandomURLExample w/ Android & Proofshield (not stable, don't use in prod)...
 * https://github.com/oraclize/ethereum-examples/blob/master/solidity/proofshield/proofShieldExample.sol
 * NOTE: CAN be done on the javascript VM.
 * Working callback seen here: http://app.oraclize.it/home/check_query?id=55b0decbf3036985e8a5b5248139c7899f7b5d0e570d95be3e3508c8fce903b8 (failed proof!)
 * Working callback seen here: 
 *
 **/
// pragma solidity ^0.4.25;

// import "./oraclizeAPI.sol";
// // import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

// contract RandomURLExample is usingOraclize__future {

//     uint public randomNumber;
//     event LogResult(string);

//     constructor () payable public {
//         oraclize_setProof(proofType_Android | proofShield_Ledger);
//     }

//     function __callback(bytes32 _myid, string _result, bytes _proof) public {
//         require (msg.sender == oraclize_cbAddress());
//         if (oraclize_proofShield_proofVerify__returnCode(_myid, _result, _proof) == 0) {
//             emit LogResult(_result);
//         } else {
//             // ... Proof verification has failed! ...
//         }   
//     }

//     function getRandomNumber() payable public {
//         string memory query = "https://www.random.org/integers/?num=1&min=1&max=6&col=1&base=10&format=plain&rnd=new";
//         bytes32 queryId = oraclize_query("URL", query, 1000000);
//         oraclize_proofShield_commitment[queryId] = keccak256(sha256(query), proofType_Android_v2);
//     }
// }
/*

ROPSTEN
Failed instruction example: 
https://ropsten.etherscan.io/tx/0x6ab52b91ba7e49ce2b3e5cf11521da6fe837bf87c0a42027dd85fdd3eed812b1

Query ID for above:
edb2a7274d3171c7821487b9dc7ab762986f0a7d7e433cbebebd2e441c6b0596

VM
Query ID:
cb84a5560e50775b04f711e70094548df3994ac6260014a225398a84f39f8278
*/
pragma solidity ^0.4.25;

import "./oraclizeAPI.sol";
// import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract RandomURLExample is usingOraclize__future {

    uint public randomNumber;
    event LogResult(string);
    bool public failed;

    constructor () payable public {
        oraclize_setProof(proofType_Android | proofShield_Ledger);
        getRandomNumber();
    }

    function __callback(bytes32 _myid, string _result, bytes _proof) public {
        require (msg.sender == oraclize_cbAddress());
        if (oraclize_proofShield_proofVerify__returnCode(_myid, _result, _proof) == 0) {
            randomNumber = parseInt(_result);   
            emit LogResult(_result);
            failed = false;
        } else {
            failed = true;
            // ... Proof verification has failed! ...
        }   
    }

    function getRandomNumber() payable public {
        string memory query = "https://www.random.org/integers/?num=1&min=1&max=6&col=1&base=10&format=plain&rnd=new";
        bytes32 queryId = oraclize_query("URL", query);
        oraclize_proofShield_commitment[queryId] = keccak256(sha256(query), proofType_Android);
    }

    function kill() public { // FIXME: Remove!
        selfdestruct(msg.sender);
    }
}