require_relative 'sparse_matrix_factory'
require_relative 'tridiagonal_matrix_factory'

# Abstract factory for sparse matrices
class AbstractSparseMatrixFactory
  def self.build(rows, cols, type, block = Proc.new)
    factory = get_factory type
    factory.build rows, cols, block
  end

  def self.get_factory(type)
    case type
    when 'sparse'
      SparseMatrixFactory.new
    when 'tridiagonal'
      TriDiagonalMatrixFactory.new
    else
      raise ArgumentError, "Unknown matrix type #{type}"
    end
  end
end
