require 'test/unit'
require_relative '../lib/sparse_matrix'

module TestUtil
  def rand_range(l, h, size)
    i = 0
    a = []
    a.push(rand(l..h)) while i < size
    a
  end

  # TODO: Implement function
  def rand_matrix(r, c)
    # return r x c matrix with random values.
  end

  def sparse_to_matrix(s)
    # TODO: Implement
    # Returns a regular Ruby matrix equivalent to Sparse Matrix s
  end

  def upper_triangular_matrix(n, l, h)
    # return a upper triangular matrix with n rows and columns
    # with non-zero values in the range l..h
    m = SparseMatrix.new(n, n)
    (0...m.rows).each do |y|
      (0...m.cols).each do |x|
        if y > x
          m.insert(x, y, 0)
        else
          rand(0..1) == 0 ? m.insert(x, y, 0) : m.insert(x, y, rand(l...h))
        end
      end
    end
    m
  end

  def lower_triangular_matrix(n, l, h)
    # return a lower triangular matrix with n rows and columns
    # with non-zero values in the range l..h
    m = SparseMatrix.new(n, n)
    (0...m.rows).each do |y|
      (0...m.cols).each do |x|
        if x > y
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
    (0...m.rows).each do |y|
      (0...m.cols).each do |x|
        if y > x + 1
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
    (0...m.rows).each do |y|
      (0...m.cols).each do |x|
        if x > y + 1
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
  def setup; end

  def teardown; end

  def test_nothing; end

  def assert_invariants(m)
    assert(m.rows() >= 0)
    assert(m.cols() >= 0)
    if m.cols() > 0
      assert(m.rows() > 0)
    end
    if m.rows() > 0
      assert(m.cols() > 0)
    end
    if m.rows() == 0
      assert(m.cols() == 0)
    end
    if m.cols() == 0
      assert(m.rows() == 0)
    end
  end
  
  def tst_scalar_mult
    r = rand(0..10_000)
    c = rand(1..10_000)
    m = TestUtil.rand_matrix(r, c)
    TestUtil.rand_range(1, 1000, 20).each do |mult|
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
        assert_invariants(new_m)
      end
    end
  end

  def tst_exponentiation
    r = rand(0..10_000)
    c = rand(1..10_000)
    m = TestUtil.rand_matrix(r, c)
    TestUtil.rand_range(1, 1000, 20).each do |exp|
      # Preconditions
      begin
      end

      new_m = m.**(exp)

      # Postconditions
      begin
        expected = m
        (0..exp).each do |_i|
          expected *= m
          assert_equal(expected, new_m)
        end
        assert_invariants(new_m)
      end
    end
  end

  def tst_lower_triangular_nonsquare
    r = 0
    c = 0
    while r != c
      r = rand(0..10_000)
      c = rand(0..10_000)
      m = TestUtil.rand_matrix(r, c)
    end

    # No Preconditions

    # Postconditions
    begin
      assert_equal(TestUtil::sparse_to_matrix(m).lower_triangular?, m.lower_triangular?)
      assert_invariants(m)
    end
  end

  def tst_lower_triangular_square
    i = 0
    while i < 20
      rc = rand(0..10_000)
      m_tri = TestUtil.lower_triangular_matrix(rc, 0, 1000)
      m_random = TestUtil.rand_matrix(rc, rc)

      # No Preconditions

      # Postconditions
      begin
        assert_equal(TestUtil::sparse_to_matrix(m_tri).lower_triangular?, m_tri.lower_triangular?)
        assert_equal(TestUtil::sparse_to_matrix(m_random).lower_triangular?, m_random.lower_triangular?)
        assert_invariants(m_tri)
        assert_invariants(m_random)
      end
      i += 1
    end
  end

  def tst_upper_triangular_nonsquare
    r = 0
    c = 0
    while r != c
      r = rand(0..10_000)
      c = rand(0..10_000)
      m = TestUtil.rand_matrix(r, c)
    end

    # No Preconditions

    # Postconditions
    begin
      assert_equal(TestUtil::sparse_to_matrix(m).upper_triangular?, m.upper_triangular?)
      assert_invariants(m)
    end
  end

  def tst_upper_triangular_square
    i = 0
    while i < 20
      rc = rand(0..10_000)
      m_tri = TestUtil.upper_triangular_matrix(rc, 0, 1000)
      m_random = TestUtil.rand_matrix(rc, rc)

      # No Preconditions

      # Postconditions
      begin
        assert_equal(TestUtil::sparse_to_matrix(m_tri).upper_triangular?, m_tri.upper_triangular?)
        assert_equal(TestUtil::sparse_to_matrix(m_random).upper_triangular?, m_random.upper_triangular?)
        assert_invariants(m_tri)
        assert_invariants(m_random)
      end
      i += 1
    end
  end

  def check_lower_hessenberg(m)
    # algorithm to test if matrix m is lower_hessenberg
    if !m.square?
      assert(!m.lower_hessenberg?)
    else
      (0...m.rows).each do |y|
        (0...m.cols).each do |x|
          assert_equal(0, m.at(x, y)) if x > y + 1
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
      m = TestUtil.rand_matrix(r, c)
    end
    # No Preconditions

    # Postconditions
    begin
      check_lower_hessenberg(m)
      assert_invariants(m)
    end
  end

  def tst_lower_hessenberg_square
    # tests lower_hessenberg with a square matrix
    i = 0
    while i < 20
      rc = rand(0..10_000)
      m_hess = TestUtil.lower_hessenberg_matrix(rc, 0, 1000)
      m_random = TestUtil.rand_matrix(rc, rc)
      # No Preconditions

      # Postconditions
      begin
        check_lower_hessenberg(m_hess)
        check_lower_hessenberg(m_random)
        assert_invariants(m_hess)
        assert_invariants(m_random)
      end
      i += 1
    end
  end

  def check_upper_hessenberg(m)
    # algorithm to test matrix m is upper_hessenberg
    if !m.square?
      assert(!m.upper_hessenberg?)
    else
      (0...m.rows).each do |y|
        (0...m.cols).each do |x|
          assert_equal(0, m.at(x, y)) if y > x + 1
        end
      end
    end
  end

  def tst_upper_hessenberg_nonsquare
    # tests upper_hessenberg? with a nonsquare matrix
    r = 0
    c = 0
    while r != c
      r = rand(0..10_000)
      c = rand(0..10_000)
      m = TestUtil.rand_matrix(r, c)
    end
    # No Preconditions

    # Postconditions
    begin
      check_upper_hessenberg(m)
      assert_invariants(m)
    end
  end

  def tst_upper_hessenberg_square
    # tests upper_hessenberg with a square matrix
    i = 0
    while i < 10
      rc = rand(0..10_000)
      m_hess = TestUtil.upper_hessenberg_matrix(rc, 0, 1000)
      m_random = TestUtil.rand_matrix(rc, rc)
      # No Preconditions

      # Postconditions
      begin
        check_upper_hessenberg(m_hess)
        check_upper_hessenberg(m_random)
        assert_invariants(m_hess)
        assert_invariants(m_random)
      end
      i += 1
    end
  end

  def tst_equals
    r1 = 0
    r2 = 0
    while r1 != r2
      r1 = rand(0..10_000)
      r2 = rand(0..10_000)
    end
    m = TestUtil.rand_matrix(r1, rand(0..10_000))
    m_same = m.clone
    m_diff = TestUtil.rand_matrix(r2, rand(0..10_000))

    # Preconditions
    begin
      assert(m_same.rows >= 0)
      assert(m_same.cols >= 0)
      assert(m_diff.rows >= 0)
      assert(m_diff.cols >= 0)
    end

    # Postconditions
    begin
      assert(m.==(m_same))
      assert(!m.==(m_diff))
      assert_invariants(m)
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
        assert_invariants(m)
      end
    end
  end
end
