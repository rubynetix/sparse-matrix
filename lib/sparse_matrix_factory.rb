# Compressed Sparse Row (CSR) sparse matrix factory
class SparseMatrixFactory

  def initialize(*args); end

  def self.rand_matrix(rows = 100, cols = rows,
                       scarcity = 0.4, range = (-1000..1000))
    raise NotImplementedError
  end
end
