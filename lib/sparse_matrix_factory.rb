# Compressed Sparse Row (CSR) sparse matrix
class SparseMatrixFactory

  def initialize(*args)

  end

  def rows
    raise "Not implemented"
  end

  def cols
    raise "Not implemented"
  end

  def nnz
    raise "Not implemented"
  end

  def resize(rows, cols)
    raise "Not implemented"
  end

  def set_zero
    raise "Not implemented"
  end

  def set_identity
    raise "Not implemented"
  end

  def at(row, col)
    raise "Not implemented"
  end
end
