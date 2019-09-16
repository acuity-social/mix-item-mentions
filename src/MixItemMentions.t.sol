pragma solidity ^0.5.11;

import "ds-test/test.sol";

import "./MixItemMentions.sol";

contract MixItemMentionsTest is DSTest {
    MixItemMentions mentions;

    function setUp() public {
        mentions = new MixItemMentions();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
