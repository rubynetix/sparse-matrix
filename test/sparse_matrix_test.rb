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
end