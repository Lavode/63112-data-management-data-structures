# B-Trees

## Introduction

- Very balanced performance across queries, updates and utilities 
  (= creation/removal of indices, defragmentation, consistency checks)
- Queries include predicate and range lookups
- Current commonly known tradeoffs assume non-random access cold storage, e.g.
  spinning disks. New disk medium provides random access to all sectors,
  allowing to e.g. focus on index hopping over sequential scans.

## Basics

- B-trees preserve sorting, being benefical for many DB operations such as joins
- B-trees optimized for block-access / paged environments, as node size can be
  flexibly chosen to be multiple of page size. Hence suitable for HDDs, but
  also e.g. RAM which, behind CPU caches, can be thought of as a block device.

- These days, usually only data in leaf nodes. Ensures that deletions only
  affect leaf nodes, and separator keys (in branch nodes) can be chosen more
  freely.
- Contents of branch and leaf nodes is sorted too, facilitating quick search
  within a node.

- Pointers to children are required. Pointers to neighbours common. Pointers to
  parents uncommon, as it causes lots of updates in case of parent changes.
- For page-based environments, pointer == page number.

- Nodes contain additional fields, e.g. depth, record count, ...

- If tree has large fan-out (multiple hundres), then depth will usually be very
  low, and most nodes will be leaves.

### Prefix / exact search

- Needs one root-leaf traversal, so `log_F(N/L)`
  - For each branch node, `log_2(F)` for binary search to find appropriate child
  - For leaf, `log_2(L)` to find appropriate data value
  - So complexity `O(log_F(N/L) * log_2(F) + log_2(L)) = O(N)`
- Exact search terminates once leaf reached, range search will have to follow
  neighbouring leaves until upper bound reached
- Range scans can use parent/grandparent pointers to allow parallel retrieval
  of (potentially) relevant child nodes

### Insertion

- Find appropriat leaf
- If space left, insert and finish
- Else split leaf if space left in parent
- If no space left in parent, split grandparent
- ...
- If root node must split, b-tree grows by one level by adding a *new* root
  node with two children
- **Depth of b-tree grows at root, this guarantees balance**

### Load balancing

- Optionally delay splits by shifting elements to neighbouring leaf nodes.
  Improves space usage at cost of code complexity.

### Deletion

- Find appropriate leaf
- Delete. If node more than half full, terminate
- Else, load-balance or merge with siblings
- Merging can cause underflow of parent node

- Alternatively: Let underflows be. Removes complexity of merging or load
  balancing, and issues will probably be fixed by subsequent insertions or
  defragmentations

## Advanced

### Node size

- Optimal node size dpeends on access latency and transfer bandwidth, plus
  record size
  High latency and high bandwidth increase optimal node size
- Larger (e.g. 1MB) on modern spinning disks, a few KB on flash devices

### Variable size records

- Achieved by layer of indirection
- Indirection layer contains fixed-length pointers to record data
  - Sorted by search term
- Variable-length record data contains data values
- Indirection and record spaces can grow towards each other, with free space in
  the middle

### Normalized keys

- Goal: Convert (composite) key into binary string, such that
  sorting/comparison on composite key can be done with naive sorting/comparison
  of binary string.
- E.g encode integer as 1 bit indicating whether value present (1) or is null
  (0), followed by 32 bits encoding for integer. Then, non-present values will
  'sort lower' than present ones, also for composite keys which have later
  non-null fields.
- Can lose information, e.g. if case-insensitive sort desired, then binary
  string will not allow to deduce case of original value
  - Solutions: Also store original value, or store additional information
    required to deduce casing. Or use normalized keys only for branches, not
    for leaves.

### Prefix B-Trees

- Truncation: If keys in node have common prefix, store it only once and
  truncate it from the keys
  - Made much easier by key normalization
