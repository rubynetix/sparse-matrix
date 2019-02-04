# Compressed Sparse Row (CSR) Matrix Factory
#
#     This can instantiate matrices in several ways:
#         SparseMatrixFactory.new(M)
#             with a dense matrix or rank-2 ndarray M
#         SparseMatrixFactory.new(S)
#             with another sparse matrix S (equivalent to S.tocsr())
#         SparseMatrixFactory.new(rows, cols)
#             to construct an empty matrix with shape (rows, cols)
#         SparseMatrixFactory.new((data, indices, indptr), [shape=(rows, cols)])
#             is the standard CSR representation where the column indices for
#             row i are stored in +indices[indptr[i]:indptr[i+1]]+ and their
#             corresponding values are stored in +data[indptr[i]:indptr[i+1]]+.
#             If the shape parameter is not supplied, the matrix dimensions
#             are inferred from the index arrays.
#
#     Attributes
#     ----------
#     rows: int
#         Number of rows
#     cols: int
#         Number of columns
#     nnz: int
#         Number of nonzero elements
#     data
#         CSR format data array of the matrix
#     indices
#         CSR format index array of the matrix
#     indptr
#         CSR format index pointer array of the matrix
class SparseMatrixFactory

  def initialize(*args); end

  def self.rand_matrix(rows = 100, cols = rows,
                       scarcity = 0.4, range = (-1000..1000))
    raise NotImplementedError
  end
end
