# Exceptions needed for Sparse matrix functions
module MatrixExceptions
  class NonSquareException < RuntimeError; end
  class EmptyMatrixException < RuntimeError; end
  class NonTraceableException < RuntimeError; end
end
