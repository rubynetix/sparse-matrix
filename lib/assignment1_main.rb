# Group No. 6 Members:
#   - Fraser Bulbuc
#   - James Hryniw
#   - Jordan Lane
#   - Ryan Furrer
#   - Tim Tran

require_relative 'sparse_matrix_factory'
require_relative 'tridiagonal_matrix_factory'

# Creation:
#   1. Instantiate a matrix factory
#   2. Create a matrix using the factory
sparse_fact = SparseMatrixFactory.new
tri_fact = TriDiagonalMatrixFactory.new

s1 = sparse_fact.new(3, 3)                                # Create a 3x3 matrix filled with zeroes
s2 = sparse_fact.new(3, 3, 1)                             # Create a 3x3 matrix filled with ones
s3 = sparse_fact.identity(3)                                 # Create a 3x3 identity matrix
s4 = sparse_fact.from_array([[1, 2, 3], [4, 5, 6], [7, 8, 9]]) # Create a 3x3 matrix from arrays

t1 = tri_fact.new(3, 3)                                   # Create a 3x3 tridiagonal matrix filled with zeroes
t2 = tri_fact.new(3, 3, 1)                                # Create a 3x3 tridiagonal matrix filled with ones
t3 = tri_fact.identity(3)                                    # Create a 3x3 tridiagonal, identity matrix
t4 = tri_fact.from_diags([[1, 2], [3, 4, 5], [6, 7]])          # Create a 3x3 tridiagonal matrix from specified diagonals
