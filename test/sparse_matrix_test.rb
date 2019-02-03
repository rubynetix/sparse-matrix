require 'test/unit'
require_relative '../lib/sparse_matrix'

module TestUtil
  def rand_range(l, h, size)
    i = 0
    a = []
    while i < size
      a.push(rand(l..h))
    end
    a
  end

  def sparse_to_matrix(s)
    m = Matrix.build(s.rows, s.cols) {|row, col| 0}
    it = s.iterator
    while s.next?
      e = s.next
      m[e.row][e.col] = e.val
    end
    m
  end
end

class SparseMatrixTest < Test::Unit::TestCase

  def setup
  end

  def teardown
  end

  def test_nothing
  end

  def tst_identity
    TestUtil::rand_range(1, 10000, 20).each do |size|
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
    r = rand(0..10000)
    c = rand(1..10000)
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
    r = rand(1..10000)
    c = rand(0..10000)
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

  def tst_resize_up
    r = rand(1..10000)
    c = rand(1..10000)
    ur = rand(r..10000)
    uc = rand(c..10000)
    m = SparseMatrix.new(r, c)
    nnzi = m.nnz

    # Upsize test

    # Preconditions
    begin
      assert_equal(r, m.rows)
      assert_equal(c, m.cols)
      assert_true(ur >= r)
      assert_true(uc >= c)
    end

    m.resize(ur, uc)

    # Postconditions
    begin
      assert_equal(ur, m.rows)
      assert_equal(uc, m.cols)
      assert_equal(nnzi, m.nnz)
    end
  end

  def tst_resize_down
    r = rand(2..10000)
    c = rand(2..10000)
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

  def tst_at
    v = rand(-1000..1000)
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

end