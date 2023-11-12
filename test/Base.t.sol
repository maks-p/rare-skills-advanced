// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Test.sol";

/**
 * @title Base test
 *
 * @author Modified from https://github.com/PaulRBerg/prb-proxy/blob/main/test/Base.t.sol
 *
 */
abstract contract BaseTest is Test {
    /**
     * @notice User accounts
     */
    struct Users {
        address payable deployer;
        address payable alice;
        address payable bob;
        address payable charlie;
        address payable user_0;
        address payable user_1;
        address payable user_2;
        address payable user_3;
        address payable admin;
    }

    Users internal users;

    function setUp() public virtual {
        users = Users({
            deployer: createUser("deployer"),
            alice: createUser("alice"),
            bob: createUser("bob"),
            charlie: createUser("charlie"),
            user_0: createUser("user_0"),
            user_1: createUser("user_1"),
            user_2: createUser("user_2"),
            user_3: createUser("user_3"),
            admin: createUser("admin")
        });
    }

    function createUser(
        string memory name
    ) internal returns (address payable addr) {
        addr = payable(makeAddr(name));
        vm.label({account: addr, newLabel: name});
        vm.deal({account: addr, newBalance: 100 ether});
    }
}
