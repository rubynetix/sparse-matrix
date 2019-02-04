# Abstract factory for sparse matrices
class AbstractSparseMatrixFactory
  @@factories = Hash.new
  @@factories['sparse'] = SparseMatrixFactory
  @@factories['triangular'] = TriangularMatrixFactory
  @@factories['diagonal'] = DiagonalMatrixFactory
  @@factories['tridiagonal'] = TriDiagonalMatrixFactory

  def initialize(*args)
    raise(ArgumentError) unless args.length > 1

    type = args[0]
    if @@factories.has_key? type
      @@factories.fetch(type).new args[1..-1]
    else
      raise ArgumentError, "Unknown matrix type #{type}"
    end
  end

  def self.rand_matrix(type, rows = 100, cols = rows,
      scarcity = 0.4, range = (-1000..1000))
    if @@factories.has_key? type
      @@factories.fetch(type).rand_matrix rows, cols, scarcity, range
    else
      raise ArgumentError, "Unknown matrix type #{type}"
    end
  end
end
