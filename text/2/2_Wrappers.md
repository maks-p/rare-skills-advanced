## Wrapped NFTs

Wrapping an NFT is essentially a mechanism for locking an underlying NFT (the NFT to be wrapped) in a `ERC721` contract that mints a NFT representing that interest. The wrapper NFT can always be burned to retrieve the underlying NFT.

The purpose for this is primarily to build some property or interoperability into the underlying NFT. For example, wrapped cryptopunks wrap the underlying cryptopunk because the contract does not integrate well with marketplaces and lending platforms.

Wrapping an NFT enables intergrations with other platforms that may need to rely on some assurance, data or other properties that are built into the wrapper. For example, a lending platform may wrap multiple NFTs into a single `ERC721` "bundle" that an then be borrowed against. The wrapper contract can share data about the contents wrapped inside. In this way, wrappers make the NFT ecosystem more composable and more interoparable.

One notable property of wrappers is that while the wrapper NFT is tradeable and can be used as collateral, the underlying NFT remains in the wrapping contract. The wrapper is essentially just a vault, and the wrapping NFT is the key that unlocks the underlying collateral for its holder.
