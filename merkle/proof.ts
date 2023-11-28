import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import * as fs from "fs";

const tree = StandardMerkleTree.load(
  JSON.parse(fs.readFileSync("merkle-tree.json").toString())
);

for (const [index, value] of tree.entries()) {
  const proof = tree.getProof(index);
  console.log("Address: ", value[0]);
  console.log("  Value: ", value);
  console.log("  Proof: ", proof);
}
