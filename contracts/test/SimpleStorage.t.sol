// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";


contract SimpleStorageTest is Test {
    SimpleStorage rage;

    function setUp() public {
        rage = new SimpleStorage("l;kfjd");
    }

    function testStorage() public {
        assertEq("l;kfjd", rage.getValue());
        rage.setValue("kdkd");
        assertEq("kdkd", rage.getValue());
    }
}
