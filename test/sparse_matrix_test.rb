require 'test/unit'
require_relative '../lib/sparse_matrix'

module TestUtil
  def rand_range(l, h, size)
    i = 0
    a = []
    a.push(rand(l..h)) while i < size
    a
  end

  def self.rand_matrix(rows = 100, cols = rows,
                       scarcity = 0.4, range = (-1000..1000))
    arr = Array.new(rows, Array.new(cols, 0))
    arr.map! { |row| row.map { rand < scarcity ? rand(range) : 0 } }
    print arr, "\n"
  end

  def sparse_to_matrix(s)
    m = Matrix.build(s.rows, s.cols) { |row, col| 0 }
    it = s.iterator
    while s.next?
      e = s.next
      m[e.row][e.col] = e.val
    end
    m
  end

  def iterate_matrix(m)
    (0..m.rows - 1).each do |i|
      (0..m.cols - 1).each do |j|
        yield(i, j, m.at(i, j))
      end
    end
  end

  def char_count(c, s)
    cnt = 0
    s.each_char { |chr| cnt += 1 if c == chr }
    cnt
  end
end

class SparseMatrixTest < Test::Unit::TestCase
  def setup; end

  def teardown; end

  def test_nothing; end

  def tst_identity
    TestUtil.rand_range(1, 10_000, 20).each do |size|
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
        (0..size - 1).each do |i|
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
    r = rand(0..10_000)
    c = rand(1..10_000)
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
    r = rand(1..10_000)
    c = rand(0..10_000)
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
    r = rand(1..10_000)
    c = rand(1..10_000)
    ur = rand(r..10_000)
    uc = rand(c..10_000)
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
    r = rand(2..10_000)
    c = rand(2..10_000)
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
      assert_true(r >= 0 && r <= m.rows - 1)
      assert_true(c >= 0 && c <= m.cols - 1)
    end

    # Postconditions
    begin
      assert_equal(v, m.at(r, c))
    end
  end

  def tst_insert
    v = rand(-1000..1000)
    m = SparseMatrix.new(100, 100)
    r = rand(0..99)
    c = rand(0.99)

    # Preconditions
    begin
      assert_true(r >= 0 && r <= m.rows - 1)
      assert_true(c >= 0 && c <= m.cols - 1)
    end

    nnz_before = m.nnz
    v_before = v.at(r, c)
    m.insert(r, c, v)

    # Postconditions
    begin
      # Check that the value is set
      assert_equal(v, m.at(r, c))

      if ((v != 0) && (v_before != 0)) || ((v == 0) && (v_before == 0))  # TODO: note ruby objects have val.nil? and val.zero? methods
        assert_equal(nnz_before, m.nnz)
      elsif (v != 0) && (v_before == 0)
        assert_equal(nnz_before + 1, m.nnz)
      else # v == 0 and v_before != 0
        assert_equal(nnz_before - 1, m.nnz)
      end
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

  def tst_diagonal?
    m = TestUtil.rand_matrix

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
        iterate_matrix(m) do |i, j, v|
          assert_equal(0, v) unless i == j
        end
      else
        # For some i,j where i != j -> at(i,j) != 0
        assert_true(nnz_off_diagonal?(m))
      end
    end
  end

  def tst_diagonal
    m = TestUtil.rand_matrix

    # Preconditions
    begin
      assert_true(square?)
    end

    md = m.diagonal

    # Postconditions
    begin
      assert_true(m.diagonal?)

      # All elements on the diagonal are equivalent to the original matrix
      (0..m.rows - 1).each do |i|
        assert_equal(m.at(i, i), md.at(i, i))
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
          assert_equal(0, TestUtil::char_count('\n', s))
        else
          # number of \n == rows()
          assert_equal(m.rows, TestUtil::char_count('\n', s))
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

  def tst_transpose
    m = TestUtil::rand_matrix

    # Preconditions
    begin
    end

    mt = m.transpose

    # Postconditions
    begin
      assert_equal(m.rows, mt.cols)
      assert_equal(m.cols, mt.rows)
      assert_equal(m.sum, mt.sum)
      TestUtil::iterate_matrix(mt) { |i, j, v| assert_equal(m.at(j, i), v) }
      assert_true(mt.transpose == m)
    end
  end

  def tst_zero?
    ms = [
        TestUtil::rand_matrix,
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

    m = TestUtil::rand_matrix

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
        assert_equal(TestUtil::sparse_to_matrix(m).rank, r)
        assert_equal(r, m.transpose.rank)
      end
    end
  end
end
