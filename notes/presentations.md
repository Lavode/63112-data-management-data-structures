# Keep in mind

- Two families of trees
  - KD partitions on space (partitions stretch across full remainder of space)
  - Quad tree partitions on data
    - Each inserted point defines its own four (if dimensions = 2) quadrants,
      into which subsequent parts are inserted
    - (Partitions stretch across full quadrant into which node is inserted)

- Approximate kNN: Indexing a lot of data points and dimensions, for when one
  cannot calculate exact kNN.
  - Graph-based, as "you cannot search through a large high-dimensional tree"
  - Whereas a graph (small-world observation) connects any two points with few
    hops
  - For searching, enter graph in random point, then move (along graph) in
    direction of lowest distance to point we mean to look up
  - Eventually we arrive at point we want to look up
    - Consider its neighbours
    - And all the ones along the path we took, some of them are
    - Pick k nearest ones from that set
  - Can repeat the procedure multiple times with random starting points to
    improve results

- Graph based structures: Most important task is how to build the graph so that
  it will solve the problem at hand
