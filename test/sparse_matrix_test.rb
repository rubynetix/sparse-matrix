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

  # Helper function for test_diagonal?
  def nnz_off_diagonal?(m)
    (0..m.rows - 1).each do |i|
      (0..m.cols - 1).each do |j|
        next unless i != j
        return true if m.at(i, j) != 0
      end
    end
    false
  end

  def test_diagonal?
    m = @factory.random_square

    # Preconditions
    begin
    end

    is_d = m.diagonal?

    # Postconditions
    begin
      if is_d
        assert_true(m.symmetric?, 'Diagonal test is incorrect. Result conflicts with symmetric test')
        assert_true(m.square?, 'Diagonal test is incorrect. Matrix is not square')

        # For all i,j where i != j -> at(i,j) == 0
        iterate_matrix(m) do |i, j, v|
          assert_equal(0, v, "Invalid non-zero value in diagonal matrix at: row:#{i}, col:#{j}") unless i == j
        end
      else
        # For some i,j where i != j -> at(i,j) != 0
        assert_true(nnz_off_diagonal?(m), 'Invalid non-diagonal matrix. All values off the main diagonal are zero')
      end
    end

    assert_invariants(m)
  end

  def test_equals
    m = @factory.random
    m_same = m.clone
    m_diff = @factory.random

    # Preconditions
    begin
      assert_true(m_same.rows >= 0, 'Invalid row count of clone comparison matrix. Row count outside of valid range')
      assert_true(m_same.cols >= 0, 'Invalid column count of clone comparison matrix. Column count outside of valid range')
      assert_true(m_diff.rows >= 0, 'Invalid row count of different comparison matrix. Row count outside of valid range')
      assert_true(m_diff.cols >= 0, 'Invalid column count of different comparison matrix. Column count outside of valid range')
    end

    # Postconditions
    begin
      assert_equal(m, m_same, 'Equivalent matrices declared different')
      assert_not_equal(m, m_diff, 'Different matrices declared equivalent')
    end

    assert_invariants(m)
    assert_invariants(m_same)
    assert_invariants(m_diff)
  end

  def tst_cofactor
    m = @factory.random

    # Preconditions
    begin
    end

    cof_row = rand(0..m.rows)
    cof_col = rand(0..m.cols)

    cof = m.cofactor(cof_row, cof_col)

    # Postconditions
    begin
      if m.cols == 1 || m.rows == 1
        assert_true(cof.null?, 'Co-factor of vector non-nil')
      else
        assert_equal(cof.cols, m.cols - 1)
        assert_equal(cof.rows, m.rows - 1)

        # TODO: Check the actual values of the cofactor matrix
      end
    end

    assert_invariants(m)
  end

  def tst_adjoint
    m = @factory.random_square

    # Preconditions
    begin
      assert_true(m.square?, 'Cannot calculate adjoint of non-square matrix')
    end

    adj = m.adjoint

    # Postconditions
    begin
      cof = m.cofactor
      assert_equal(adj, cof.transpose, 'Adjoint not equal to transpose of cofactor matrix')
    end

    assert_invariants(m)
    assert_invariants(adj)
  end

  def tst_rank
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

  def test_to_ruby_matrix
    m = @factory.random_square

    # Preconditions
    begin
    end

    ruby_m = m.to_ruby_matrix

    # Postcondition
    begin
      (0...m.rows).each do |r|
        (0...m.cols).each do |c|
          assert_equal(m.at(r, c), ruby_m[r,c], "Ruby matrix value is incorrect at row:#{r} col:#{c}. Value: #{ruby_m[r,c]}")
        end
      end
    end
  end
end
