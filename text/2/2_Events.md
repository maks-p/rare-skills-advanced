## Events

### How Do Marketplaces use Events to Index NFTs?

Marketplaces like OpenSea must be able to render the NFTs owned by a given wallet quickly and efficiently. This is difficult to do in the context of `ERC721` and `ERC1155` contracts (the predominant NFT standards) for two reasons:

1. Querying the blockchain for data is not as fast as querying a database and doing it at the scale required for a web2 user experience would be a difficult engineering challenge.
2. Typical NFT contracts don't have a mechansim for querying which token ids are owned by a given address - they can provide which wallet owns which token id, but not the reverse.

To provide the seamless user experience required, OpenSea and other marketplaces use offchain indexers that listen to events emitted from the NFT contracts, specifically the `Transfer` event. When an `ERC721` contract emits a `Transfer` event, typically from the zero address to a wallet (a mint), or from one wallet to another (a sale, or in some cases a trade), that event triggers an update to the offchain indexer (really, just a database), updating the state of the ownership.

It would also make sense for these systems to also regularly validate the offchain state of their indexers by calling the `ownerOf` function on chain and verifying that the expected addresses do in fact own the expected token ids. In addition, this type of check would almost certainly be used as part of the listing and sale flow.
