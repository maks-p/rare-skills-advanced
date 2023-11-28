import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import * as fs from "fs";

const values = [
  ["0x0000000000000000000000000000000000000001", "0", 2],
  ["0x0000000000000000000000000000000000000002", "1", 2],
  ["0x0000000000000000000000000000000000000003", "2", 2],
  ["0x0000000000000000000000000000000000000004", "3", 2],
  ["0x0000000000000000000000000000000000000005", "4", 2],
];

const tree = StandardMerkleTree.of(values, ["address", "uint256", "uint256"]);

console.log("Merkle root: ", tree.root);

fs.writeFileSync("merkle-tree.json", JSON.stringify(tree.dump()));
