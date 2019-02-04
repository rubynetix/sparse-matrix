require 'test/unit'
require_relative '../lib/sparse_matrix'

module MatrixTestUtil
  def rand_sparse(rows: rand(1..1000), cols: rand(1..1000), range: (-1000..1000))
    # TODO: Implementation
  end

  def rand_square_sparse(size: 1000, range: -1000..1000)
    rand_sparse(rows: size, cols: size, range: range)
  end

  def null_matrix
    # TODO: Implementation
  end

  def identity_matrix(size: rand(1..1000))
    # TODO: Implementation
  end
end

class MatrixTest < Test::Unit::TestCase
  @@MAX_ROWS = 10_000
  @@MAX_COLS = 10_000
  @@MIN_VAL = -10_000
  @@MAX_VAL = 10_000

  def setup; end

  def teardown; end

  def tst_set_zero
    m = MatrixTestUtil.rand_sparse

    # Preconditions
    # N/A

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
    m = MatrixTestUtil.rand_sparse

    # Preconditions
    # N/A

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

  def tst_identity?
    i = MatrixTestUtil.identity_matrix
    m = MatrixTestUtil.rand_square_sparse

    # Preconditions
    # N/A

    identity = i.identity?
    non_identity = m.identity?

    # Posconditions
    begin
      assert_true(identity)
      assert_false(non_identity)
    end
  end

  def tst_clone
    m1 = MatrixTestUtil.rand_sparse

    # Preconditions
    # N/A

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

  def tst_sum
    m = MatrixTestUtil.rand_sparse

    # Preconditions
    # N/A

    sum = m.sum

    # Postconditions
    begin
      it = m.iterator
      expected = 0

      while it.has_next?
        el = it.next
        expected += el.val
      end

      assert_equal(expected, sum)
    end
  end

  def tst_add_scalar
    m1 = MatrixTestUtil.rand_sparse
    num = rand(@@MIN_VAL..@@MAX_VAL)

    # Preconditions
    # N/A

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

  def tst_subtract_scalar
    m1 = MatrixTestUtil.rand_sparse
    num = rand(@@MIN_VAL..@@MAX_VAL)

    # Preconditions
    # N/A

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

  def tst_add_matrix
    r = rand(1..@@MAX_ROWS)
    c = rand(1..@@MAX_COLS)
    m1 = MatrixTestUtil.rand_sparse(rows: r, cols: c)
    m2 = MatrixTestUtil.rand_sparse(rows: r, cols: c)

    # Preconditions
    begin
      assert_equal(m1.rows, m2.rows)
      assert_equal(m1.cols, m2.cols)
    end

    m3 = m1 + m2

    # Postconditions
    begin
      assert_equal(m1.sum + m2.sum, m3.sum)

      assert_equal(m1.trace + m2.trace, m3.trace) if m1.traceable?

      assert_equal(m1, m3 - m2)

      (0..m1.rows).each do |r|
        (0..m1.cols).each do |c|
          assert_equal(m1.at(r, c) + m2.at(r, c), m3.at(r, c))
        end
      end
    end
  end

  def tst_subtract_matrix
    r = rand(1..@@MAX_ROWS)
    c = rand(1..@@MAX_COLS)
    m1 = MatrixTestUtil.rand_sparse(rows: r, cols: c)
    m2 = MatrixTestUtil.rand_sparse(rows: r, cols: c)

    # Preconditions
    begin
      assert_equal(m1.rows, m2.rows)
      assert_equal(m1.cols, m2.cols)
    end

    m3 = m1 - m2

    # Postcondition
    begin
      assert_equal(m1.sum - m2.sum, m3.sum)

      assert_equal(m1.trace - m2.trace, m3.trace) if m1.traceable?

      assert_equal(m1, m3 + m2)

      (0..m1.rows).each do |r|
        (0..m1.cols).each do |c|
          assert_equal(m1.at(r, c) - m2.at(r, c), m3.at(r, c))
        end
      end
    end
  end

  def tst_null
    sparse_m = MatrixTestUtil.rand_sparse
    null_m = MatrixTestUtil.null_matrix

    # Preconditions
    # N/A

    non_null = sparse_m.null?
    null = null_m.null?

    # Postconditions
    begin
      assert_false(non_null)
      assert_true(null)
    end
  end

  def tst_invertible
    m = MatrixTestUtil.rand_sparse

    # Preconditions
    # N/A

    inv = m.invertible?

    # Postconditions
    begin
      assert_equal(m.square? && m.det != 0, inv)
    end
  end

  def tst_inverse
    m = MatrixTestUtil.rand_square_sparse

    # Preconditions
    begin
      m.invertible?
    end

    inv = m.inverse

    # Postconditions
    begin
      assert_equal(m * inv, SparseMatrix.identity(m.rows))
    end
  end

  def tst_positive
    pos_m = MatrixTestUtil.rand_sparse(range: 0..@@MAX_VAL)
    neg_m = MatrixTestUtil.rand_sparse(range: @@MIN_VAL..-1)

    # Preconditions
    # N/A

    pos = pos_m.positive?
    neg = neg_m.positive?

    # Postconditions
    begin
      assert_true(pos)
      assert_false(neg)
    end
  end

  def tst_square
    m = MatrixTestUtil.rand_sparse

    # Preconditions
    # N/A

    sq = m.square?

    # Postconditions
    begin
      assert_equal(m.rows == m.cols, sq)
    end
  end

  def tst_symmetric
    m = MatrixTestUtil.rand_sparse

    # Preconditions
    # N/A

    sym = m.symmetric?

    # Postconditions
    begin
      assert_equal(m == m.transpose, sym)
    end
  end

  def tst_traceable
    m = MatrixTestUtil.rand_sparse

    # Preconditions
    # N/A

    tr = m.traceable?

    # Postconditions
    begin
      assert_equal(m.square?, tr)
    end
  end

  def tst_trace
    m = MatrixTestUtil.rand_sparse

    # Preconditions
    begin
      m.traceable?
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

  def tst_cofactor
    m = MatrixTestUtil.rand_sparse

    # Preconditions
    # N/A

    cof_row = rand(0..m.rows)
    cof_col = rand(0..m.cols)

    cof = m.cofactor(cof_row, cof_col)

    # Postconditions
    begin
      if m.cols == 1 || m.rows == 1
        assert_true(cof.null?)
      else
        cof.cols = m.cols - 1
        cof.rows = m.rows - 1

        # TODO: Check the actual values of the cofactor matrix
      end
    end
  end

  def tst_adjoint
    m = MatrixTestUtil.rand_square_sparse

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

  def tst_orthogonal
    m = MatrixTestUtil.rand_square_sparse

    # Preconditions
    # N/A

    orth = m.orthogonal?

    # Posconditions
    begin
      assert_true(m.transpose == m.inverse, orth)
    end
  end
end
