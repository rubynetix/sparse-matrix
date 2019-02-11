require 'test/unit'
require_relative '../../lib/sparse_matrix'
require_relative '../../lib/tridiagonal_matrix'
require_relative 'test_helper_matrix_util'

module MatrixTestCase
  include MatrixTestUtil

  TEST_ITER = 10
  MAX_ROWS = 100
  MAX_COLS = 100
  MIN_VAL = -100
  MAX_VAL = 100

  def assert_base_invariants(m)
    assert_true(m.rows >= 0)
    assert_true(m.cols >= 0)
    if m.cols > 0
      assert_true(m.rows > 0, 'Invariant assertion. Invalid row count')
    end
    if m.rows > 0
      assert_true(m.cols > 0, 'Invalid assertion. Invalid column count')
    end
    if m.rows == 0
      assert_true(m.cols == 0, 'Invariant assertion. Invalid row count')
    end
    if m.cols == 0
      assert_true(m.rows == 0, 'Invalid assertion. Invalid column count')
    end
  end

  def test_identity
    rand_range(1, MAX_ROWS, 5).each do |size|
      # Preconditions
      begin
        assert_true(size > 0, 'Identity matrix is nil')
      end

      m = @factory.identity(size)

      # Postconditions
      begin
        assert_true(m.square?, 'Identity matrix is not square')
        assert_true(m.diagonal?, 'Identity matrix is not diagonal')
        assert_true(m.symmetric?, 'Identity mastrix is not symmetric')
        assert_equal(size, m.sum, 'Identity matrix sum is not equivalent to size')
        (0..size - 1).each do |i|
          assert_equal(1, m.at(i, i), "Value for identity matrix not 1 at row:#{i}, col:#{i}")
        end
      end

      assert_invariants(m)
    end
  end

  def test_nnz
    n = rand(0..10)
    m = @factory.zero(MAX_ROWS)

    ins = 0
    while ins < n
      x = rand(0...m.rows)
      y = rand(0...m.cols)
      succ = m.put(x, y, rand(MAX_VAL..MAX_VAL))
      ins += 1 if succ
    end

    # Preconditions - N/A
    begin
    end

    # Postconditions
    begin
      assert_equal(n, m.nnz, "Number of non-zero elements in the matrix is incorrect. Expected: #{n}, Actual: #{m.nnz}")
    end

    assert_invariants(m)
  end

  def test_rows
    r = rand(2..MAX_ROWS)
    c = rand(2..MAX_COLS)
    m = @factory.new(r, c)

    # Preconditions
    begin
      assert_true(r >= 0, "Number of rows is invalid: #{r}")
    end

    # Postconditions
    begin
      assert_equal(r, m.rows, "Number of matrix rows is incorrect. Expected: #{r}, Actual: #{m.rows}")
    end

    assert_invariants(m)
  end

  def test_cols
    n = rand(1..MAX_ROWS)
    m = @factory.random_square(size: n)

    # Preconditions
    begin
      assert_true(n >= 0, "Number of cols is invalid: #{n}")
    end

    # Postconditions
    begin
      assert_equal(n, m.cols, "Number of matrix columns is incorrect. Expected: #{n}, Actual: #{m.cols}")
    end

    assert_invariants(m)
  end

  def test_det
    m = @factory.random_square

    # Preconditions
    begin
      assert_true(m.square?, 'Matrix for determinant test is not square')
    end

    d = m.det

    # Postconditions
    begin
      assert_equal(d, m.to_ruby_matrix.det, "Determinant is incorrect. Expected: #{(m).to_ruby_matrix.det}, Actual: #{d}")
      assert_equal(d, m.t.det, "Determinant is incorrect. Expected: #{m.t.det}, Actual: #{d}")
    end

    assert_invariants(m)
  end

  def test_resize
    m = @factory.random
    n = rand(0..MAX_ROWS)
    r = m.rows
    c = m.cols
    nnzi = m.nnz

    # Preconditions
    begin
    end

    m.resize!(n, n)

    # Postconditions
    begin
      assert_equal(n, m.rows, "Resize rows is incorrect. Expected: #{n}, Actual: #{m.rows}")
      assert_equal(n, m.cols, "Resize cols is incorrect. Expected: #{n}, Actual: #{m.cols}")

      # Resize up
      if (n >= r) && (n >= c)
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
    n = rand(2..MAX_ROWS)
    dn = n - 1
    m = @factory.zero(n)
    m.put(n - 1, n - 1, 1)

    # Preconditions
    begin
      assert_equal(n, m.rows, "Number of rows is invalid. Expected: #{n}, Actual: #{m.rows}")
      assert_equal(n, m.cols, "Number of cols is invalid: Expected: #{n}, Actual: #{m.cols}")
      assert_true(dn <= m.rows, 'Resize down row count is larger than original matrix row count')
      assert_true(dn <= m.cols, 'Resize down column count is larger than original matrix column count')
    end

    m.resize!(dn, dn)

    # Postconditions
    begin
      assert_equal(dn, m.rows, "Resize rows is incorrect. Expected: #{dn}, Actual: #{m.rows}")
      assert_equal(dn, m.cols, "Resize cols is incorrect. Expected: #{dn}, Actual: #{m.cols}")
      assert_equal(0, m.nnz, 'Number of non-zero elements is invalid. The only non-zero element should have been pushed out during resize down')
    end

    assert_invariants(m)
  end

  def test_set_zero
    m = @factory.random

    # Preconditions
    begin
    end

    m.set_zero

    # Postconditions
    begin
      (0...m.rows).each do |r|
        (0...m.cols).each do |c|
          assert_equal(0, m.at(r, c), "Matrix is not zero at row:#{r} col:#{c}. Value: #{m.at(r, c)}")
        end
      end
    end

    assert_invariants(m)
  end

  def test_set_identity
    (0..TEST_ITER).each do
      m = @factory.random_square

      # Preconditions
      begin
        assert_true(m.square?, "Identity matrix must be square.")
      end

      m.set_identity

      # Postconditions
      begin
        (0...m.rows).each do |r|
          (0...m.cols).each do |c|
            if r == c
              assert_equal(1, m.at(r, c), "Identity matrix contains element other than 1 on diagonal.")
            else
              assert_equal(0, m.at(r, c), "Identity matrix contains non-zero element off diagonal.")
            end
          end
        end
      end

      assert_invariants(m)
    end
  end

  def test_at
    v = rand(MIN_VAL..MAX_VAL)
    m = @factory.random
    r = c = nil

    loop do
      r = rand(0...m.rows)
      c = rand(0...m.cols)
      succ = m.put(r, c, v)
      break unless !succ
    end

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

  def test_clone
    m1 = rand_sparse

    # Preconditions
    begin
    end

    m2 = m1.clone
    r = rand(0...m1.rows)
    c = rand(0...m1.cols)

    # We want to assert that we are working on different copies
    m2.put(r, c, m2.at(r, c) + 1)

    # Postconditions
    begin
      assert_not_equal(m1.object_id, m2.object_id, "Object ids are equal after clone")
      assert_equal(m1.sum + 1, m2.sum, "Clone did not create deep copy")
    end

    assert_invariants(m1)
    assert_invariants(m2)
  end

  # # TODO: Only include in SparseMatrix tests
  # def test_to_s
  #   test_ms = [
  #       SparseMatrix.new(0, 0),
  #       SparseMatrix.[]([10, 2, 3]),
  #       SparseMatrix.identity(3),
  #       SparseMatrix.[]([100, 0, 0, 0], [0, 1, 1, 0], [0, -1, 0, 0])
  #   ]
  #
  #   exps = [
  #       "nil\n", # the null case
  #       "10 2 3\n", # vector case
  #       "1 0 0\n0 1 0\n0 0 1\n", # matrix case
  #       "100  0 0 0\n  0  1 1 0\n  0 -1 0 0\n" # Note the formatting. Values are left-padded to the longest
  #   # elements column-wise
  #   ]
  #
  #   test_ms.zip(exps).each do |m, e|
  #     # Preconditions
  #     begin
  #     end
  #
  #     s = m.to_s
  #
  #     # Postconditions
  #     begin
  #       assert_equal(e, s, 'Incorrect to_s format')
  #
  #       # More generically
  #       if m.nil?
  #         assert_equal(1, char_count("\n", s), 'Nil Matrix incorrect to_s format')
  #       else
  #         # number of \n == rows()
  #         assert_equal(m.rows, char_count("\n", s), "Matrix incorrect to_s format ")
  #         # all rows have the same length
  #         len = nil
  #         s.each_line("\n") do |l|
  #           len = l.size if len.nil?
  #           assert_equal(len, l.size, 'Matrix to_s format, incorrect row length')
  #         end
  #       end
  #     end
  #
  #     assert_invariants(m)
  #   end
  # end

  def test_sum
    m = @factory.random

    # Preconditions
    begin
    end

    sum = m.sum

    # Postconditions
    begin
      expected = 0
      (0..m.rows - 1).each do |r|
        (0..m.cols - 1).each do |c|
          expected += m.at(r, c)
        end
      end

      assert_equal(expected, sum, "Incorrect matrix sum. Expected:#{expected}, Actual: #{sum}")
    end

    assert_invariants(m)
  end

  # def test_add_matrix
  #   (0..TEST_ITER).each do
  #     r = rand(1..MAX_ROWS)
  #     c = rand(1..MAX_COLS)
  #     m1 = @factory.random(rows: r, cols: c)
  #     m2 = @factory.random(rows: r, cols: c)
  #
  #     # Preconditions
  #     begin
  #       assert_equal(m1.rows, m2.rows, "Cannot add matrices of different dimensions.")
  #       assert_equal(m1.cols, m2.cols, "Cannot add matrices of different dimensions.")
  #     end
  #
  #     m3 = m1 + m2
  #
  #     # Postconditions
  #     begin
  #       assert_equal(m1.sum + m2.sum, m3.sum, "Matrix addition incorrect. Expected Sum:#{m1.sum + m2.sum}, Actual Sum:#{m3.sum}")
  #
  #       if m1.traceable?
  #         assert_equal(m1.trace + m2.trace, m3.trace, "Matrix addition incorrect. Expected Trace:#{m1.trace + m2.trace}, Actual Trace:#{m3.trace}")
  #       end
  #
  #       assert_equal(m1, m3 - m2, "Matrix addition error.")
  #
  #       (0...m1.rows).each do |r2|
  #         (0...m1.cols).each do |c2|
  #           assert_equal(m1.at(r2, c2) + m2.at(r2, c2), m3.at(r2, c2), "Matrix addition error at row:#{r2}, col:#{c2}. Expected:#{m1.at(r2, c2) + m2.at(r2, c2)}, Actual:#{m3.at(r2, c2)}")
  #         end
  #       end
  #     end
  #
  #     assert_invariants(m1)
  #     assert_invariants(m2)
  #     assert_invariants(m3)
  #   end
  # end

  def test_scalar_plus
    m1 = @factory.random(rows: 5, cols: 5, range: (0..9))
    num = 10

    # Preconditions
    begin
    end

    m2 = m1 + num

    # Postconditions
    begin

      assert_equal(m1.sum + num * m1.rows * m1.cols, m2.sum, "Matrix scalar addition incorrect. Expected Sum:#{m1.sum + num * m1.nnz}, Actual Sum:#{m2.sum}") if m1.instance_of?(SparseMatrix)
      assert_equal(m1.sum + num * ((3 * m1.rows) - 2), m2.sum, "Matrix scalar addition incorrect. Expected Sum:#{m1.sum + num * ((3 * m1.rows) - 2)}, Actual Sum:#{m2.sum}") if m1.instance_of?(TriDiagonalMatrix)

      (0...m1.rows).each do |r|
        (0...m1.cols).each do |c|
          if m1.instance_of?(SparseMatrix)
            assert_equal(m1.at(r, c) + num, m2.at(r, c), "Incorrect scalar addition at row:#{r}, col:#{c}. Expected:#{m1.at(r, c) + num}, Actual:#{m2.at(r, c)}")
          elsif m1.instance_of?(TriDiagonalMatrix)
            assert_equal(m1.at(r, c) + num, m2.at(r, c), "Incorrect scalar addition at row:#{r}, col:#{c}. Expected:#{m1.at(r, c) + num}, Actual:#{m2.at(r, c)}") if m2.on_band?(r, c)
          end
        end
      end
    end

    assert_invariants(m1)
    assert_invariants(m2)
  end

  # def test_subtract_matrix
  #   (0..TEST_ITER).each do
  #     r = rand(1..MAX_ROWS)
  #     c = rand(1..MAX_COLS)
  #     m1 = @factory.random(rows: r, cols: c)
  #     m2 = @factory.random(rows: r, cols: c)
  #
  #     # Preconditions
  #     begin
  #       assert_equal(m1.rows, m2.rows, "Cannot subtract matrices of different dimensions.")
  #       assert_equal(m1.cols, m2.cols, "Cannot subtract matrices of different dimensions.")
  #     end
  #
  #     m3 = m1 - m2
  #
  #     # Postconditions
  #     begin
  #       assert_equal(m1.sum - m2.sum, m3.sum, "Matrix subtraction incorrect. Expected Sum:#{m1.sum - m2.sum}, Actual Sum:#{m3.sum}")
  #
  #       if m1.traceable?
  #         assert_equal(m1.trace - m2.trace, m3.trace, "Matrix subtraction incorrect. Expected Trace:#{m1.trace - m2.trace}, Actual Trace:#{m3.trace}")
  #       end
  #
  #       assert_equal(m1, m3 + m2, 'Matrix subtraction error.')
  #
  #       (0...m1.rows).each do |r2|
  #         (0...m1.cols).each do |c2|
  #           assert_equal(m1.at(r2, c2) - m2.at(r2, c2), m3.at(r2, c2), "Incorrect subtraction at row:#{r2}, col:#{c2}. Expected:#{m1.at(r2, c2) - m2.at(r2, c2)}, Actual:#{m3.at(r2, c2)}")
  #         end
  #       end
  #     end
  #
  #     assert_invariants(m1)
  #     assert_invariants(m2)
  #     assert_invariants(m3)
  #   end
  # end
  #
  # def test_scalar_subtract
  #   m1 = @factory.random
  #   num = rand(MIN_VAL..MAX_VAL)
  #
  #   # Preconditions
  #   begin
  #   end
  #
  #   m2 = m1 - num
  #
  #   # Postconditions
  #   begin
  #     assert_equal(m1.sum - num * m1.rows * m1.cols, m2.sum, "Matrix scalar subtraction incorrect. Expected Sum:#{m1.sum - num * m1.nnz}, Actual Sum:#{m2.sum}")
  #
  #     (0...m1.rows).each do |r|
  #       (0...m1.cols).each do |c|
  #         assert_equal(m1.at(r, c) - num, m2.at(r, c), "Incorrect scalar subraction at row:#{r}, col:#{c}. Expected:#{m1.at(r, c) - num}, Actual:#{m2.at(r, c)}")
  #       end
  #     end
  #   end
  #
  #   assert_invariants(m1)
  #   assert_invariants(m2)
  # end
  #
  # def test_matrix_mult
  #   m1 = @factory.random
  #   m2 = @factory.random(rows: m1.cols)
  #
  #   # Preconditions
  #   begin
  #     assert_equal(m1.cols, m2.rows)
  #   end
  #
  #   m3 = m1 * m2
  #
  #   # Postconditions
  #   begin
  #     assert_equal(m1.rows, m3.rows)
  #     assert_equal(m2.cols, m3.cols)
  #   end
  # end
  #
  # def test_scalar_mult
  #   r = rand(0..MAX_ROWS)
  #   c = rand(1..MAX_COLS)
  #   m = @factory.random(rows: r, cols: c)
  #   rand_range(1, 1000, 20).each do |mult|
  #     # Preconditions
  #     begin
  #     end
  #
  #     new_m = m * mult
  #
  #     # Postconditions
  #     begin
  #       (0...r).each do |i|
  #         (0...c).each do |j|
  #           assert_equal(m.at(i, j) * mult, new_m.at(i, j), "Incorrect scalar multiplication at row:#{i}, col:#{j}. Expected:#{m.at(i, j) * mult}, Actual:#{new_m.at(i, j)}")
  #         end
  #       end
  #     end
  #
  #     assert_invariants(m)
  #   end
  # end

  def test_exponentiation
    exp = 3
    m = @factory.random_square
    # No Preconditions

    new_m = m**exp

    # Postconditions
    begin
      expected = m
      (2..exp).each do |_i|
        expected *= m
      end
      assert_equal(expected, new_m, "Incorrect exponentiation. Expected:#{expected}, Actual:#{new_m}")
    end

    assert_invariants(m)
  end

  def test_put
    m = @factory.random_square
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
    succ = m.put(r, c, v)

    # Postconditions
    begin
      # Check that the value is set
      if succ
        assert_equal(v, m.at(r, c), "Invalid insertion, value not set. Expected:#{v}, Actual:#{m.at(r, c)}")

        if ((v != 0) && (v_before != 0)) || ((v == 0) && (v_before == 0))
          assert_equal(nnz_before, m.nnz, 'Invalid insertion, number of non-zero elements unexpectedly changed.')
        elsif (v != 0) && (v_before == 0)
          assert_equal(nnz_before + 1, m.nnz, "Invalid insertion, number of non-zero elements is incorrect after replacing zero value with non-zero. Expected:#{nnz_before + 1}, Actual:#{m.nnz}")
        else # v == 0 and v_before != 0
          assert_equal(nnz_before - 1, m.nnz, "Invalid insertion, number of non-zero elements is incorrect after replacing non-zero value with zero. Expected:#{nnz_before - 1}, Actual:#{m.nnz}")
        end
      else
        assert_equal(v_before, m.at(r, c), "Invalid insertion, value unexpectedly changed. Expected:#{v}, Actual:#{m.at(r, c)}")
        assert_equal(nnz_before, m.nnz)
      end
    end

    assert_invariants(m)
  end

  # # Helper function for test_diagonal?
  # def nnz_off_diagonal?(m)
  #   (0..m.rows - 1).each do |i|
  #     (0..m.cols - 1).each do |j|
  #       next unless i != j
  #       return true if m.at(i, j) != 0
  #     end
  #   end
  #   false
  # end
  #
  # def test_diagonal?
  #   m = @factory.random_square
  #
  #   # Preconditions
  #   begin
  #   end
  #
  #   is_d = m.diagonal?
  #
  #   # Postconditions
  #   begin
  #     if is_d
  #       assert_true(m.symmetric?, 'Diagonal test is incorrect. Result conflicts with symmetric test')
  #       assert_true(m.square?, 'Diagonal test is incorrect. Matrix is not square')
  #
  #       # For all i,j where i != j -> at(i,j) == 0
  #       iterate_matrix(m) do |i, j, v|
  #         assert_equal(0, v, "Invalid non-zero value in diagonal matrix at: row:#{i}, col:#{j}") unless i == j
  #       end
  #     else
  #       # For some i,j where i != j -> at(i,j) != 0
  #       assert_true(nnz_off_diagonal?(m), 'Invalid non-diagonal matrix. All values off the main diagonal are zero')
  #     end
  #   end
  #
  #   assert_invariants(m)
  # end

  def test_diagonal
    m = @factory.random_square

    # Preconditions
    begin
      assert_true(m.square?, 'Diagonal not defined for non-square matrix')
    end

    md = m.diagonal

    # Postconditions
    begin
      # All elements on the diagonal are equivalent to the original matrix
      (0..m.rows - 1).each do |i|
        assert_equal(m.at(i, i), md[i], 'Diagonal elements not-equal to original diagonal')
      end
    end

    assert_invariants(m)
  end

  def test_lower_triangular?(_nonsquare)
    r = 0
    c = 0
    while r != c
      r = rand(0..MAX_ROWS)
      c = rand(0..MAX_COLS)
      m = @factory.random(rows: r, cols: c)
    end

    # Preconditions
    begin
    end

    # Postconditions
    begin
      assert_equal(sparse_to_matrix(m).lower_triangular?, m.lower_triangular?, "Non-square Matrix lower triangular check is incorrect. Expected:#{sparse_to_matrix(m).lower_triangular?}, Actual:#{m.lower_triangular?}")
    end

    assert_invariants(m)
  end

  def test_lower_triangular_square
    i = 0
    while i < 20
      rc = rand(0..MAX_ROWS)
      m_tri = lower_triangular_matrix(rc, 0, 1000)
      m_random = @factory.random_square

      # Preconditions
      begin
      end

      # Postconditions
      begin
        assert_equal(sparse_to_matrix(m_tri).lower_triangular?, m_tri.lower_triangular?, "Lower triangular check is incorrect for Square Lower Triangular Matrix. Expected:#{sparse_to_matrix(m_tri).lower_triangular?}, Actual:#{m_tri.lower_triangular?}")
        assert_equal(sparse_to_matrix(m_random).lower_triangular?, m_random.lower_triangular?, "Lower triangular check is incorrect for Random Square Matrix. Expected:#{sparse_to_matrix(m_random).lower_triangular?}, Actual:#{m_random.lower_triangular?}")
      end

      assert_invariants(m_tri)
      assert_invariants(m_random)

      i += 1
    end
  end

  def test_upper_triangular?(_nonsquare)
    r = 0
    c = 0
    while r != c
      r = rand(0..MAX_ROWS)
      c = rand(0..MAX_COLS)
      m = @factory.random(rows: r, cols: c)
    end

    # Preconditions
    begin
    end

    # Postconditions
    begin
      assert_equal(sparse_to_matrix(m).upper_triangular?, m.upper_triangular?, "Non-square Matrix upper triangular check is incorrect. Expected:#{sparse_to_matrix(m).upper_triangular?}, Actual:#{m.upper_triangular?}")
    end

    assert_invariants(m)
  end

  def test_upper_triangular_square
    i = 0
    while i < 20
      rc = rand(0..MAX_ROWS)
      m_tri = upper_triangular_matrix(rc, 0, 1000)
      m_random = @factory.random_square

      # Preconditions
      begin
      end

      # Postconditions
      begin
        assert_equal(sparse_to_matrix(m_tri).upper_triangular?, m_tri.upper_triangular?, "Upper triangular check is incorrect for Square Upper Triangular Matrix. Expected:#{sparse_to_matrix(m_tri).upper_triangular?}, Actual:#{m_tri.upper_triangular?}")
        assert_equal(sparse_to_matrix(m_random).upper_triangular?, m_random.upper_triangular?, "Upper triangular check is incorrect for Random Square Matrix. Expected:#{sparse_to_matrix(m_random).upper_triangular?}, Actual:#{m_random.upper_triangular?}")
      end

      assert_invariants(m_tri)
      assert_invariants(m_random)

      i += 1
    end
  end

  def check_lower_hessenberg(m)
    # algorithm to test if matrix m is lower_hessenberg
    # Returns true if matrix m is lower hessenberg. False otherwise.
    if !m.square?
      assert_false(m.lower_hessenberg?, "Lower Hessenberg check for Non-square Matrix is incorrect. Expected: False, Actual:#{m.lower_hessenberg?}")
    else
      (0...m.rows).each do |y|
        (0...m.cols).each do |x|
          if (x > y + 1 ) && (m.at(y, x) != 0)
            return false
          end
        end
      end
      true
    end
  end

  def test_lower_hessenberg?(_nonsquare)
    # tests lower_hessenberg? with a nonsquare matrix
    r = 0
    c = 0
    while r != c
      r = rand(0..10_000)
      c = rand(0..10_000)
      m = @factory.random(rows: r, cols: c)
    end

    # Preconditions
    begin
    end

    # Postconditions
    begin
      check_lower_hessenberg(m)
    end

    assert_invariants(m)
  end

  def test_lower_hessenberg_square
    # tests lower_hessenberg with a square matrix
    i = 0
    while i < 20
      rc = rand(0..MAX_ROWS)
      m_hess = lower_hessenberg_matrix(rc, 0, 1000)
      m_random = @factory.random_square

      # Preconditions
      begin
      end

      # Postconditions
      begin
        assert_true(m_hess.lower_hessenberg?, "lower_hessenberg? returned false for a lower hessenberg matrix")
        assert_true(!m_random.lower_hessenberg?, "lower_hessenberg? returned true for a non-lower hessenberg matrix") if !check_lower_hessenberg(m_random)
      end

      assert_invariants(m_hess)
      assert_invariants(m_random)

      i += 1
    end
  end

  def check_upper_hessenberg(m)
    # algorithm to test matrix m is upper_hessenberg
    # Returns true if matrix m is upper hessenberg. False otherwise.
    if !m.square?
      assert(!m.upper_hessenberg?, 'Non-square matrix cannot be upper hessenberg')
    else
      (0...m.rows).each do |y|
        (0...m.cols).each do |x|
          if (y > x + 1) && (m.at(y, x) != 0)
            return false
          end
        end
      end
      true
    end
  end

  def test_upper_hessenberg?(_nonsquare)
    # tests upper_hessenberg? with a nonsquare matrix
    r = 0
    c = 0
    while r != c
      r = rand(0..MAX_ROWS)
      c = rand(0..MAX_COLS)
      m = @factory.random(rows: r, cols: c)
    end

    # Preconditions
    begin
    end

    # Postconditions
    begin
      check_upper_hessenberg(m)
    end

    assert_invariants(m)
  end

  def test_upper_hessenberg_square
    # tests upper_hessenberg with a square matrix
    i = 0
    while i < 10
      rc = rand(0..MAX_ROWS)
      m_hess = upper_hessenberg_matrix(rc, 0, 1000)
      m_random = @factory.random_square

      # Preconditions
      begin
      end

      # Postconditions
      begin
        assert_true(m_hess.upper_hessenberg?, "upper_hessenberg? returned false for a upper hessenberg matrix")
        assert_true(!m_random.upper_hessenberg?, "upper_hessenberg? returned true for a non upper hessenberg matrix") if !check_upper_hessenberg(m_random)
      end

      assert_invariants(m_hess)
      assert_invariants(m_random)

      i += 1
    end
  end

  # def test_equals
  #   m = @factory.random
  #   m_same = m.clone
  #   m_diff = @factory.random
  #
  #   # Preconditions
  #   begin
  #     assert_true(m_same.rows >= 0, 'Invalid row count of clone comparison matrix. Row count outside of valid range')
  #     assert_true(m_same.cols >= 0, 'Invalid column count of clone comparison matrix. Column count outside of valid range')
  #     assert_true(m_diff.rows >= 0, 'Invalid row count of different comparison matrix. Row count outside of valid range')
  #     assert_true(m_diff.cols >= 0, 'Invalid column count of different comparison matrix. Column count outside of valid range')
  #   end
  #
  #   # Postconditions
  #   begin
  #     assert_equal(m, m_same, 'Equivalent matrices declared different')
  #     assert_not_equal(m, m_diff, 'Different matrices declared equivalent')
  #   end
  #
  #   assert_invariants(m)
  #   assert_invariants(m_same)
  #   assert_invariants(m_diff)
  # end
  #
  # def tst_cofactor
  #   m = @factory.random
  #
  #   # Preconditions
  #   begin
  #   end
  #
  #   cof_row = rand(0..m.rows)
  #   cof_col = rand(0..m.cols)
  #
  #   cof = m.cofactor(cof_row, cof_col)
  #
  #   # Postconditions
  #   begin
  #     if m.cols == 1 || m.rows == 1
  #       assert_true(cof.null?, 'Co-factor of vector non-nil')
  #     else
  #       assert_equal(cof.cols, m.cols - 1)
  #       assert_equal(cof.rows, m.rows - 1)
  #
  #       # TODO: Check the actual values of the cofactor matrix
  #     end
  #   end
  #
  #   assert_invariants(m)
  # end
  #
  # def tst_adjoint
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

  def test_identity?
    i = @factory.identity(rand(1..MAX_ROWS))
    m = @factory.random_square(range: 2...MAX_VAL)

    # Preconditions
    begin
    end

    identity = i.identity?
    non_identity = m.identity?

    # Posconditions
    begin
      assert_true(identity, 'Identity matrix declared as non-identity matrix')
      assert_false(non_identity, 'Non-identity matrix declared as identity matrix')
    end

    assert_invariants(i)
    assert_invariants(m)
  end

  def test_square?
    m = @factory.random

    # Preconditions
    begin
    end

    sq = m.square?

    # Postconditions
    begin
      assert_equal(m.rows == m.cols, sq, 'Square/non-square matrix declared as non-square/square')
    end

    assert_invariants(m)
  end

  def test_positive?
    pos_m = @factory.random(range: 1..MAX_VAL)
    neg_m = @factory.random(range: MIN_VAL..-1)

    # Preconditions
    begin
    end

    pos = pos_m.positive?
    neg = neg_m.positive?

    # Postconditions
    begin
      assert_true(pos, 'Positive matrix declared non-positive')
      assert_false(neg, 'Non-positive matrix declared as positive')
    end

    assert_invariants(pos_m)
    assert_invariants(neg_m)
  end

  def test_invertible?
    m = @factory.random_square

    # Preconditions
    begin
    end

    inv = m.invertible?

    # Postconditions
    begin
      assert_equal(m.square? && m.det != 0, inv, 'Invertible/singular matrix declared as singular/invertible.')
    end

    assert_invariants(m)
  end

  # def test_inverse
  #   m = @factory.random_square(size: rand(25...50))
  #
  #   # Preconditions
  #   begin
  #     # "Cannot calculate inverse of singular matrix
  #     return if not m.invertible?
  #   end
  #
  #   inv = m.inverse
  #
  #   # Postconditions
  #   begin
  #     assert_equal(m * inv, @factory.identity(m.rows), 'Matrix times its inverse not equal identity')
  #   end
  #
  #   assert_invariants(m)
  # end

  def test_symmetric?
    m = @factory.random

    # Preconditions
    begin
    end

    sym = m.symmetric?

    # Postconditions
    begin
      assert_equal(m == m.transpose, sym, 'Symmetric matrix not equal to its transpose')
    end

    assert_invariants(m)
  end

  def tst_traceable?
    m = @factory.random

    # Preconditions
    begin
    end

    tr = m.traceable?

    # Postconditions
    begin
      assert_equal(m.square?, tr, 'Square/non-square matrix are not-traceable/traceable')
    end

    assert_invariants(m)
  end

  def test_trace
    m = @factory.random_square

    # Preconditions
    begin
      assert_true(m.traceable?, 'Matrix is not traceable')
    end

    tr = m.trace

    # Postconditions
    begin
      assert_equal(m.diagonal.sum, tr, 'Trace not equal to sum of diagonal matrix')

      trace = 0
      (0..m.rows - 1).each do |r|
        trace += m.at(r, r)
      end

      assert_equal(trace, tr, 'Trace not equal to sum of diagonal elements')
    end

    assert_invariants(m)
  end

  def test_transpose
    m = @factory.random

    # Preconditions
    begin
    end

    mt = m.transpose

    # Postconditions
    begin
      assert_equal(m.rows, mt.cols, 'Transpose has a different number of columns')
      assert_equal(m.cols, mt.rows, 'Transpose has different number of rows')
      assert_equal(m.sum, mt.sum, 'Sum of transposes not equal')
      iterate_matrix(mt) {|i, j, v| assert_equal(m.at(j, i), v)}
      assert_equal(mt.transpose, m, 'Transpose of transpose not equal to original')
    end

    assert_invariants(m)
    assert_invariants(mt)
  end

  def test_zero?
    ms = [
        @factory.random,
        @factory.identity(rand(0..100)),
        @factory.zero(rand(0..MAX_ROWS))
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

  # def tst_rank
  #   m = @factory.random
  #
  #   # Preconditions
  #   begin
  #   end
  #
  #   r = m.rank
  #
  #   # Postconditions
  #   begin
  #     if m.nil? || m.zero?
  #       assert_equal(0, r, 'Rank non-zero for zero matrix')
  #       return
  #     end
  #
  #     assert_true(r > 0, 'Rank non-positive for non-nil matrix') unless m.nil? || m.zero?
  #     assert_true(r <= m.rows, 'Rank larger than number of rows')
  #
  #     if m.square?
  #       assert_equal(sparse_to_matrix(m).rank, r, 'Rank not equal to Ruby::Matrix rank')
  #       assert_equal(r, m.transpose.rank, 'Rank not equal to rank of transpose.')
  #     end
  #   end
  #
  #   assert_invariants(m)
  # end
  #
  # def test_orthogonal?
  #   m = @factory.random_square
  #
  #   # Preconditions
  #   begin
  #   end
  #
  #   orth = m.orthogonal?
  #
  #   # Post conditions
  #   begin
  #     assert_equal(m.transpose == m.inverse, orth, 'Conflict between orthogonal result and transpose/inverse equality')
  #   end
  #
  #   assert_invariants(m)
  # end
  #
  def test_tridiagonal
    (0..TEST_ITER).each do
      m = @factory.random_square

      # Preconditions
      begin
        assert_true(m.square?, "Tri-diagonal matrix must be square.")
      end

      tri_diag = m.tridiagonal

      # Postconditions
      begin
        assert_true(tri_diag.square?, 'Tri-diagonal matrix must be square.')

        (0...tri_diag.rows).each do |r|
          (0...tri_diag.cols).each do |c|
            unless r == c || c == r - 1 || c == r + 1
              assert_equal(tri_diag.at(r, c), 0, 'Tri-diagonal matrix cannot have non-zero elements outside of band.')
            end
          end
        end
      end

      assert_invariants(m)
    end
  end

  # def test_to_ruby_matrix
  #   m = @factory.random_square
  #
  #   # Preconditions
  #   begin
  #   end
  #
  #   ruby_m = m.to_ruby_matrix
  #
  #   # Postcondition
  #   begin
  #     (0...m.rows).each do |r|
  #       (0...m.cols).each do |c|
  #         assert_equal(m.at(r, c), ruby_m[r,c], "Ruby matrix value is incorrect at row:#{r} col:#{c}. Value: #{ruby_m[r,c]}")
  #       end
  #     end
  #   end
  # end
end
