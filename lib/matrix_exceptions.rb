# Exceptions needed for Sparse matrix functions
module MatrixExceptions
  class DimensionMismatchException < RuntimeError; end
  class EmptyMatrixException < RuntimeError; end
end
