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

  def upper_triangular_matrix(n, l, h)
    # return a upper triangular matrix with n rows and columns
    # with non-zero values in the range l..h
    m = SparseMatrix.new(n, n)
    for y in 0...m.rows
      for x in 0...m.cols
        if (y > x)
          m.insert(x, y, 0)
        else
          if rand(0..1) == 0
            m.insert(x, y, 0)
          else
            m.insert(x, y, rand(l...h))
          end
        end
      end
    end
    m
  end

  def lower_triangular_matrix(n, l, h)
    # return a lower triangular matrix with n rows and columns
    # with non-zero values in the range l..h
    m = SparseMatrix.new(n, n)
    for y in 0...m.rows
      for x in 0...m.cols
        if (x > y)
          m.insert(x, y, 0)
        else
          if rand(0..1) == 0
            m.insert(x, y, 0)
          else
            m.insert(x, y, rand(l...h))
          end
        end
      end
    end
    m
  end

  def upper_hessenberg_matrix(n, l, h)
    # return a upper hessenberg matrix with n rows and columns
    # with non-zero values in the range l..h
    m = SparseMatrix.new(n, n)
    for y in 0...m.rows
      for x in 0...m.cols
        if (y > x + 1)
          m.insert(x, y, 0)
        else
          if rand(0..1) == 0
            m.insert(x, y, 0)
          else
            m.insert(x, y, rand(l...h))
          end
        end
      end
    end
    m
  end

  def lower_hessenberg_matrix(n, l, h)
    # return a lower hessenberg matrix with n rows and columns
    # with non-zero values in the range l..h
    m = SparseMatrix.new(n, n)
    for y in 0...m.rows
      for x in 0...m.cols
        if (x > y + 1)
          m.insert(x, y, 0)
        else
          if rand(0..1) == 0
            m.insert(x, y, 0)
          else
            m.insert(x, y, rand(l...h))
          end
        end
      end
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
      m_tri = TestUtil::lower_triangular_matrix(rc, 0, 1000)
      m_random = TestUtil::rand_matrix(rc, rc)

      # No Preconditions

      # Postconditions
      begin
        assert_equal(sparse_to_matrix(m_tri).lower_triangular?, m_tri.lower_triangular?)
        assert_equal(sparse_to_matrix(m_random).lower_triangular?, m_random.lower_triangular?)
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
      m_tri = TestUtil::upper_triangular_matrix(rc, 0, 1000)
      m_random = TestUtil::rand_matrix(rc, rc)

      # No Preconditions

      # Postconditions
      begin
        assert_equal(sparse_to_matrix(m_tri).upper_triangular?, m_tri.upper_triangular?)
        assert_equal(sparse_to_matrix(m_random).upper_triangular?, m_random.upper_triangular?)
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
      m_hess = TestUtil::lower_hessenberg_matrix(rc, 0, 1000)
      m_random = TestUtil::rand_matrix(rc, rc)
      # No Preconditions

      # Postconditions
      begin
        check_lower_hessenberg(m_hess)
        check_lower_hessenberg(m_random)
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
    for i in 0..10
      rc = rand(0..10000)
      m_hess = TestUtil::upper_hessenberg_matrix(rc, 0, 1000)
      m_random = TestUtil::rand_matrix(rc, rc)
      # No Preconditions

      # Postconditions
      begin
        check_upper_hessenberg(m_hess)
        check_upper_hessenberg(m_random)
      end
    end
  end
end