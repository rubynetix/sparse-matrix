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

  def tst_lower_triangular_nonsquare
    r = 0
    c = 0
    while r != c
      r = rand(0..10000)
      c = rand(0..10000)
      m = rand_matrix(r, c)
    end

      # No Preconditions

      # Postconditions
      begin
        assert_equal(sparse_to_matrix(m).lower_triangular?, m.lower_triangular?)
      end
    end
  end

  def tst_lower_triangular_square
    for i in 0..20
      rc = rand(0..10000)
      m = rand_matrix(rc, rc)

      # No Preconditions

      # Postconditions
      begin
        assert_equal(sparse_to_matrix(m).lower_triangular?, m.lower_triangular?)
      end
    end
  end

  def tst_upper_triangular_nonsquare
    r = 0
    c = 0
    while r != c
      r = rand(0..10000)
      c = rand(0..10000)
      m = rand_matrix(r, c)
    end

    # No Preconditions

    # Postconditions
    begin
      assert_equal(sparse_to_matrix(m).upper_triangular?, m.upper_triangular?)
    end
  end

  def tst_upper_triangular_square
    for i in 0..20
      rc = rand(0..10000)
      m = rand_matrix(rc, rc)

      # No Preconditions

      # Postconditions
      begin
        assert_equal(sparse_to_matrix(m).upper_triangular?, m.upper_triangular?)
      end
    end
  end

  def check_lower_hessenberg(m)
    # algorithm to test if matrix m is lower_hessenberg
    if !m.square?
      assert(!m.lower_hessenberg?)
    else
      for y in 0...m.rows
        for x in 0...m.cols
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
      m = rand_matrix(r, c)
    end
      # No Preconditions

      # Postconditions
    begin
      check_lower_hessenberg(m)
    end
  end

  def tst_lower_hessenberg_square
    # tests lower_hessenberg with a square matrix
    for i in 0..20
      rc = rand(0..10000)
      m = rand_matrix(rc, cc)
      # No Preconditions

      # Postconditions
      begin
        check_lower_hessenberg(m)
      end
    end
  end

  def check_upper_hessenberg(m)
    # algorithm to test if matrix m is upper_hessenberg
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
      r = rand(0..10000)
      c = rand(0..10000)
      m = rand_matrix(r, c)
    end
      # No Preconditions

      # Postconditions
    begin
      check_upper_hessenberg(m)
    end
  end

  def tst_upper_hessenberg_square
    # tests upper_hessenberg with a square matrix
    for i in 0..20
      rc = rand(0..10000)
      m = rand_matrix(rc, cc)
      # No Preconditions

      # Postconditions
      begin
        check_upper_hessenberg(m)
      end
    end
  end
end