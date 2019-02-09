require 'test/unit'
require_relative '../lib/sparse_matrix'
require_relative './matrix_test_util'

class MatrixIdentitiesTest < Test::Unit::TestCase
  include MatrixTestUtil

  TEST_ITER = 10
  MAX_ROWS = 100
  MAX_COLS = 100
  MIN_VAL = -100
  MAX_VAL = 100

  def test_addition_identities
    # Verify addition identities hold
    (0..TEST_ITER).each do
      a = rand_square_sparse
      b = rand_sparse(rows: a.rows, cols: a.cols)
      c = rand_sparse(rows: a.rows, cols: a.cols)
      zero = SparseMatrix.zero(a.rows, a.cols)

      # Commutativity
      assert_equal(a + b, b + a, "Commutativity does not hold.")

      # Additive identity
      assert_equal(a + zero, a, "Additive identity does not hold")

      # Additive inverse identities
      assert_equal(a - a, zero, "Additive inverse identity does not hold")
      assert_equal(a - b, a + (b * -1), "Additive inverse identity does not hold")
      assert_equal(a, a * -1 * -1, "Additive inverse identity does not hold")
      assert_equal(zero * -1, zero, "Additive inverse identity does not hold")

      # Negation distribution
      assert_equal((a + b) * -1, (a * -1) + (b * -1), "Negation distribution does not hold")

      # Associativity
      assert_equal((a + b) + c, a + (b + c), "Associativity does not hold")
    end
  end

  def test_multiplication_identities
    # TODO: Uncomment a_inv and uncomment all associated identities once inverse is implemented
    a = rand_square_sparse(size: 5, range: (0..9))
    # a_inv = a.inverse
    b = rand_sparse(rows: a.rows, cols: a.cols)
    c = rand_sparse(rows: a.rows, cols: a.cols)
    i = SparseMatrix.identity(a.rows)

    # Multiplicative identity
    assert_equal(a * i, a, "Multiplicative identity does not hold.")
    assert_equal(i * a, a, "Multiplicative identity does not hold.")

    # Multiplicative inverse identities
    # TODO: Activate with inverse implementation
    # assert_equal(a * a_inv, i, "Multiplicative inverse identity does not hold.")
    # assert_equal(a_inv.inverse, a, "Multiplicative inverse identity does not hold.")
    # assert_equal(i.inverse, i, "Multiplicative inverse identity does not hold.")

    # Grouping identities
    assert_equal(a * (b * c), (a * b) * c, "Grouping identity does not hold.")
    assert_equal(a * (b * -1), (a * b) * -1, "Grouping identity does not hold.")
    assert_equal((a * b) * -1, (a * -1) * b, "Grouping identity does not hold.")
  end
end
