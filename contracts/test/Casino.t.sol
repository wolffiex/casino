// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {CasinoProp, Casino} from "../src/Casino.sol";

contract CasinoTest is CasinoProp, Test {

    function signBet(uint256 key, bytes32 nonce)
        internal
        returns (Signed memory)
    {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, nonce);
        return Signed({v: v, r: r, s: s});
    }

    function testDoubleOrNothing() public {
        Casino sino;
        bytes32 startingNonce = keccak256("seed string");
        Prop memory double_or_nothing = Prop({
            probability: 50,
            odds: Odds({numerator: 2, denominator: 1})
        });
        Prop[] memory props = new Prop[](1);
        props[0] = double_or_nothing;
        uint256 bank_pk = 0xA;
        address bank = vm.addr(bank_pk);
        vm.deal(bank, 1 ether);
        vm.startPrank(bank);
        sino = new Casino{value: 1000}(startingNonce, props);
        vm.stopPrank();

        uint256 bettor_pk = 0xB;
        address bettor = vm.addr(bettor_pk);
        vm.deal(bettor, 1 ether);
        vm.startPrank(bettor);
        emit log_named_address("bettor", bettor);
        for (uint i=0; i< 1000; i++) {
            makeBet(sino, 1, bettor_pk, bank_pk);
        }
        emit log_named_uint("contract:", address(sino).balance);
        emit log_named_uint("bettor:", bettor.balance);
        uint total = address(sino).balance + bettor.balance;
        emit log_named_uint("total:", total);
    }

    function testBigPayout() public {
        Casino sino;
        bytes32 startingNonce = keccak256("sed string");
        Prop memory one_in_ten = Prop({
            probability: 11,
            odds: Odds({numerator: 10, denominator: 1})
        });
        Prop[] memory props = new Prop[](1);
        props[0] = one_in_ten;
        uint256 bank_pk = 0xC;
        address bank = vm.addr(bank_pk);
        vm.deal(bank, 1 ether);
        vm.startPrank(bank);
        sino = new Casino{value: 1000}(startingNonce, props);
        vm.stopPrank();

        uint256 bettor_pk = 0xD;
        address bettor = vm.addr(bettor_pk);
        vm.deal(bettor, 1 ether);
        vm.startPrank(bettor);
        emit log_named_address("bettor", bettor);
        for (uint i=0; i< 1000; i++) {
            makeBet(sino, 1, bettor_pk, bank_pk);
        }
        emit log_named_uint("contract:", address(sino).balance);
        emit log_named_uint("bettor:", bettor.balance);
        uint total = address(sino).balance + bettor.balance;
        emit log_named_uint("total:", total);
    }

    function makeBet(Casino sino, uint amount, uint256 bettor_pk, uint256 bank_pk) public {
        Signed memory signed = signBet(bettor_pk, sino.nonce());
        sino.placeBet{value: amount}(signed);
        sino.resolveBet(signBet(bank_pk, sino.nonce()));
    }
}
