# Recap Tries

Consider we used a trie to store DNA sequences.

- Span = number of bits to represent one digit of key = 2. (2^2=4)
- Each node must hold up to four pointers (one for every possible edge)
  - This is even sufficient in theory, we can simply store up to four pointers,
    respectively a null-value indicating that a given pointer is not present.
    - This can be done as pointers are block-aligned, so there are invalid
      pointer values to use as null values.
  - An additional four bits per node to indicate whether the given prefix is a
    key
    - Or a special terminator symbol one node further down, to indicate so

## Deletion

- First traverse until we find terminator of key we want to delete
  - Unset the terminator
  - If the node has a) no additional terminators and b) no outbound pointers
    then we can delete it
  - Then traverse one level up, rinse and repeat
  - But then: Deletions are very expensive, we need to traverse up and down a
    lot

- Better: Keep reference counter per node
- Then we just traverse to node (to verify it is present), and afterwards
  traverse upwards to find the topmost node with a reference counter of 1
- And delete anything from there below
- Can have one reference counter per node, but then deletion still requires
  going down one level to check that node's reference counter
- So instead we can have one reference counter per edge (in our case 4), don't
  need to look down to delete keys, but costs additional space.

## Example design (cleaned up)

Per node:
- 4 * 8B for pointers
- 4 * 4B for reference counters
- 4 * 1B to mark whether pointers present (but this can be embedded in
  pointers)

-> Heavily inefficient.

More efficient encodings do exist, and are used.
