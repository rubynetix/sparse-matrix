require_relative '../lib/tridiagonal_matrix_factory'
require_relative 'common/matrix_test_case'

class TridiagonalMatrixTest < Test::Unit::TestCase
  include MatrixTestCase

  def setup
    @factory = TriDiagonalMatrixFactory.new
  end

  def assert_invariants(m)
    assert_base_invariants(m)
  end
end
