## Alternative Token Standards

### Summary

Both the `ERC-777` and `ERC-1363` token standards attempt to solve issues inherent to the `ERC-20` standard, specifically the two step `approve` and `transfer` flow required to perform an action (execute a function) in a contract when payment in tokens is required. The core issue is the lack of a mechanism for smart contracts to be notified when they have received `ERC-20` tokens, and as such they are unable to take any action upon receipt of those tokens. Instead, the sender needs to `approve` the receiving contract and then call an executing function on that receiver, which would then use `transferFrom` internally to pull the tokens in. The separate transactions mean users need to pay gas twice to effectively execute a single action.

The `ERC-777` and `ERC-1363` both attempt to solve this issue in a similar way, utilizing hooks implemented by the receiving contract and typically called by an internal function inside the token's transfer function called by the sender.

One way to think about these approaches is that they desire to make `ERC-20` tokens behave like Ether - in other words, `payable`. Contracts implementing these standards can effectively define `fallback` functions for `ERC-20` tokens, where the token amount sent behaves like `msg.value` internally.

`ERC-1363` is a more lightweigh implementation than `ERC-777`, and is inspired by the `onERC721Recieved` and `ERC721TokenReceiver` mechanisms. While care should be taken with both standards, `ERC-1363` is a safer implementation as the reentrancy issue can be more easily handled and represents less of a footgun than the `ERC-777` implementation (see below).

### `ERC-20`

Two step typical flow:

1. `approve` → `IERC20(token).approve(contractAddress, 1e18)`
2. call function on approved contract → `contractAddress.doThing()` → calls `transferFrom` internally, e.g. `IERC20(token).transferFrom(msg.sender, address(this), 1e18)`.

### `ERC-777`

1. `send` → `IERC777(token).send(contractAddress, 1e18, "")`. The registered `tokensReceived` function then internally calls `doThing`.

### `ERC-1363`

1. `transferAndCall` → calls `transfer`, then internally calls the receiver -> `IERC1363Receiver(to).onTransferReceived(_msgSender(), from, value, data)`, which can then internally call `doThing`.

### Issues with `ERC-777`

Beyond aesthetic concerns around the implementation - which is bloated and has been described by the community as "over-engineered", `ERC-777` introduces significant security concerns - specifically reentrancy - centered on its use of hooks.

Hooks allow streamlining of the sending process and offer a single way to send tokens to any recipients. The `tokensReceived` hook enables contracts to react and prevent locking tokens upon receipt.

- `tokensToSend` is implemented by the sending account and executes every time tokens are about to be sent from the given address
- `tokensReceived` is implemented by the receiving account and runs after the registered address has received tokens.

Notably, the standard specifically calls for the the following order of operations when transferring tokens:

1. Call `tokensToSend` on the sender contract
2. Execute the transfer e.g. _modify state_
3. Call `tokensReceived`

The `tokensToSend` call does not follow the widely recommended Checks-Effects-Interactions pattern → state has not been updated yet, but an external contract is now in control of the execution. Depending on how a contract is implemented the above can introduce significant security issues, as discovered in this [Uniswap ERC-777 attack vector](https://blog.openzeppelin.com/exploiting-uniswap-from-reentrancy-to-actual-profit). The fundamental problem stems from the order in which Uniswap would swap tokens, and the fact that prior to actually transferring tokens from the sender to Uniswap, the `tokensToSend` hook is called, which means the sender is now in control of the execution and can call back into the Uniswap `swap` function while the global state is an incorrect state.

The above issue is exacerbated by the standard's stated goal of `ERC-20` backwards compatiblity, meaning that calling `transferFrom` on an `ERC-777` token works, but behaves differently (and more dangerously) than the same call on an `ERC-20` token.
