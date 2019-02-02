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

  # TODO: Implement function
  def rand_matrix(r, c)
    # return r x c matrix with random values.
  end

  def sparse_to_matrix(s):
    #TODO: Implement
    # Returns a regular Ruby matrix equivalent to Sparse Matrix s
  end
end

class SparseMatrixTest < Test::Unit::TestCase

  def setup
  end

  def teardown
  end

  def test_nothing
  end

  def tst_*
    r = rand(0..10000)
    c = rand(1..10000)
    m = rand_matrix(r, c)
    TestUtil::rand_range(1, 1000, 20).each do |mult|
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

  def tst_**
    r = rand(0..10000)
    c = rand(1..10000)
    m = rand_matrix(r, c)
    TestUtil::rand_range(1, 1000, 20).each do |exp|
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

  def tst_lower_triangular
    r = rand(0..10000)
    c = rand(1..10000)
    m = rand_matrix(r, c)
    for i in 0..20
      # No Preconditions

      expected = sparse_to_matrix(s).lower_triangular?

      # Postconditions
      begin
        assert_equal(expected, m.lower_triangular?)
      end
    end
  end

  def tst_upper_triangular
    r = rand(0..10000)
    c = rand(1..10000)
    m = rand_matrix(r, c)
    for i in 0..20
      # No Preconditions

      expected = sparse_to_matrix(s).upper_triangular?

      # Postconditions
      begin
        assert_equal(expected, m.upper_triangular?)
      end
    end
  end
end