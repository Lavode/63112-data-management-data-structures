# LSM trees recap

- General idea: Split in two.
  - One region in memory
  - One region in storage
- Storage region has multiple tiers
  - Growing in size with each layer (usually exponentially)
  - "Chunks" (in all disk tiers) called SSTables. ~ 'files' containing data
- Storage tiers are often implemented as skiplist (or also generic trees)

## Insertion

- First make log entry (for ACID purposes)
- Insert in whatever data structure we use for memory region

## Compaction (flush to disk)

- Triggered once in-memory data structure hits threshold
- Flush to first disk tier
  - Traverse memory data structure, keeping track of min/max
  - Write new SSTable to disk

## Merging (Flush disk to disk)

- Triggered when one tier of disk is full
- Merges upper-tier SSTables into lower-tier SSTables
  - Create **non-overlapping** SSTables 
    - More performant for future lookups
    - And also for future merging, as (hopefully) fewer files will be involved
      in future merges
  - This creates write-amplification, so is expensive

### SSTable

- "A file"
  - Immutable, never updated after it's written initially.
- Metadata
  - Key range (min and max)
    - Allows to see, at a glance, whether a given key could potentially be in
      the SSTable we look at
  - Bloom filter
  - Fixed-size index, providing key -> (approximate) location in SSTable size
    - Fixed size means that this index might not use the actual keys, but
      sufficiently short separator keys inbetween the actual keys
    - Or subset of actual keys
    - Or truncated keys
    - Fixed-size allows nicely caching in memory
- Data
  - Sorted values

## Lookup

- Merge iterator
 - Gathers all sstables which (based on min/max) might contain key
 - Discards all where bloom filter shows key not present in sstable
 - Gets initial position in all SSTables using its index
 - Iterates over all remaining SSTables until it finds the looked-up key
   somewhere (or all iterators terminate)

## Application

- We want to store a very wide (lots of columns) table as an LSM tree.
- Schema stored in another place. We then store `PK -> (a, b, c, ...)` in LSM
  tree
- Problem: Query such as `SELECT b FROM table WHERE pk = x` will read all the
  attributes of one tuple while we only care about one
- Solution:
  - Column families. Group columns such that we are likely to read all
    columns within one family at once (e.g. related attributes)
  - Then store each `PK -> family` in its own (LSM tree? SSTable? ...)

# Tries

Four kind of indexing structures:
- Hash based
- Trees
- Sorted arrays
- Tries
- Arguably a fifth: Graphs


- Trie is a prefix tree, keys spread along edges, one 'part' of key (e.g. byte)
  per node
- No balancing, shape depends on distribution of keys
- Lookup complexity depends on length of key
  - Compare b-tree: log in number of keys
- But lookup can terminate early if key does not exist
  - Compare b-tree: Must always go to leaf node

- Motivation:
  - In B-Tree we need, at each level, to perform a comparison of the lookup key
    with the separators
    - B-Tree designed to be partially on disk
  - Comparisons can be comparably expensive, consider e.g. comparisons of large
    strings
    - And each level of tree will require one comparison, yet in the end the
      key might not be present
  - In trie, we can simply use the x-th byte of the key to look up the next node
    - More efficient if we already hold all of it in memory

- We can represent a trie's node as a fixed-size array of pointers (size =
  fanout factor)
- Then traversal is just some array accesses
  - At i-th level, with k_i i-th byte of key, check if array[k_i] holds a
    pointer
  - If a comparison returns false, we can immediately return
  - And comparisons also always of 'small' values, e.g. pointers

- Span == fanout factor. Number of bits encoded per 'part' of key
  - E.g 256 if using bytes

- Potential optimization: Can compact sequence of `count` repeated `node` into
  `(count, node)`
  - Or even leave out `count`, but then you might get false positive matches

- Choosing span
  - Small span -> compact representation, but large depth, lots of comparisons
  - Large span -> potentially wasteful representation, but few comparisons
  - E.g. Judy implementation: Picks span per node, based on how populated it is


