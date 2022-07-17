// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {CasinoProp, Casino} from "../src/Casino.sol";

contract CasinoTest is CasinoProp, Test {

    bytes32 game_nonce;
    function setUp() public {
        game_nonce = keccak256("strating");
    }

    function signBet(uint256 key, bytes32 nonce)
        internal
        returns (Signed memory)
    {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, nonce);
        return Signed({v: v, r: r, s: s});
    }

    function testDoubleOrNothing() public {
        Prop memory double_or_nothing = Prop({
            probability: 51,
            odds: Odds({numerator: 2, denominator: 1})
        });
        Prop[] memory props = new Prop[](1);
        props[0] = double_or_nothing;
        permuteGame(props);
    }

    function testBigPayout() public {
        Prop memory one_in_ten = Prop({
            probability: 10,
            odds: Odds({numerator: 21, denominator: 2})
        });
        Prop[] memory props = new Prop[](1);
        props[0] = one_in_ten;
        permuteGame(props);
    }

    uint pk = 0xA;
    function permuteGame(Prop[] memory props) internal {
        int total = 0;
        for (uint i=0; i < 20; i++) {
            total += runGame(props);
        }
        emit log_named_int("meta:", total);
    }

    function runGame(Prop[] memory props) internal returns (int) {
        game_nonce = keccak256(abi.encode(game_nonce, props));
        Casino sino;
        uint256 bank_pk = 0xC;
        address bank = vm.addr(bank_pk);
        vm.deal(bank, 10 ether);
        vm.startPrank(bank);
        uint contract_value = 1000;
        sino = new Casino{value: contract_value}(game_nonce, props);
        vm.stopPrank();

        uint256 bettor_pk = 0xD;
        address bettor = vm.addr(bettor_pk);
        vm.deal(bettor, 10 ether);
        vm.startPrank(bettor);
        for (uint i=0; i< 1000; i++) {
            makeBet(sino, 1, bettor_pk, bank_pk);
        }
        vm.stopPrank();
        int bank_result = int(address(sino).balance) - int(contract_value);
        emit log_named_int("result:", bank_result);
        return bank_result;
    }

    function makeBet(Casino sino, uint amount, uint256 bettor_pk, uint256 bank_pk) public {
        Signed memory signed = signBet(bettor_pk, sino.nonce());
        sino.placeBet{value: amount}(signed);
        sino.resolveBet(signBet(bank_pk, sino.nonce()));
    }
}
