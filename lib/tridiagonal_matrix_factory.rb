require_relative 'tridiagonal_matrix'

class TriDiagonalMatrixFactory
  def initialize(*args); end

  def build(rows, cols, block = Proc.new)
    TriDiagonalMatrix(rows, cols)
  end
end
