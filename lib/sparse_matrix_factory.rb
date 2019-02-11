require_relative 'sparse_matrix'
require_relative 'matrix_factory'

class SparseMatrixFactory < MatrixFactory

  def initialize(*args); end

  def new(rows, cols, val = 0)
    SparseMatrix.create(rows, cols: cols, val: val)
  end

  def zero(rows, cols = rows)
    SparseMatrix.create(rows, cols: cols)
  end

  def identity(n)
    SparseMatrix.identity(n)
  end

  def from_array(rows)
    SparseMatrix.[](*rows)
  end

  private

  def random_loc(rows, cols)
    [rand(0..rows - 1), rand(0..cols - 1)]
  end

  def num_nz(rows, cols, fill_factor)
    (rows * cols * fill_factor / 100).floor
  end
end
