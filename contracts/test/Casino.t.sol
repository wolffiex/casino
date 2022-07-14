// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {CasinoProp, Casino} from "../src/Casino.sol";


contract CasinoTest is CasinoProp,Test {
    Casino sino;
    bytes32 startingNonce;

    function testNonce() public {
        startingNonce = keccak256("seed string");
        Prop memory double_or_nothing = Prop({
            probability : 127,
            odds : Odds({
                mult: 2,
                div: 0
            })
        });
        Prop[] memory props = new Prop[](1);
        props[0] = double_or_nothing;
        sino = new Casino(startingNonce, props);

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
        Prop[] memory got_props = sino.getProps();
        console2.log("probabl");
        console2.log(got_props[0].probability);
        

        address signer = ecrecover(nonce, v, r, s);

        assertEq(owner, signer);
        console2.log(signer);

        bytes32 next1 = keccak256(abi.encode(nonce));
        bytes32 next2 = keccak256(abi.encode(next1));
        bytes32 next3 = keccak256(abi.encode(next2));
        bytes32 next4 = keccak256(abi.encode(next3));
        bytes32 next5 = keccak256(abi.encode(next4));

        console2.log("hash rotation");
        console2.logBytes32(next1);
        console2.logBytes32(next2);
        console2.logBytes32(next3);
        console2.logBytes32(next4);
        console2.logBytes32(next5);



    }

}
