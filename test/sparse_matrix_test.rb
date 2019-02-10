require 'test/unit'
require_relative '../lib/sparse_matrix'
require_relative 'common/test_helper_matrix_util'
require_relative '../lib/sparse_matrix_factory'
require_relative 'common/matrix_test_case'

class SparseMatrixTest < Test::Unit::TestCase
  include MatrixTestUtil
  include MatrixTestCase

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

  def test_nnz
    n = rand(0..20)
    m = SparseMatrix.new(n, n)
    x = (0...m.cols).to_a.shuffle.take(n)
    y = (0...m.rows).to_a.shuffle.take(n)
    (0...n).each do |i|
      m.put(x[i], y[i], rand(1..1000))
    end
    # Preconditions
    begin
      assert_true(n >= 0, "Number of non-zero elements is invalid: #{n}")
    end

    # Postconditions
    begin
      assert_equal(n, m.nnz, "Number of non-zero elements in the matrix is incorrect. Expected: #{n}, Actual: #{m.nnz}")
    end

    assert_invariants(m)
  end

  def test_resize
    m = rand_sparse
    nr = rand(0..MAX_ROWS)
    nc = rand(0..MAX_COLS)
    r = m.rows
    c = m.cols
    nnzi = m.nnz

    # Preconditions
    begin
    end

    m.resize!(nr, nc)

    # Postconditions
    begin
      assert_equal(nr, m.rows, "Resize rows is incorrect. Expected: #{nr}, Actual: #{m.rows}")
      assert_equal(nc, m.cols, "Resize cols is incorrect. Expected: #{nc}, Actual: #{m.cols}")

      # Resize up
      if (nr >= r) && (nc >= c)
        assert_equal(nnzi, m.nnz, "Number of non-zero elements in resized matrix is incorrect. Expected: #{nnzi}, Actual: #{m.nnz}")
        return
      end

      # Resizing down
      assert_true(nnzi >= m.nnz, "Number of non-zero elements in resized matrix is incorrect. Expected: #{nnzi}, Actual: #{m.nnz}")
    end

    assert_invariants(m)
  end

  def test_resize_down
    # A more explicit case where we check that
    # a value was removed
    r = rand(2..MAX_ROWS)
    c = rand(2..MAX_COLS)
    dr = r - 1
    dc = c - 1
    m = SparseMatrix.new(r, c)
    m.put(r-1, c-1, 1)

    # Preconditions
    begin
      assert_equal(r, m.rows, "Number of rows is invalid. Expected: #{r}, Actual: #{m.rows}")
      assert_equal(c, m.cols, "Number of cols is invalid: Expected: #{c}, Actual: #{m.cols}")
      assert_true(dr <= m.rows, 'Resize down row count is larger than original matrix row count')
      assert_true(dc <= m.cols, 'Resize down column count is larger than original matrix column count')
    end

    m.resize!(dr, dc)

    # Postconditions
    begin
      assert_equal(dr, m.rows, "Resize rows is incorrect. Expected: #{dr}, Actual: #{m.rows}")
      assert_equal(dc, m.cols, "Resize cols is incorrect. Expected: #{dc}, Actual: #{m.cols}")
      assert_equal(0, m.nnz, 'Number of non-zero elements is invalid. The only non-zero element should have been pushed out during resize down')
    end

    assert_invariants(m)
  end

  def test_at
    v = rand(MIN_VAL..MAX_VAL)
    m = SparseMatrix.new(100, 100)
    r = rand(0..99)
    c = rand(0..99)

    m.put(r, c, v)

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

  def test_to_s
    test_ms = [
      SparseMatrix.new(0, 0),
      SparseMatrix.[]([10, 2, 3]),
      SparseMatrix.identity(3),
      SparseMatrix.[]([100, 0, 0, 0], [0, 1, 1, 0], [0, -1, 0, 0])
    ]

    exps = [
        "nil\n", # the null case
        "10 2 3\n", # vector case
        "1 0 0\n0 1 0\n0 0 1\n", # matrix case
        "100  0 0 0\n  0  1 1 0\n  0 -1 0 0\n" # Note the formatting. Values are left-padded to the longest
    # elements column-wise
    ]

    test_ms.zip(exps).each do |m, e|
      # Preconditions
      begin
      end

      s = m.to_s

      # Postconditions
      begin
        assert_equal(e, s, 'Incorrect to_s format')

        # More generically
        if m.nil?
          assert_equal(1, char_count("\n", s), 'Nil Matrix incorrect to_s format')
        else
          # number of \n == rows()
          assert_equal(m.rows, char_count("\n", s), "Matrix incorrect to_s format ")
          # all rows have the same length
          len = nil
          s.each_line("\n") do |l|
            len = l.size if len.nil?
            assert_equal(len, l.size, 'Matrix to_s format, incorrect row length')
          end
        end
      end

      assert_invariants(m)
    end
  end

  def test_add_matrix
    (0..TEST_ITER).each do
      r = rand(1..MAX_ROWS)
      c = rand(1..MAX_COLS)
      m1 = rand_sparse(rows: r, cols: c)
      m2 = rand_sparse(rows: r, cols: c)

      # Preconditions
      begin
        assert_equal(m1.rows, m2.rows, "Cannot add matrices of different dimensions.")
        assert_equal(m1.cols, m2.cols, "Cannot add matrices of different dimensions.")
      end

      m3 = m1 + m2

      # Postconditions
      begin
        assert_equal(m1.sum + m2.sum, m3.sum, "Matrix addition incorrect. Expected Sum:#{m1.sum + m2.sum}, Actual Sum:#{m3.sum}")

        if m1.traceable?
          assert_equal(m1.trace + m2.trace, m3.trace, "Matrix addition incorrect. Expected Trace:#{m1.trace + m2.trace}, Actual Trace:#{m3.trace}")
        end

        assert_equal(m1, m3 - m2, "Matrix addition error.")

        (0...m1.rows).each do |r2|
          (0...m1.cols).each do |c2|
            assert_equal(m1.at(r2, c2) + m2.at(r2, c2), m3.at(r2, c2), "Matrix addition error at row:#{r2}, col:#{c2}. Expected:#{m1.at(r2, c2) + m2.at(r2, c2)}, Actual:#{m3.at(r2, c2)}")
          end
        end
      end

      assert_invariants(m1)
      assert_invariants(m2)
      assert_invariants(m3)
    end
  end

  def test_scalar_plus
    m1 = rand_sparse
    num = rand(MIN_VAL..MAX_VAL)

    # Preconditions
    begin
    end

    m2 = m1 + num

    # Postconditions
    begin
      assert_equal(m1.sum + num * m1.rows * m1.cols, m2.sum, "Matrix scalar addition incorrect. Expected Sum:#{m1.sum + num * m1.nnz}, Actual Sum:#{m2.sum}")

      (0...m1.rows).each do |r|
        (0...m1.cols).each do |c|
          assert_equal(m1.at(r, c) + num, m2.at(r, c), "Incorrect scalar addition at row:#{r}, col:#{c}. Expected:#{m1.at(r, c) + num}, Actual:#{m2.at(r, c)}")
        end
      end
    end

    assert_invariants(m1)
    assert_invariants(m2)
  end

  def test_subtract_matrix
    (0..TEST_ITER).each do
      r = rand(1..MAX_ROWS)
      c = rand(1..MAX_COLS)
      m1 = rand_sparse(rows: r, cols: c)
      m2 = rand_sparse(rows: r, cols: c)

      # Preconditions
      begin
        assert_equal(m1.rows, m2.rows, "Cannot subtract matrices of different dimensions.")
        assert_equal(m1.cols, m2.cols, "Cannot subtract matrices of different dimensions.")
      end

      m3 = m1 - m2

      # Postconditions
      begin
        assert_equal(m1.sum - m2.sum, m3.sum, "Matrix subtraction incorrect. Expected Sum:#{m1.sum - m2.sum}, Actual Sum:#{m3.sum}")

        if m1.traceable?
          assert_equal(m1.trace - m2.trace, m3.trace, "Matrix subtraction incorrect. Expected Trace:#{m1.trace - m2.trace}, Actual Trace:#{m3.trace}")
        end

        assert_equal(m1, m3 + m2, 'Matrix subtraction error.')

        (0...m1.rows).each do |r2|
          (0...m1.cols).each do |c2|
            assert_equal(m1.at(r2, c2) - m2.at(r2, c2), m3.at(r2, c2), "Incorrect subtraction at row:#{r2}, col:#{c2}. Expected:#{m1.at(r2, c2) - m2.at(r2, c2)}, Actual:#{m3.at(r2, c2)}")
          end
        end
      end

      assert_invariants(m1)
      assert_invariants(m2)
      assert_invariants(m3)
    end
  end

  def test_scalar_subtract
    m1 = rand_sparse
    num = rand(MIN_VAL..MAX_VAL)

    # Preconditions
    begin
    end

    m2 = m1 - num

    # Postconditions
    begin
      assert_equal(m1.sum - num * m1.rows * m1.cols, m2.sum, "Matrix scalar subtraction incorrect. Expected Sum:#{m1.sum - num * m1.nnz}, Actual Sum:#{m2.sum}")

      (0...m1.rows).each do |r|
        (0...m1.cols).each do |c|
          assert_equal(m1.at(r, c) - num, m2.at(r, c), "Incorrect scalar subraction at row:#{r}, col:#{c}. Expected:#{m1.at(r, c) - num}, Actual:#{m2.at(r, c)}")
        end
      end
    end

    assert_invariants(m1)
    assert_invariants(m2)
  end

  def test_matrix_mult
    m1 = rand_sparse
    m2 = rand_sparse(rows: m1.cols)

    # Preconditions
    begin
      assert_equal(m1.cols, m2.rows)
    end

    m3 = m1 * m2

    # Postconditions
    begin
      assert_equal(m1.rows, m3.rows)
      assert_equal(m2.cols, m3.cols)
    end
  end

  def test_scalar_mult
    r = rand(0..MAX_ROWS)
    c = rand(1..MAX_COLS)
    m = rand_sparse(rows: r, cols: c)
    rand_range(1, 1000, 20).each do |mult|
      # Preconditions
      begin
      end

      new_m = m * mult

      # Postconditions
      begin
        (0...r).each do |i|
          (0...c).each do |j|
            assert_equal(m.at(i, j) * mult, new_m.at(i, j), "Incorrect scalar multiplication at row:#{i}, col:#{j}. Expected:#{m.at(i, j) * mult}, Actual:#{new_m.at(i, j)}")
          end
        end
      end

      assert_invariants(m)
    end
  end

  def test_put
    m = rand_sparse
    v = rand(MIN_VAL..MAX_VAL)
    r = rand(0...m.rows)
    c = rand(0...m.cols)

    # Preconditions
    begin
      assert_true(r >= 0 && r <= m.rows - 1, 'Invalid row: Out of matrix row range')
      assert_true(c >= 0 && c <= m.cols - 1, 'Invalid column: Out of matrix column range')
    end

    nnz_before = m.nnz
    v_before = m.at(r, c)
    m.put(r, c, v)

    # Postconditions
    begin
      # Check that the value is set
      assert_equal(v, m.at(r, c), "Invalid insertion, value not set. Expected:#{v}, Actual:#{m.at(r, c)}")

      if ((v != 0) && (v_before != 0)) || ((v == 0) && (v_before == 0))
        assert_equal(nnz_before, m.nnz, 'Invalid insertion, number of non-zero elements unexpectedly changed.')
      elsif (v != 0) && (v_before == 0)
        assert_equal(nnz_before + 1, m.nnz, "Invalid insertion, number of non-zero elements is incorrect after replacing zero value with non-zero. Expected:#{nnz_before + 1}, Actual:#{m.nnz}")
      else # v == 0 and v_before != 0
        assert_equal(nnz_before - 1, m.nnz, "Invalid insertion, number of non-zero elements is incorrect after replacing non-zero value with zero. Expected:#{nnz_before - 1}, Actual:#{m.nnz}")
      end
    end

    assert_invariants(m)
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
    m = rand_square_sparse

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
    m = rand_sparse
    m_same = m.clone
    m_diff = rand_sparse

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
    m = rand_sparse

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
    m = rand_square_sparse

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

  def test_inverse
    m = rand_square_sparse(size: rand(25...50))

    # Preconditions
    begin
      # "Cannot calculate inverse of singular matrix
      return if not m.invertible?
    end

    inv = m.inverse

    # Postconditions
    begin
      assert_equal(m * inv, SparseMatrix.identity(m.rows), 'Matrix times its inverse not equal identity')
    end

    assert_invariants(m)
  end

  def test_zero?
    ms = [
      rand_sparse,
      SparseMatrix.new(0),
      SparseMatrix.identity(rand(0..100)),
      SparseMatrix.zero(rand(0..MAX_ROWS), rand(0..MAX_COLS))
    ]

    ms.each do |m|
      # Preconditions
      begin
      end

      is_zero = m.zero?

      # Postconditions
      begin
        if m.nnz > 0
          assert_false(is_zero, 'Non-zero matrix recognized as zero')
        else
          assert_true(is_zero, 'Zero matrix not recognized as zero')
        end
      end

      assert_invariants(m)
    end
  end

  def tst_rank
    m = rand_sparse

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

  def test_orthogonal?
    m = rand_square_sparse

    # Preconditions
    begin
    end

    orth = m.orthogonal?

    # Post conditions
    begin
      assert_equal(m.transpose == m.inverse, orth, 'Conflict between orthogonal result and transpose/inverse equality')
    end

    assert_invariants(m)
  end

  def test_to_ruby_matrix
    m = rand_square_sparse

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
