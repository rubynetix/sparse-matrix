# Abstract factory for sparse matrices
class AbstractSparseMatrixFactory
  @factories = Hash.new
  @factories['sparse'] = SparseMatrixFactory
  @factories['triangular'] = TriangularMatrixFactory
  @factories['diagonal'] = DiagonalMatrixFactory

  def initialize(*args)
    raise(ArgumentError) unless args.length > 1

    type = args[0]
    if @factories.has_key? type
      @factories.fetch(type).new args[1..-1]
    else
      raise ArgumentError, "Unknown matrix type #{type}"
    end
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
