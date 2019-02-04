# Diagonal Matrix Factory
class DiagonalMatrixFactory < TriangularMatrixFactory
  def initialize(*args)
    raise(ArgumentError) unless args.length > 1
  end

  def self.rand_matrix(rows = 100, cols = rows,
                       scarcity = 0.4, range = (-1000..1000))
    raise NotImplementedError
  end
end

# Diagonal Matrix
class DiagonalMatrix < TriangularMatrix

end
