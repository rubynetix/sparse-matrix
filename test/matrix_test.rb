require 'test/unit'
require_relative '../lib/sparse_matrix'

module MatrixTestUtil
  def rand_matrix(rows, cols, low, high)
    # TODO: Implementation
  end
end

class MatrixTest < Test::Unit::TestCase

  @@MAX_ROWS = 10000
  @@MAX_COLS = 10000
  @@MIN_VAL = -10000
  @@MAX_VAL = 10000

  def setup
  end

  def teardown
  end

  def tst_set_zero
    # Preconditions
    # N/A

    m = MatrixTestUtil::rand_matrix(rand(1..@@MAX_ROWS), rand(1..@@MAX_COLS), @@MIN_VAL, @@MAX_VAL)
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
    # Preconditions
    # N/A

    m = MatrixTestUtil::rand_matrix(rand(1..@@MAX_ROWS), rand(1..@@MAX_COLS), @@MIN_VAL, @@MAX_VAL)
    m.set_zero

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

  def tst_clone
    # Preconditions
    # N/A

    m1 = MatrixTestUtil::rand_matrix(rand(1..@@MAX_ROWS), rand(1..@@MAX_COLS), @@MIN_VAL, @@MAX_VAL)
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
    # Preconditions
    # N/A

    m = MatrixTestUtil::rand_matrix(rand(1..@@MAX_ROWS), rand(1..@@MAX_COLS), @@MIN_VAL, @@MAX_VAL)
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

  def tst_add
    # Preconditions
    # N/A

    m1 = MatrixTestUtil::rand_matrix(rand(1..@@MAX_ROWS), rand(1..@@MAX_COLS), @@MIN_VAL, @@MAX_VAL)
    m2 = m1.clone
    num = rand(@@MIN_VAL..@@MAX_VAL)
    m + num

    # Postconditions
    begin
      assert_equal(m1.sum, m2.sum + num*m2.nnz)

      (0..m1.rows).each do |r|
        (0..m1.cols).each do |c|
          assert_equal(m1.at(r, c), m2.at(r, c) + num)
        end
      end
    end
  end

  def tst_subtract
    # Preconditions
    # N/A

    m1 = MatrixTestUtil::rand_matrix(rand(1..@@MAX_ROWS), rand(1..@@MAX_COLS), @@MIN_VAL, @@MAX_VAL)
    m2 = m1.clone
    num = rand(@@MIN_VAL..@@MAX_VAL)
    m1 - num

    # Postconditions
    begin
      assert_equal(m1.sum, m2.sum - num*m2.nnz)

      (0..m1.rows).each do |r|
        (0..m1.cols).each do |c|
          assert_equal(m1.at(r, c), m2.at(r, c) - num)
        end
      end
    end
  end
end