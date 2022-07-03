// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Casino} from "../src/Casino.sol";


contract CasinoTest is Test {
    Casino sino;
    bytes32 startingNonce;

    function setUp() public {
        startingNonce = keccak256("seed string");
        sino = new Casino(startingNonce);
    }

    function testNonce() public {
        assertTrue(true);
        bytes32 nonce = sino.nonce();
        assertEq(startingNonce, nonce);

        uint256 ownerPrivateKey = 0xA11CE;
        address owner = vm.addr(ownerPrivateKey);
        console2.log("owner");
        console2.log(owner);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, nonce);
        console2.log(v);
        console2.logBytes32(r);
        console2.logBytes32(s);
        console2.logBytes32(nonce);
        

        address signer = ecrecover(nonce, v, r, s);

        assertEq(owner, signer);
        console2.log(signer);



    }

}
