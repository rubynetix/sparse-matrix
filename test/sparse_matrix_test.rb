require 'test/unit'
require_relative '../lib/sparse_matrix'
require_relative './matrix_test_util'

class SparseMatrixTest < Test::Unit::TestCase

  MAX_ROWS = 10000
  MAX_COLS = 10000
  MIN_VAL = -10000
  MAX_VAL = 10000

  def assert_invariants(m)
    assert_true(m.rows >= 0)
    assert_true(m.cols >= 0)
    if m.cols > 0
      assert_true(m.rows > 0)
    end
    if m.rows > 0
      assert_true(m.cols > 0)
    end
    if m.rows == 0
      assert_true(m.cols == 0)
    end
    if m.cols == 0
      assert_true(m.rows == 0)
    end
  end

  def tst_identity
    TestUtil::rand_range(1, MAX_ROWS, 20).each do |size|
      # Preconditions
      begin
        assert_true(size > 0)
      end

      m = SparseMatrix.identity(size)

      # Postconditions
      begin
        assert_true(m.square?)
        assert_true(m.diagonal?)
        assert_true(m.symmetric?)
        assert_equal(size, m.sum)
        (0..size-1).each do |i|
          assert_equal(1, m.at(i, i))
        end
      end
    end
  end

  def tst_nnz
    n = rand(0..20)
    m = SparseMatrix.new(n, n)
    # TODO: insert n random elements into m

    # Preconditions
    begin
      assert_true(n >= 0)
    end

    # Postconditions
    begin
      assert_equal(n, m.nnz)
    end
  end

  def tst_rows
    r = rand(0..MAX_ROWS)
    c = rand(1..MAX_COLS)
    m = SparseMatrix.new(r, c)

    # Preconditions
    begin
      assert_true(r >= 0)
    end

    # Postconditions
    begin
      assert_equal(r, m.rows)
    end
  end

  def tst_cols
    r = rand(1..MAX_ROWS)
    c = rand(0..MAX_COLS)
    m = SparseMatrix.new(r, c)

    # Preconditions
    begin
      assert_true(c >= 0)
    end

    # Postconditions
    begin
      assert_equal(c, m.cols)
    end
  end

  def tst_det
    s = rand(1..1000)
    m = SparseMatrix.new(s)

    # Preconditions
    begin
      assert_true(square?)
    end

    d = m.det

    # Postconditions
    begin
      assert_equal(d, sparse_to_matrix(m).det)
      assert_equal(d, m.t.det)
    end
  end

  def tst_resize
    r = rand(0..MAX_ROWS)
    c = rand(0..MAX_COLS)
    nr = rand(0..MAX_ROWS)
    nc = rand(0..MAX_COLS)
    m = MatrixTestUtil::rand_sparse(r, c)
    nnzi = m.nnz

    # Upsize test

    # Preconditions
    begin
      assert_equal(r, m.rows)
      assert_equal(c, m.cols)
    end

    m.resize(nr, nc)

    # Postconditions
    begin
      assert_equal(nr, m.rows)
      assert_equal(nc, m.cols)

      # Resize up
      if nr >= r and nc >= c
        assert_equal(nnzi, m.nnz)
        return
      end

      # Resizing down
      assert_true(nnzi >= m.nnz)
    end
  end

  def tst_resize_down
    # A more explicit case where we check that
    # a value was removed
    r = rand(2..MAX_ROWS)
    c = rand(2..MAX_COLS)
    dr = r - 1
    dc = c - 1
    m = SparseMatrix.new(r, c)
    m.insert(r, c, 1)

    # Preconditions
    begin
      assert_equal(r, m.rows)
      assert_equal(c, m.cols)
      assert_true(dr <= r)
      assert_true(dc <= c)
    end

    m.resize(dr, dc)

    # Postconditions
    begin
      assert_equal(dr, m.rows)
      assert_equal(dc, m.cols)
      assert_equal(0, m.nnz)
    end
  end

  def tst_set_zero
    m = MatrixTestUtil::rand_sparse

    # Preconditions
    begin
    end

    m.set_zero

    # Postconditions
    begin
      (0..m.rows).each do |r|
        (0..m.cols).each do |c|
          assert_equal(0, m.at(r, c))
        end
      end
    end
  end

  def tst_set_identity
    m = MatrixTestUtil::rand_sparse

    # Preconditions
    begin
    end

    m.set_identity

    # Postconditions
    begin
      (0..m.rows).each do |r|
        (0..m.cols).each do |c|
          if r == c
            assert_equal(1, m.at(r, c))
          else
            assert_equal(0, m.at(r, c))
          end
        end
      end
    end
  end

  def tst_at
    v = rand(MIN_VAL..MAX_VAL)
    m = SparseMatrix.new(100, 100)
    r = rand(0..99)
    c = rand(0.99)

    m.insert(r, c, v)

    # Preconditions
    begin
      assert_true(0 <= r && r <= m.rows - 1)
      assert_true(0 <= c && c <= m.cols - 1)
    end

    # Postconditions
    begin
      assert_equal(v, m.at(r, c))
    end
  end

  def tst_clone
    m1 = MatrixTestUtil::rand_sparse

    # Preconditions
    begin
    end

    m2 = m1.clone

    # Postconditions
    begin
      (0..m1.rows).each do |r|
        (0..m1.cols).each do |c|
          assert_equal(m1.at(r, c), m2.at(r, c))
        end
      end
    end
  end

  def tst_to_s
    test_ms = [
        SparseMatrix.new(0, 0),
        SparseMatrix.create { [[10, 2, 3]] },
        SparseMatrix.identity(3),
        SparseMatrix.create { [[100, 0, 0, 0 ], [0, 1, 1, 0], [0, -1, 0, 0]] }
    ]

    exps = [
        "nil\n",    # the null case
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
        assert_equal(e, s)

        # More generically
        if m.nil?
          assert_equal(0, MatrixTestUtil::char_count('\n', s))
        else
          # number of \n == rows()
          assert_equal(m.rows, MatrixTestUtil::char_count('\n', s))
          t
          # all rows have the same length
          len = nil
          s.each_line('\n') do |l|
            len = l.size if len.nil?
            assert_equal(len, l.size)
          end
        end
      end
    end
  end

  def tst_sum
    m = MatrixTestUtil::rand_sparse

    # Preconditions
    begin
    end

    sum = m.sum

    # Postconditions
    begin
      it = m.iterator
      expected = 0

      while it.has_next? do
        el = it.next
        expected += el.val
      end

      assert_equal(expected, sum)
    end
  end

  def tst_add_matrix
    r = rand(1..MAX_ROWS)
    c = rand(1..MAX_COLS)
    m1 = MatrixTestUtil::rand_sparse(rows: r, cols: c)
    m2 = MatrixTestUtil::rand_sparse(rows: r, cols: c)

    #Preconditions
    begin
      assert_equal(m1.rows, m2.rows)
      assert_equal(m1.cols, m2.cols)
    end

    m3 = m1 + m2

    # Postconditions
    begin
      assert_equal(m1.sum + m2.sum, m3.sum)

      if m1.traceable?
        assert_equal(m1.trace + m2.trace, m3.trace)
      end

      assert_equal(m1, m3 - m2)

      (0..m1.rows).each do |r2|
        (0..m1.cols).each do |c2|
          assert_equal(m1.at(r2, c2) + m2.at(r2, c2), m3.at(r2, c2))
        end
      end
    end
  end

  def tst_add_scalar
    m1 = MatrixTestUtil::rand_sparse()
    num = rand(MIN_VAL..MAX_VAL)

    # Preconditions
    begin
    end

    m2 = m1 + num

    # Postconditions
    begin
      assert_equal(m1.sum + num * m1.nnz, m2.sum)

      (0..m1.rows).each do |r|
        (0..m1.cols).each do |c|
          assert_equal(m1.at(r, c) + num, m2.at(r, c))
        end
      end
    end
  end

  def tst_subtract_matrix
    r = rand(1..MAX_ROWS)
    c = rand(1..MAX_COLS)
    m1 = MatrixTestUtil::rand_sparse(rows: r, cols: c)
    m2 = MatrixTestUtil::rand_sparse(rows: r, cols: c)

    #Preconditions
    begin
      assert_equal(m1.rows, m2.rows)
      assert_equal(m1.cols, m2.cols)
    end

    m3 = m1 - m2

    # Postcondition
    begin
      assert_equal(m1.sum - m2.sum, m3.sum)

      if m1.traceable?
        assert_equal(m1.trace - m2.trace, m3.trace)
      end

      assert_equal(m1, m3 + m2)

      (0..m1.rows).each do |r2|
        (0..m1.cols).each do |c2|
          assert_equal(m1.at(r2, c2) - m2.at(r2, c2), m3.at(r2, c2))
        end
      end
    end
  end

  def tst_subtract_scalar
    m1 = MatrixTestUtil::rand_sparse()
    num = rand(MIN_VAL..MAX_VAL)

    # Preconditions
    begin
    end

    m2 = m1 - num

    # Postconditions
    begin
      assert_equal(m1.sum - num * m1.nnz, m2.sum)

      (0..m1.rows).each do |r|
        (0..m1.cols).each do |c|
          assert_equal(m1.at(r, c) - num, m2.at(r, c))
        end
      end
    end
  end

  # TODO: * matrix

  def tst_scalar_mult
    r = rand(0..10000)
    c = rand(1..10000)
    m = MatrixTestUtil::rand_matrix(r, c)
    MatrixTestUtil::rand_range(1, 1000, 20).each do |mult|
      # Preconditions
      begin

      end

      new_m = m.*(mult)

      # Postconditions
      begin
        (0..r).each do |i|
          (0..c).each do |j|
            assert_equal(m.at(i, j) * mult, new_m.at(i, j))
          end
        end
      end
    end
  end

  def tst_exponentiation
    r = rand(0..MAX_ROWS)
    c = rand(1..MAX_COLS)
    m = MatrixTestUtil::rand_matrix(r, c)
    MatrixTestUtil::rand_range(1, 15, 20).each do |exp|
      # Preconditions
      begin

      end

      new_m = m.**(exp)

      # Postconditions
      begin
        expected = m
        (0..exp).each do |i|
          expected = expected.*(m)
          assert_equal(expected, new_m)
        end
      end
    end
  end

  def tst_insert
    v = rand(MIN_VAL..MAX_VAL)
    m = SparseMatrix.new(100, 100)
    r = rand(0..99)
    c = rand(0.99)

    # Preconditions
    begin
      assert_true(0 <= r && r <= m.rows - 1)
      assert_true(0 <= c && c <= m.cols - 1)
    end

    nnz_before = m.nnz
    v_before = v.at(r, c)
    m.insert(r, c, v)

    # Postconditions
    begin
      # Check that the value is set
      assert_equal(v, m.at(r, c))

      if (v != 0 and v_before != 0) or (v == 0 and v_before == 0)
        assert_equal(nnz_before, m.nnz)
      elsif v != 0 and v_before == 0
        assert_equal(nnz_before+1, m.nnz)
      else # v == 0 and v_before != 0
        assert_equal(nnz_before-1, m.nnz)
      end
    end
  end

  # Helper function for test_diagonal?
  def nnz_off_diagonal?(m)
    (0..m.rows-1).each do |i|
      (0..m.cols-1).each do |j|
        if i != j
          if m.at(i,j) != 0
            return true
          end
        end
      end
    end
    false
  end

  def tst_diagonal?
    m = MatrixTestUtil::rand_sparse

    # Preconditions
    begin
    end

    is_d = m.diagonal?

    # Postconditions
    begin
      if is_d
        assert_true(m.symmetric?)
        assert_true(m.square?)

        # For all i,j where i != j -> at(i,j) == 0
        iterate_matrix(m) {|i, j, v|
          assert_equal(0, v) unless i == j
        }
      else
        # For some i,j where i != j -> at(i,j) != 0
        assert_true(nnz_off_diagonal?(m))
      end
    end
  end

  def tst_diagonal
    m = MatrixTestUtil::rand_sparse

    # Preconditions
    begin
      assert_true(square?)
    end

    md = m.diagonal

    # Postconditions
    begin
      assert_true(m.diagonal?)

      # All elements on the diagonal are equivalent to the original matrix
      (0..m.rows-1).each do |i|
        assert_equal(m.at(i,i), md.at(i,i))
      end
    end
  end

  def tst_lower_triangular_nonsquare
    r = 0
    c = 0
    while r != c
      r = rand(0..MAX_ROWS)
      c = rand(0..MAX_COLS)
      m = MatrixTestUtil::rand_matrix(r, c)
    end

    # Preconditions
    begin
    end

    # Postconditions
    begin
      assert_equal(MatrixTestUtil::sparse_to_matrix(m).lower_triangular?, m.lower_triangular?)
    end
  end

  def tst_lower_triangular_square
    i = 0
    while i < 20
      rc = rand(0..MAX_ROWS)
      m_tri = MatrixTestUtil::lower_triangular_matrix(rc, 0, 1000)
      m_random = MatrixTestUtil::rand_matrix(rc, rc)

      # Preconditions
      begin
      end

      # Postconditions
      begin
        assert_equal(MatrixTestUtil::sparse_to_matrix(m_tri).lower_triangular?, m_tri.lower_triangular?)
        assert_equal(MatrixTestUtil::sparse_to_matrix(m_random).lower_triangular?, m_random.lower_triangular?)
      end
      i += 1
    end
  end

  def tst_upper_triangular_nonsquare
    r = 0
    c = 0
    while r != c
      r = rand(0..MAX_ROWS)
      c = rand(0..MAX_COLS)
      m = MatrixTestUtil::rand_matrix(r, c)
    end

    # Preconditions
    begin
    end

    # Postconditions
    begin
      assert_equal(MatrixTestUtil::sparse_to_matrix(m).upper_triangular?, m.upper_triangular?)
    end
  end

  def tst_upper_triangular_square
    i = 0
    while i < 20
      rc = rand(0..MAX_ROWS)
      m_tri = MatrixTestUtil::upper_triangular_matrix(rc, 0, 1000)
      m_random = MatrixTestUtil::rand_matrix(rc, rc)

      # Preconditions
      begin
      end

      # Postconditions
      begin
        assert_equal(MatrixTestUtil::sparse_to_matrix(m_tri).upper_triangular?, m_tri.upper_triangular?)
        assert_equal(MatrixTestUtil::sparse_to_matrix(m_random).upper_triangular?, m_random.upper_triangular?)
      end
      i += 1
    end
  end

  def check_lower_hessenberg(m)
    # algorithm to test if matrix m is lower_hessenberg
    if !m.square?
      assert(!m.lower_hessenberg?)
    else
      for y in 0...m.rows()
        for x in 0...m.cols()
          if x > y + 1
            assert_equal(0, m.at(x, y))
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
      r = rand(0..10000)
      c = rand(0..10000)
      m = MatrixTestUtil::rand_matrix(r, c)
    end

    # Preconditions
    begin
    end

    # Postconditions
    begin
      check_lower_hessenberg(m)
    end
  end

  def tst_lower_hessenberg_square
    # tests lower_hessenberg with a square matrix
    i = 0
    while i < 20
      rc = rand(0..MAX_ROWS)
      m_hess = MatrixTestUtil::lower_hessenberg_matrix(rc, 0, 1000)
      m_random = MatrixTestUtil::rand_matrix(rc, rc)

      # Preconditions
      begin
      end

      # Postconditions
      begin
        check_lower_hessenberg(m_hess)
        check_lower_hessenberg(m_random)
      end
      i += 1
    end
  end

  def check_upper_hessenberg(m)
    # algorithm to test matrix m is upper_hessenberg
    if !m.square?
      assert(!m.upper_hessenberg?)
    else
      for y in 0...m.rows
        for x in 0...m.cols
          if y > x + 1
            assert_equal(0, m.at(x, y))
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
      m = MatrixTestUtil::rand_matrix(r, c)
    end

    # Preconditions
    begin
    end

    # Postconditions
    begin
      check_upper_hessenberg(m)
    end
  end

  def tst_upper_hessenberg_square
    # tests upper_hessenberg with a square matrix
    i = 0
    while i < 10
      rc = rand(0..MAX_ROWS)
      m_hess = MatrixTestUtil::upper_hessenberg_matrix(rc, 0, 1000)
      m_random = MatrixTestUtil::rand_matrix(rc, rc)

      # Preconditions
      begin
      end

      # Postconditions
      begin
        check_upper_hessenberg(m_hess)
        check_upper_hessenberg(m_random)
      end
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
    m = MatrixTestUtil::rand_matrix(r1, rand(0..MAX_ROWS))
    m_same = m.clone
    m_diff = MatrixTestUtil::rand_matrix(r2, rand(0..MAX_ROWS))

    # Preconditions
    begin
      assert_true(m_same.rows >= 0)
      assert_true(m_same.cols >= 0)
      assert_true(m_diff.rows >= 0)
      assert_true(m_diff.cols >= 0)
    end

    # Postconditions
    begin
      assert_true(m == m_same)
      assert_true(m != m_diff)
    end
  end

  def tst_cofactor
    m = MatrixTestUtil::rand_sparse()

    # Preconditions
    begin
    end

    cof_row = rand(0..m.rows)
    cof_col = rand(0..m.cols)

    cof = m.cofactor(cof_row, cof_col)

    # Postconditions
    begin
      if m.cols == 1  || m.rows == 1
        assert_true(cof.null?)
      else
        cof.cols = m.cols - 1
        cof.rows = m.rows - 1

        #TODO: Check the actual values of the cofactor matrix
      end
    end
  end

  def tst_adjoint
    m = MatrixTestUtil::rand_square_sparse()

    # Preconditions
    begin
      assert_true(m.square?)
    end

    adj = m.adjoint

    # Postconditions
    begin
      cof = m.cofactor
      assert_equal(adj, cof.transpose)
    end
  end

  def tst_identity?
    i = MatrixTestUtil::identity_matrix()
    m = MatrixTestUtil::rand_square_sparse()

    # Preconditions
    begin
    end

    identity = i.identity?
    non_identity = m.identity?

    # Posconditions
    begin
      assert_true(identity)
      assert_false(non_identity)
    end

  end

  def tst_square?
    m = MatrixTestUtil::rand_sparse()

    # Preconditions
    begin
    end

    sq = m.square?

    # Postconditions
    begin
      assert_equal(m.rows == m.cols, sq)
    end
  end

  def tst_positive?
    pos_m = MatrixTestUtil::rand_sparse(range: 0..MAX_VAL)
    neg_m = MatrixTestUtil::rand_sparse(range: MIN_VAL..-1)

    # Preconditions
    begin
    end

    pos = pos_m.positive?
    neg = neg_m.positive?

    # Postconditions
    begin
      assert_true(pos)
      assert_false(neg)
    end
  end

  def tst_invertible?
    m = MatrixTestUtil::rand_sparse()

    # Preconditions
    begin
    end

    inv = m.invertible?

    # Postconditions
    begin
      assert_equal(m.square? && m.det != 0, inv)
    end
  end

  def tst_inverse
    m = MatrixTestUtil::rand_square_sparse()

    # Preconditions
    begin
      assert_true(m.invertible?)
    end

    inv = m.inverse

    # Postconditions
    begin
      assert_equal(m * inv, SparseMatrix::identity(m.rows))
    end
  end

  def tst_symmetric?
    m = MatrixTestUtil::rand_sparse()

    # Preconditions
    begin
    end

    sym = m.symmetric?

    # Postconditions
    begin
      assert_equal(m == m.transpose, sym)
    end
  end

  def tst_traceable?
    m = MatrixTestUtil::rand_sparse()

    # Preconditions
    begin
    end

    tr = m.traceable?

    # Postconditions
    begin
      assert_equal(m.square?, tr)
    end
  end

  def tst_trace
    m = MatrixTestUtil::rand_sparse()

    # Preconditions
    begin
      assert_true(m.traceable?)
    end

    tr = m.trace

    # Postconditions
    begin
      assert_equal(m.diagonal.trace, tr)
      assert_equal(m.diagonal.sum, tr)

      trace = 0
      (0..m.rows).each do |r|
        trace += m.at(r, r)
      end

      assert_equal(trace, tr)
    end
  end

  def tst_transpose
    m = MatrixTestUtil::rand_sparse

    # Preconditions
    begin
    end

    mt = m.transpose

    # Postconditions
    begin
      assert_equal(m.rows, mt.cols)
      assert_equal(m.cols, mt.rows)
      assert_equal(m.sum, mt.sum)
      MatrixTestUtil::iterate_matrix(mt) { |i, j, v| assert_equal(m.at(j, i), v) }
      assert_true(mt.transpose == m)
    end
  end

  def tst_zero?
    ms = [
        MatrixTestUtil::rand_sparse,
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
          assert_false(is_zero)
        else
          assert_true(is_zero)
        end
      end
    end
  end

  def tst_rank
    assert_equal(0, SparseMatrix.zero(0..100, 0..100).rank)

    m = MatrixTestUtil::rand_sparse

    # Preconditions
    begin
    end

    r = m.rank

    # Postconditions
    begin
      if m.nil? or m.zero?
        assert_equal(0, r)
        return
      end

      assert_true(r > 0) unless m.nil? or m.zero?
      assert_true(r <= m.rows)

      if m.square?
        assert_equal(MatrixTestUtil::sparse_to_matrix(m).rank, r)
        assert_equal(r, m.transpose.rank)
      end
    end
  end

  def tst_orthogonal?
    m = MatrixTestUtil::rand_square_sparse()

    # Preconditions
    begin
    end

    orth = m.orthogonal?

    # Post conditions
    begin
      assert_true(m.transpose == m.inverse, orth)
    end
  end

  def tst_tridiagonal
    TestUtil::rand_range(1, 1000, 20).each do |len|
      upper_diagonal = Array.new(len-1)
      upper_diagonal.insert(TestUtil::rand_range(1, 1000, len-1))
      lower_diagonal = Array.new(len-1)
      lower_diagonal.insert(TestUtil::rand_range(1, 1000, len-1))
      diagonal = Array.new(len)
      diagonal.insert(TestUtil::rand_range(1, 1000, len))
      diagonals = Array.[](upper_diagonal, diagonal, lower_diagonal)

      # Preconditions
      begin
        assert(diagonals[1].length == (diagonals[0].length + 1))
        assert(diagonals[1].length == (diagonals[2].length + 1))
      end

      m = SparseMatrix.tridagonal(diagonals)

      # Postconditions
      begin
        assert(m.square?())
        for y in range 0...len
          for x in range 0...len
            if !(x == y || x == y-1 || x == y+1)
              assert(m.at(x,y) == 0)
            end
          end
        end
      end
    end
  end
end