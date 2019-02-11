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

s1 = sparse_fact.new(3, 3)                                         # Create a 3x3 matrix filled with zeroes
s2 = sparse_fact.new(3, 3, 1)                                      # Create a 3x3 matrix filled with ones
s3 = sparse_fact.identity(3)                                       # Create a 3x3 identity matrix
s4 = sparse_fact.from_array([[7, 2, 1], [0, 3, -1], [-3, 4, -2]])  # Create a 3x3 matrix from arrays

t1 = tri_fact.new(3, 3)                                            # Create a 3x3 tridiagonal matrix filled with zeroes
t2 = tri_fact.new(3, 3, 1)                                         # Create a 3x3 tridiagonal matrix filled with ones
t3 = tri_fact.identity(3)                                          # Create a 3x3 tridiagonal, identity matrix
t4 = tri_fact.from_diags([[1, 2], [3, 4, 5], [6, 7]])              # Create a 3x3 tridiagonal matrix from specified diagonals

# Example operations:
#   - Note, the following list is not exhaustive --
#     see the class API for all supported operations.

# 1. Access
puts "\nAccessing element (method 1):   \n#{s2.at(1, 1)}"
puts "\nAccessing element (method 2):   \n#{s2[1, 1]}"
puts "\nSetting element (method 1):";   s2.put(1, 1, 3); puts s2
puts "\nSetting element (method 2):";   s2[1, 1] = 4; puts s2

# 2. Scalar operations
puts "\nScalar addition:                \n#{s1 + 2}"
puts "\nScalar subtraction:             \n#{s1 * 2}"
puts "\nScalar multiplication:          \n#{s1 - 2}"
puts "\nScalar exponentiation:          \n#{s1 ** 2}"

# 3. Common matrix Operations
puts "\nMatrix addition:                \n#{s1 + s4}"
puts "\nMatrix subtraction:             \n#{s1 - s4}"
puts "\nMatrix multiplication:          \n#{s1 * s4}"
puts "\nMatrix division:                \n#{s1 / s4}"
puts "\nMatrix comparison:              \n#{s1 == s4}"
puts "\nMatrix sum:                     \n#{s4.sum}"
puts "\nMatrix inverse:                 \n#{s4.inverse}"
puts "\nMatrix transpose:               \n#{s4.transpose}"
puts "\nMatrix trace:                   \n#{s4.trace}"
puts "\nMatrix determinant:             \n#{s4.det}"
puts "\nMatrix diagonal:                \n#{s4.diagonal}"
puts "\nMatrix tridiagonal:             \n#{s4.tridiagonal}"
puts "\nMatrix is symmetric?:           \n#{s4.symmetric?}"
puts "\nMatrix is positive?:            \n#{s4.positive?}"
puts "\nMatrix is identity matrix?:     \n#{s4.identity?}"
puts "\nMatrix is zero matrix?:         \n#{s4.zero?}"
puts "\nMatrix is lower triangular?:    \n#{s4.lower_triangular?}"
puts "\nMatrix is upper triangular?:    \n#{s4.upper_triangular?}"
puts "\nMatrix is lower Hessenberg?:    \n#{s4.lower_hessenberg?}"
puts "\nMatrix is upper Hessenberg?:    \n#{s4.upper_hessenberg?}"

# 4. Other helpful ways to manipulate your sparse matrix
puts "\nOperate on all elements:        \n#{s4.map{|val, row, col| val + 5}}"
puts "\nOperate on diagonal elements:   \n#{s4.map_diagonal{|val, row, col| val + 5}}"
puts "\nOperate on non-zero elements:   \n#{s4.map_nz{|row, col, val| val + 5}}"
