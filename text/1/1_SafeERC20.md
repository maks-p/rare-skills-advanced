## SafeERC20

### Summary

OpenZeppelin maintains a `SafeERC20` library ([github](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol)) that should be used whenever your contract needs to call `transfer` or `transferFrom` on arbitrary `ERC-20` token contracts.

### Background

The `ERC-20` Standard ([github](https://eips.ethereum.org/EIPS/eip-20)) requires that `transfer` and `transferFrom` throw a `boolean` value upon execution, and _optionally_ reverts in case of failure. The behavior on failure - to return `false` or revert execution - was widely argued within the community, with some resulting confusion regarding the adopted standard.

The standard API as per the EIP:

- `function transfer(address _to, uint256 _value) public returns (bool success)`
- `function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)`

However, not all `ERC-20` contracts abide by this standard, including notably USDT, which does not return a boolean on `transfer` or `transferFrom` ([etherscan](https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7#code)).

The problem that arises is because developers expect a boolean to be returned from those calls, this return value should be checked with the function reverting if it returns `false` - which happens to be the default value returned by non-compliant `ERC-20` contracts like USDT. So even if the transfer should succeed, no boolean value is returned, and the calling contract will revert.

An additional issue arises amongst developers that _expect_ failures to revert and do not check the return value of the call - this approach is not recommended, but would be safe if only integrating with tokens that implement the OpenZeppelin `ERC-20` implementation for example.

### Solution

`SafeERC20` allows developers to safely integrate with arbitrary `ERC-20` contracts by handling both issues above:

- For tokens that do not return a value on `transfer` and `transferFrom` calls, `SafeERC20` assumes non-reverting calls to be successful.
- For tokens that do not revert in case of failure and rather return `false`, `SafeERC20` will throw on failure (e.g. revert execution).

With these conventions, developers can call `safeTransfer` or `safeTransferFrom` safely, and without checking a return value, understanding that regardless of the underlying token implementation, the call will revert on failure.
