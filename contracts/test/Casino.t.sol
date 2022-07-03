// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Casino} from "../src/Casino.sol";


contract CasinoTest is Test {
    Casino sino;
    bytes32 constant startingNonce = "this can be anything";

    function setUp() public {
        sino = new Casino(startingNonce);
    }

    function testNonce() public {
        assertTrue(true);
        bytes32 nonce = sino.nonce();
        assertEq(startingNonce, nonce);
    }

}
