require 'test/unit'
require_relative '../lib/sparse_matrix'
require_relative 'common/test_helper_matrix_util'
require_relative '../lib/sparse_matrix_factory'
require_relative 'common/matrix_test_case'
require_relative 'common/matrix_identities_test_case'

class SparseMatrixTest < Test::Unit::TestCase
  include MatrixTestUtil
  include MatrixTestCase
  include MatrixIdentitiesTestCase

  TEST_ITER = 10
  MAX_ROWS = 100
  MAX_COLS = 100
  MIN_VAL = -10_000
  MAX_VAL = 10_000

  def setup
    @factory = SparseMatrixFactory.new
  end

  def assert_invariants(m)
    assert_base_invariants(m)

    # Implementation specific assertions
    row_vector = m.instance_variable_get(:@row_vector)
    data = m.instance_variable_get(:@data)
    col_vector = m.instance_variable_get(:@col_vector)

    assert_equal(m.nnz, row_vector[-1], "Row vector inconsistent with data")
    assert_equal(m.nnz, data.size, "Data vector inconsistent with data")
    assert_equal(m.nnz, col_vector.size, "Col vector inconsistent with data")

    assert_equal(row_vector.sort, row_vector, "Row vector must be in increasing order")
    (0...m.rows).each do |r|
      cols_in_row = col_vector[row_vector[r]...row_vector[r+1]]
      assert_equal(cols_in_row.sort, cols_in_row, "Col vector must be in increasing order for each row")
    end
  end

  # def test_cofactor
  #   m = @factory.random_square(size: 3)
  #
  #   # Preconditions
  #   begin
  #   end
  #
  #   cof = m.cofactor
  #
  #   # Postconditions
  #   begin
  #     assert_equal(m.adjugate, cof.transpose, "Cofactor matrix should be equal to the transpose of the adjugate")
  #   end
  #
  #   assert_invariants(m)
  # end
  #
  # def test_adjugate
  #   m = @factory.random_square
  #
  #   # Preconditions
  #   begin
  #     assert_true(m.square?, 'Cannot calculate adjoint of non-square matrix')
  #   end
  #
  #   adj = m.adjoint
  #
  #   # Postconditions
  #   begin
  #     cof = m.cofactor
  #     assert_equal(adj, cof.transpose, 'Adjoint not equal to transpose of cofactor matrix')
  #   end
  #
  #   assert_invariants(m)
  #   assert_invariants(adj)
  # end

  def test_at
    v = rand(MIN_VAL..MAX_VAL)
    m = @factory.random rows: 11, cols: 11, fill_factor: 5
    r, c = @factory.random_loc(m.rows, m.cols)
    m.put(r, c, v)
    puts r, c, v
    puts m
    print m.row_vector
    print m.col_vector
    print m.data

    # Preconditions
    begin
      assert_true(r >= 0 && r <= m.rows - 1, 'Invalid row: Out of matrix row range')
      assert_true(c >= 0 && c <= m.cols - 1, 'Invalid column: Out of matrix column range')
    end

    # Postconditions
    begin
      assert_equal(v, m.at(r, c), "Incorrect value at row:#{r}, col:#{c}. Expected: #{v}, Actual:#{m.at(r, c)}")
    end

    assert_invariants(m)
  end

  def test_rank
    m = @factory.random

    # Preconditions
    begin
    end

    r = m.rank

    # Postconditions
    begin
      if m.nil? || m.zero?
        assert_equal(0, r, 'Rank non-zero for zero matrix')
        return
      end

      assert_true(r > 0, 'Rank non-positive for non-nil matrix') unless m.nil? || m.zero?
      assert_true(r <= m.rows, 'Rank larger than number of rows')

      if m.square?
        assert_equal(sparse_to_matrix(m).rank, r, 'Rank not equal to Ruby::Matrix rank')
        assert_equal(r, m.transpose.rank, 'Rank not equal to rank of transpose.')
      end
    end

    assert_invariants(m)
  end
end
