require_relative '../../lib/sparse_matrix'
require_relative 'test_helper_matrix_util'

module MatrixIdentitiesTestCase
  include MatrixTestUtil

  TEST_ITER = 100
  MAX_ROWS = 10
  MAX_COLS = 10
  MIN_VAL = -10
  MAX_VAL = 10

  def generate_matrices
    @a = @factory.random_square(size: rand(2..MAX_ROWS))
    @a_t =  @a.transpose
    # @a_inv = @a.inverse

    @b = @factory.random_square(size: @a.rows)
    @b_t = @b.transpose
    # @b_inv = @b.inverse

    @c = @factory.random_square(size: @a.rows)
    @c_t = @c.transpose
    # @c_inv = @c.inverse

    @d = @factory.random_square(size: @a.rows)
    @d_t = @d.transpose

    @zero = @factory.zero(@a.rows)
    @i = @factory.identity(@a.rows)
  end

  def generate_invertible_matrices
    @a = invertible_sparse_matrix(@factory, rand(2..MAX_ROWS), MIN_VAL, MAX_VAL)
    @a_t =  @a.transpose
    @a_inv = @a.inverse

    @b = invertible_sparse_matrix(@factory, @a.rows, MIN_VAL, MAX_VAL)
    @b_t = @b.transpose
    @b_inv = @b.inverse

    @c = invertible_sparse_matrix(@factory, @a.rows, MIN_VAL, MAX_VAL)
    @c_t = @c.transpose
    @c_inv = @c.inverse

    @d = invertible_sparse_matrix(@factory, @a.rows, MIN_VAL, MAX_VAL)
    @d_t = @d.transpose

    @zero = @factory.zero(@a.rows)
    @i = @factory.identity(@a.rows)
  end

  def test_addition_identities
    # Verify addition identities hold
    (0..TEST_ITER).each do
      generate_matrices

      # Commutativity
      assert_equal(@a + @b, @b + @a, "Commutativity does not hold.")

      # Additive identity
      assert_equal(@a + @zero, @a, "Additive identity does not hold")

      # Additive inverse identities
      assert_equal(@a - @a, @zero, "Additive inverse identity does not hold")
      assert_equal(@a - @b, @a + (@b * -1), "Additive inverse identity does not hold")
      assert_equal(@a, @a * -1 * -1, "Additive inverse identity does not hold")
      assert_equal(@zero * -1, @zero, "Additive inverse identity does not hold")

      # Negation distribution
      assert_equal((@a + @b) * -1, (@a * -1) + (@b * -1), "Negation distribution does not hold")

      # Associativity
      assert_equal((@a + @b) + @c, @a + (@b + @c), "Associativity does not hold")
    end
  end

  def test_multiplication_identities
    # Verify multiplication identities hold
    (0..TEST_ITER).each do
      generate_matrices

      # Multiplicative identity
      assert_equal(@a * @i, @a, "Multiplicative identity does not hold.")
      assert_equal(@i * @a, @a, "Multiplicative identity does not hold.")

      # Grouping identities
      assert_equal(@a * (@b * @c), (@a * @b) * @c, "Grouping identity does not hold.")
      assert_equal(@a * (@b * -1), (@a * @b) * -1, "Grouping identity does not hold.")
      assert_equal((@a * @b) * -1, (@a * -1) * @b, "Grouping identity does not hold.")

      # Multiplicative inverse identities
      # TODO: Activate assertions with inverse implementation
      generate_invertible_matrices
      assert_equal(@a * @a_inv, @i, "Multiplicative inverse identity does not hold.")
      assert_equal(@a_inv.inverse, @a, "Multiplicative inverse identity does not hold.")
      assert_equal(@i.inverse, @i, "Multiplicative inverse identity does not hold.")
    end
  end

  def test_joint_identities
    # Verify joint identities hold
    (0..TEST_ITER).each do
      generate_matrices

      # Multiplication distributes over addition
      assert_equal(@a * (@c + @d), (@a * @c) + (@a * @d), "Multiplication does not distribute over addition.")
      assert_equal((@c + @d) * @a, (@c * @a) + (@d * @a), "Multiplication does not distribute over addition.")

      # Inverse distributes over multiplication
      # TODO: Activate assertions with inverse implementation
      generate_invertible_matrices
      assert_equal(@a_inv * -1, (@a * -1).inverse, "Inverse does not distribute over multiplication.")
      assert_equal((@a * @b).inverse, @b_inv * @a_inv, "Inverse does not distribute over multiplication.")
    end
  end

  def test_transpose_identities
    # Verify transpose identities hold
    (0..TEST_ITER).each do
      generate_matrices

      # Transpose of transpose
      assert_equal(@a, @a_t.transpose, "Transpose identity does not hold.")
      assert_equal(@zero.transpose, @zero, "Transpose of zero matrix identity does not hold.")
      assert_equal(@i.transpose, @i, "Transpose of identity matrix identity does not hold.")

      # Transpose distributes over addition
      assert_equal((@a + @b).transpose, @a_t + @b_t,"Transpose does not distribute over addition.")

      # Transpose distributes over multiplication
      assert_equal((@a * @b).transpose, @b_t * @a_t,"Transpose does not distribute over multiplication.")
      assert_equal((@a * @b * @c).transpose, @c_t * @b_t * @a_t,"Transpose does not distribute over multiplication.")
    end
  end

  # TODO: Activate test with inverse implementation
  def test_symmetric_identities
    # Verify symmetric identities hold
    (0..TEST_ITER).each do
      generate_matrices

      if @b.symmetric?
        assert_true((@a_t * @b * @a).symmetric?, "Symmetric identity does not hold.")
        assert_true((@a * @b * @a_t).symmetric?, "Symmetric identity does not hold.")
      end

      assert_true((@a_t * @a).symmetric?,"Symmetric identity does not hold.")
      assert_true((@a * @a_t).symmetric?,"Symmetric identity does not hold.")
      assert_true((@a * @a_t).symmetric?,"Symmetric identity does not hold.")

      generate_invertible_matrices
      assert_equal(@a_inv.symmetric?, @a.symmetric?, "Symmetric identity does not hold.")
    end
  end

  # TODO: Activate test with inverse implementation
  def test_general_matrix_identities
    # Verify more general matrix identities hold.
    #
    # Identities and derivations, courtesy of Dr. Miller, can be found at:
    # https://eclass.srv.ualberta.ca/mod/forum/discuss.php?d=1126341
    generate_invertible_matrices
    assert_equal(@a + @b, @a * (@a_inv + @b_inv) * @b)
    assert_equal(@i + @a, (@i + @a_inv) * @a)
    assert_equal(@a_inv + @b_inv, @a_inv * (@a + @b) * @b_inv)
    assert_equal(@i + @a_inv, (@i + @a) * @a_inv)
    assert_equal((@i + (@a_inv * @b)).inverse, (@a + @b).inverse * @a)
    assert_equal((@i + (@a * @b)).inverse, (@a_inv + @b).inverse * @a_inv)
    assert_equal(@a + @b_inv, @a * (@a_inv + @b) * @b_inv)
    assert_equal(@a - @b, (@a * -1) * (@a_inv - @b_inv) * @b)
    assert_equal((@a * @b) + (@b * @c), @a * ((@a_inv * @b) + (@b * @c_inv)) * @c)
    assert_equal(@a + (@a * @b), (@a + (@a * @b_inv)) * @b)
    assert_equal((@a + @b).inverse, @a_inv * (@a_inv + @b_inv).inverse * @b_inv)
    assert_equal((@a_inv + @b_inv).inverse, @a * (@a + @b).inverse * @b)
    assert_equal((@i + @a_inv).inverse, (@i + @a).inverse * @a)
    assert_equal((@a + @b).inverse, @a_inv * (@a_inv + @b_inv).inverse * @b_inv)
    assert_equal((@i + @a).inverse, @a * (@i + @a).inverse * @a_inv)
    assert_equal((@i - @a).inverse, @a * (@i - @a).inverse * @a_inv)
    assert_equal(@b * (@i + (@a * @b)).inverse, @a_inv * (@i + (@a * @b)).inverse * (@a * @b))
    assert_equal((@i + (@a * @b)).inverse * @a, @a * @b * (@i + (@a * @b)).inverse * @b_inv)
    assert_equal(@a - (@a * (@b_inv * @a)), @a * (@a_inv - @b_inv) * @a)
    assert_equal(@a * (@a_inv + @b_inv), (@a + @b)* @b_inv)
    assert_equal(@a * (@a_inv + @b), (@a + @b_inv) * @b)
    assert_equal(@a * (@a + @b).inverse, (@a_inv + @b_inv).inverse * @b_inv)
    assert_equal(@a_inv * (@a + @b), (@a_inv + @b_inv) * @b)
    assert_equal((@a + @b) * @b_inv, @a * (@a_inv + @b_inv))
    assert_equal((@a * @b_inv) + @i, @a * (@a_inv + @b_inv))
    assert_equal(@a + @b + (@a * (@c * @b)), @a * (@a_inv + @b_inv + @c) * @b)
  end
end