// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {CasinoProp, Casino} from "../src/Casino.sol";

contract CasinoTest is CasinoProp, Test {
    Casino sino;
    bytes32 startingNonce;

    function signBet(uint256 key, bytes32 nonce)
        internal
        returns (Signed memory)
    {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, nonce);
        return Signed({v: v, r: r, s: s});
    }

    function testDoubleOrNothing() public {
        startingNonce = keccak256("seed string");
        Prop memory double_or_nothing = Prop({
            probability: 127,
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

        address contract_address = address(sino);
        uint256 contract_size = contract_address.balance;
        emit log_named_address("contr", address(sino));
        emit log_named_uint("bala", contract_size);

        uint256 bettor_pk = 0xB;
        address bettor = vm.addr(bettor_pk);
        vm.deal(bettor, 1 ether);
        vm.startPrank(bettor);
        emit log_named_address("bettor", bettor);
        uint256 bet_amount = 1;
        Signed memory signed = signBet(bettor_pk, sino.nonce());
        sino.placeBet{value: bet_amount}(signed);
        emit log_named_uint("nowbala", contract_address.balance);
    }
}
