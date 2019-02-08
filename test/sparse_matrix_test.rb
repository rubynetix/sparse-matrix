require 'test/unit'
require_relative '../lib/sparse_matrix'
require_relative './matrix_test_util'

class SparseMatrixTest < Test::Unit::TestCase
  include MatrixTestUtil

  MAX_ROWS = 1000
  MAX_COLS = 1000
  MIN_VAL = -10_000
  MAX_VAL = 10_000

  def assert_invariants(m)
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

      m = SparseMatrix.identity(size)

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

  def test_rows
    r = rand(0..MAX_ROWS)
    c = rand(1..MAX_COLS)
    m = SparseMatrix.new(r, c)

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
    r = rand(1..MAX_ROWS)
    c = rand(0..MAX_COLS)
    m = SparseMatrix.new(r, c)

    # Preconditions
    begin
      assert_true(c >= 0, "Number of cols is invalid: #{c}")
    end

    # Postconditions
    begin
      assert_equal(c, m.cols, "Number of matrix columns is incorrect. Expected: #{c}, Actual: #{m.cols}")
    end

    assert_invariants(m)
  end

  def tst_det
    s = rand(1..1000)
    m = SparseMatrix.new(s)

    # Preconditions
    begin
      assert_true(square?, 'Matrix for determinant test is not square')
    end

    d = m.det

    # Postconditions
    begin
      assert_equal(d, sparse_to_matrix(m).det, "Determinant is incorrect. Expected: #{sparse_to_matrix(m).det}, Actual: #{d}")
      assert_equal(d, m.t.det, "Determinant is incorrect. Expected: #{m.t.det}, Actual: #{d}")
    end

    assert_invariants(m)
  end

  def tst_resize
    r = rand(0..MAX_ROWS)
    c = rand(0..MAX_COLS)
    nr = rand(0..MAX_ROWS)
    nc = rand(0..MAX_COLS)
    m = rand_sparse(r, c)
    nnzi = m.nnz

    # Upsize test

    # Preconditions
    begin
      assert_equal(r, m.rows, "Number of rows is invalid. Expected: #{r}, Actual: #{m.rows}")
      assert_equal(c, m.cols, "Number of cols is invalid: Expected: #{c}, Actual: #{m.cols}")
    end

    m.resize(nr, nc)

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

  def tst_resize_down
    # A more explicit case where we check that
    # a value was removed
    r = rand(2..MAX_ROWS)
    c = rand(2..MAX_COLS)
    dr = r - 1
    dc = c - 1
    m = SparseMatrix.new(r, c)
    m.put(r, c, 1)

    # Preconditions
    begin
      assert_equal(r, m.rows, "Number of rows is invalid. Expected: #{r}, Actual: #{m.rows}")
      assert_equal(c, m.cols, "Number of cols is invalid: Expected: #{c}, Actual: #{m.cols}")
      assert_true(dr <= r, 'Resize down row count is larger than original matrix row count')
      assert_true(dc <= c, 'Resize down column count is larger than original matrix column count')
    end

    m.resize(dr, dc)

    # Postconditions
    begin
      assert_equal(dr, m.rows, "Resize rows is incorrect. Expected: #{dr}, Actual: #{m.rows}")
      assert_equal(dc, m.cols, "Resize cols is incorrect. Expected: #{dc}, Actual: #{m.cols}")
      assert_equal(0, m.nnz, 'Number of non-zero elements is invalid. The only non-zero element should have been pushed out during resize down')
    end

    assert_invariants(m)
  end

  def test_set_zero
    m = rand_sparse

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

  def tst_set_identity
    m = rand_sparse

    # Preconditions
    begin
    end

    m.set_identity

    # Postconditions
    begin
      (0..m.rows).each do |r|
        (0..m.cols).each do |c|
          if r == c
            assert_equal(1, m.at(r, c), "Value for set_identity matrix not 1 at row:#{r}, col:#{c}")
          else
            assert_equal(0, m.at(r, c), "Value for set_identity matrix not 0 at row:#{r}, col:#{c}")
          end
        end
      end
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

  def tst_clone
    m1 = rand_sparse

    # Preconditions
    begin
    end

    m1.freeze
    m2 = m1.clone

    # Postconditions
    begin
      assert_not_equal(m1.object_id, m2.object_id, "Object ids are equal after clone")
      assert_true(m2.frozen?, "Clone unfroze object")
      (0...m1.rows).each do |r|
        (0...m1.cols).each do |c|
          assert_equal(m1.at(r, c), m2.at(r, c), "Invalid value in clone matrix. Expected:#{m1.at(r, c)}, Actual:#{m2.at(r, c)}")
        end
      end
    end

    assert_invariants(m1)
    assert_invariants(m2)
  end

  def tst_to_s
    test_ms = [
      SparseMatrix.new(0, 0),
      SparseMatrix.create { [[10, 2, 3]] },
      SparseMatrix.identity(3),
      SparseMatrix.create { [[100, 0, 0, 0], [0, 1, 1, 0], [0, -1, 0, 0]] }
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
          assert_equal(0, char_count('\n', s), 'Nil Matrix incorrect to_s format')
        else
          # number of \n == rows()
          assert_equal(m.rows, char_count('\n', s), 'Matrix incorrect to_s format ')
          t
          # all rows have the same length
          len = nil
          s.each_line('\n') do |l|
            len = l.size if len.nil?
            assert_equal(len, l.size, 'Matrix to_s format, incorrect row length')
          end
        end
      end

      assert_invariants(m)
    end
  end

  def test_sum
    m = rand_sparse

    # Preconditions
    begin
    end

    sum = m.sum

    # Postconditions
    begin
      expected = 0
      (0..m.rows-1).each do |r|
        (0..m.cols-1).each do |c|
          expected += m.at(r, c)
        end
      end

      assert_equal(expected, sum, "Incorrect matrix sum. Expected:#{expected}, Actual: #{sum}")
    end

    assert_invariants(m)
  end

  def tst_add_matrix
    r = rand(1..MAX_ROWS)
    c = rand(1..MAX_COLS)
    m1 = rand_sparse(rows: r, cols: c)
    m2 = rand_sparse(rows: r, cols: c)

    # Preconditions
    begin
      assert_equal(m1.rows, m2.rows, "Incompatable matrix row count, vector addition not possible. Matrix 1 Row Count:#{m1.rows}, Matrix 2 Row Count:#{m2.rows}")
      assert_equal(m1.cols, m2.cols, "Incompatable matrix column count, vector addition not possible. Matrix 1 Col Count:#{m1.cols}, Matrix 2 Col Count:#{m2.cols}")
    end

    m3 = m1 + m2

    # Postconditions
    begin
      assert_equal(m1.sum + m2.sum, m3.sum, "Matrix vector addition incorrect. Expected Sum:#{m1.sum + m2.sum}, Actual Sum:#{m3.sum}")

      if m1.traceable?
        assert_equal(m1.trace + m2.trace, m3.trace, "Matrix vector addition incorrect. Expected Trace:#{m1.trace + m2.trace}, Actual Trace:#{m3.trace}")
      end

      assert_equal(m1, m3 - m2, 'Matrix vector addition incorrect. Expected reversible operation')

      (0..m1.rows).each do |r2|
        (0..m1.cols).each do |c2|
          assert_equal(m1.at(r2, c2) + m2.at(r2, c2), m3.at(r2, c2), "Incorrect vector addition at row:#{r2}, col:#{c2}. Expected:#{m1.at(r2, c2) + m2.at(r2, c2)}, Actual:#{m3.at(r2, c2)}")
        end
      end
    end

    assert_invariants(m1)
    assert_invariants(m2)
    assert_invariants(m3)
  end

  def tst_add_scalar
    m1 = rand_sparse
    num = rand(MIN_VAL..MAX_VAL)

    # Preconditions
    begin
    end

    m2 = m1 + num

    # Postconditions
    begin
      assert_equal(m1.sum + num * m1.nnz, m2.sum, "Matrix scalar addition incorrect. Expected Sum:#{m1.sum + num * m1.nnz}, Actual Sum:#{m2.sum}")

      (0..m1.rows).each do |r|
        (0..m1.cols).each do |c|
          assert_equal(m1.at(r, c) + num, m2.at(r, c), "Incorrect scalar addition at row:#{r2}, col:#{c2}. Expected:#{m1.at(r, c) + num}, Actual:#{m2.at(r, c)}")
        end
      end
    end

    assert_invariants(m1)
    assert_invariants(m2)
    assert_invariants(m3)
  end

  def tst_subtract_matrix
    r = rand(1..MAX_ROWS)
    c = rand(1..MAX_COLS)
    m1 = rand_sparse(rows: r, cols: c)
    m2 = rand_sparse(rows: r, cols: c)

    # Preconditions
    begin
      assert_equal(m1.rows, m2.rows, "Incompatable matrix row count, vector subtraction not possible. Matrix 1 Row Count:#{m1.rows}, Matrix 2 Row Count:#{m2.rows}")
      assert_equal(m1.cols, m2.cols, "Incompatable matrix column count, vector subtraction not possible. Matrix 1 Col Count:#{m1.cols}, Matrix 2 Col Count:#{m2.cols}")
    end

    m3 = m1 - m2

    # Postconditions
    begin
      assert_equal(m1.sum - m2.sum, m3.sum, "Matrix vector subtraction incorrect. Expected Sum:#{m1.sum - m2.sum}, Actual Sum:#{m3.sum}")

      if m1.traceable?
        assert_equal(m1.trace - m2.trace, m3.trace, "Matrix vector subtraction incorrect. Expected Trace:#{m1.trace - m2.trace}, Actual Trace:#{m3.trace}")
      end

      assert_equal(m1, m3 + m2, 'Matrix vector subtraction incorrect. Expected reversible operation')

      (0..m1.rows).each do |r2|
        (0..m1.cols).each do |c2|
          assert_equal(m1.at(r2, c2) - m2.at(r2, c2), m3.at(r2, c2), "Incorrect vector subtraction at row:#{r2}, col:#{c2}. Expected:#{m1.at(r2, c2) - m2.at(r2, c2)}, Actual:#{m3.at(r2, c2)}")
        end
      end
    end

    assert_invariants(m1)
    assert_invariants(m2)
    assert_invariants(m3)
  end

  def tst_subtract_scalar
    m1 = rand_sparse
    num = rand(MIN_VAL..MAX_VAL)

    # Preconditions
    begin
    end

    m2 = m1 - num

    # Postconditions
    begin
      assert_equal(m1.sum - num * m1.nnz, m2.sum, "Matrix scalar subtraction incorrect. Expected Sum:#{m1.sum - num * m1.nnz}, Actual Sum:#{m2.sum}")

      (0..m1.rows).each do |r|
        (0..m1.cols).each do |c|
          assert_equal(m1.at(r, c) - num, m2.at(r, c), "Incorrect scalar subraction at row:#{r}, col:#{c}. Expected:#{m1.at(r, c) - num}, Actual:#{m2.at(r, c)}")
        end
      end
    end

    assert_invariants(m1)
    assert_invariants(m2)
  end

  # TODO: * matrix

  def tst_scalar_mult
    r = rand(0..MAX_ROWS)
    c = rand(1..MAX_COLS)
    m = rand_matrix(r, c)
    rand_range(1, 1000, 20).each do |mult|
      # Preconditions
      begin
      end

      new_m = m * mult

      # Postconditions
      begin
        (0..r).each do |i|
          (0..c).each do |j|
            assert_equal(m.at(i, j) * mult, new_m.at(i, j), "Incorrect scalar multiplication at row:#{i}, col:#{j}. Expected:#{m.at(i, j) * mult}, Actual:#{new_m.at(i, j)}")
          end
        end
      end

      assert_invariants(m)
    end
  end

  def tst_exponentiation
    r = rand(0..MAX_ROWS)
    c = rand(1..MAX_COLS)
    m = rand_matrix(r, c)
    rand_range(1, 15, 20).each do |exp|
      # Preconditions
      begin
      end

      new_m = m.**(exp)

      # Postconditions
      begin
        expected = m
        (0..exp).each do |_i|
          expected *= m
          assert_equal(expected, new_m, "Incorrect exponentiation. Expected:#{expected}, Actual:#{new_m}")
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

  def tst_diagonal?
    m = rand_sparse

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

  def tst_diagonal
    m = rand_sparse

    # Preconditions
    begin
      assert_true(square?, 'Diagonal not defined for non-square matrix')
    end

    md = m.diagonal

    # Postconditions
    begin
      assert_true(m.diagonal?, "Diagonal conversion invalid. Expected: True, Actual:#{m.diagonal?}")

      # All elements on the diagonal are equivalent to the original matrix
      (0..m.rows - 1).each do |i|
        assert_equal(m.at(i, i), md.at(i, i), 'Diagonal elements not-equal to original diagonal')
      end
    end

    assert_invariants(m)
  end

  def tst_lower_triangular?(_nonsquare)
    r = 0
    c = 0
    while r != c
      r = rand(0..MAX_ROWS)
      c = rand(0..MAX_COLS)
      m = rand_matrix(r, c)
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

  def tst_lower_triangular_square
    i = 0
    while i < 20
      rc = rand(0..MAX_ROWS)
      m_tri = lower_triangular_matrix(rc, 0, 1000)
      m_random = rand_matrix(rc, rc)

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

  def tst_upper_triangular_nonsquare
    r = 0
    c = 0
    while r != c
      r = rand(0..MAX_ROWS)
      c = rand(0..MAX_COLS)
      m = rand_matrix(r, c)
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

  def tst_upper_triangular_square
    i = 0
    while i < 20
      rc = rand(0..MAX_ROWS)
      m_tri = upper_triangular_matrix(rc, 0, 1000)
      m_random = rand_matrix(rc, rc)

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
    if !m.square?
      assert_false(m.lower_hessenberg?, "Lower Hessenberg check for Non-square Matrix is incorrect. Expected: False, Actual:#{m.lower_hessenberg?}")
    else
      (0...m.rows).each do |y|
        (0...m.cols).each do |x|
          if x > y + 1
            assert_equal(0, m.at(x, y), "Lower Hessenberg Matrix is not zero at row:#{y} col:#{x}. Value: #{m.at(x, y)}")
          end
        end
      end
    end
  end

  def tst_lower_hessenberg_nonsquare
    # tests lower_hessenberg? with a nonsquare matrix
    r = 0
    c = 0
    while r != c
      r = rand(0..10_000)
      c = rand(0..10_000)
      m = rand_matrix(r, c)
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

  def tst_lower_hessenberg_square
    # tests lower_hessenberg with a square matrix
    i = 0
    while i < 20
      rc = rand(0..MAX_ROWS)
      m_hess = lower_hessenberg_matrix(rc, 0, 1000)
      m_random = rand_matrix(rc, rc)

      # Preconditions
      begin
      end

      # Postconditions
      begin
        check_lower_hessenberg(m_hess)
        check_lower_hessenberg(m_random)
      end

      assert_invariants(m_hess)
      assert_invariants(m_random)

      i += 1
    end
  end

  def check_upper_hessenberg(m)
    # algorithm to test matrix m is upper_hessenberg
    if !m.square?
      assert(!m.upper_hessenberg?, 'Non-square matrix cannot be upper hessenberg')
    else
      (0...m.rows).each do |y|
        (0...m.cols).each do |x|
          if y > x + 1
            assert_equal(0, m.at(x, y), 'Nonzero value below tri-diagonal band, cannot be upper hessenberg')
          end
        end
      end
    end
  end

  def tst_upper_hessenberg_nonsquare
    # tests upper_hessenberg? with a nonsquare matrix
    r = 0
    c = 0
    while r != c
      r = rand(0..MAX_ROWS)
      c = rand(0..MAX_COLS)
      m = rand_matrix(r, c)
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

  def tst_upper_hessenberg_square
    # tests upper_hessenberg with a square matrix
    i = 0
    while i < 10
      rc = rand(0..MAX_ROWS)
      m_hess = upper_hessenberg_matrix(rc, 0, 1000)
      m_random = rand_matrix(rc, rc)

      # Preconditions
      begin
      end

      # Postconditions
      begin
        check_upper_hessenberg(m_hess)
        check_upper_hessenberg(m_random)
      end

      assert_invariants(m_hess)
      assert_invariants(m_random)

      i += 1
    end
  end

  def tst_equals
    r1 = 0
    r2 = 0
    while r1 != r2
      r1 = rand(0..MAX_ROWS)
      r2 = rand(0..MAX_ROWS)
    end
    m = rand_matrix(r1, rand(0..MAX_ROWS))
    m_same = m.clone
    m_diff = rand_matrix(r2, rand(0..MAX_ROWS))

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

  def tst_identity?
    i = identity_matrix
    m = rand_square_sparse(range: 2...MAX_VAL)

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

  def tst_square?
    m = rand_sparse

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

  def tst_positive?
    pos_m = rand_sparse(range: 0..MAX_VAL)
    neg_m = rand_sparse(range: MIN_VAL..-1)

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

  def tst_invertible?
    m = rand_sparse

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

  def tst_inverse
    m = rand_square_sparse

    # Preconditions
    begin
      assert_true(m.invertible?, 'Cannot calculate inverse of singular matrix')
    end

    inv = m.inverse

    # Postconditions
    begin
      assert_equal(m * inv, SparseMatrix.identity(m.rows), 'Matrix times its inverse not equal identity')
    end

    assert_invariants(m)
  end

  def tst_symmetric?
    m = rand_sparse

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
    m = rand_sparse

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

  def tst_trace
    m = rand_sparse

    # Preconditions
    begin
      assert_true(m.traceable?, 'Matrix is not traceable')
    end

    tr = m.trace

    # Postconditions
    begin
      assert_equal(m.diagonal.trace, tr, 'Trace not equal to trace of diagonal matrix')
      assert_equal(m.diagonal.sum, tr, 'Trace not equal to sum of diagonal matrix')

      trace = 0
      (0..m.rows).each do |r|
        trace += m.at(r, r)
      end

      assert_equal(trace, tr, 'Trace not equal to sum of diagonal elements')
    end

    assert_invariants(m)
  end

  def tst_transpose
    m = rand_sparse

    # Preconditions
    begin
    end

    mt = m.transpose

    # Postconditions
    begin
      assert_equal(m.rows, mt.cols, 'Transpose has a different number of columns')
      assert_equal(m.cols, mt.rows, 'Transpose has different number of rows')
      assert_equal(m.sum, mt.sum, 'Sum of transposes not equal')
      iterate_matrix(mt) { |i, j, v| assert_equal(m.at(j, i), v) }
      assert_equal(mt.transpose, m, 'Transpose of transpose not equal to original')
    end

    assert_invariants(m)
    assert_invariants(mt)
  end

  def tst_zero?
    ms = [
      rand_sparse,
      SparseMatrix.new(0),
      SparseMatrix.identity(3),
      SparseMatrix.zero((0..100), (0..100))
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

  def tst_orthogonal?
    m = rand_square_sparse

    # Preconditions
    begin
    end

    orth = m.orthogonal?

    # Post conditions
    begin
      assert_true(m.transpose == m.inverse, orth, 'Conflict between orthogonal result and transpose/inverse equality')
    end

    assert_invariants(m)
  end

  def tst_tridiagonal
    TestUtil.rand_range(1, 1000, 20).each do |len|
      upper_diagonal = Array.new(len - 1)
      upper_diagonal.put(TestUtil.rand_range(1, 1000, len - 1))
      lower_diagonal = Array.new(len - 1)
      lower_diagonal.put(TestUtil.rand_range(1, 1000, len - 1))
      diagonal = Array.new(len)
      diagonal.put(TestUtil.rand_range(1, 1000, len))
      diagonals = Array.[](upper_diagonal, diagonal, lower_diagonal)

      # Preconditions
      begin
        assert_equal(diagonals[1].length, (diagonals[0].length + 1), 'Upper/main diagonal band lengths differ by more than one')
        assert_equal(diagonals[1].length, (diagonals[2].length + 1), 'Lower/main diagonal band lengths differ by more than one')
      end

      m = SparseMatrix.tridagonal(diagonals)

      # Postconditions
      begin
        assert_true(m.square?, 'Tri-diagonal matrix must be square.')
        range 0...len.each do |y|
          range 0...len.each do |x|
            unless x == y || x == y - 1 || x == y + 1
              assert_equal(m.at(x, y), 0, 'Tri-diagonal matrix cannot have non-zero elements outside of band.')
            end
          end
        end
      end

      assert_invariants(m)
    end
  end
end
