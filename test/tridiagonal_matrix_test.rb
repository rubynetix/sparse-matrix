require_relative '../lib/tridiagonal_matrix_factory'
require_relative 'common/matrix_test_case'

class TridiagonalMatrixTest < Test::Unit::TestCase
  include MatrixTestCase

  def initialize(*args)
    super(*args)
    @factory = TriDiagonalMatrixFactory.new(suppress_warnings: true)
  end

  def assert_invariants(m)
    assert_base_invariants(m)

    assert_true(m.square?, "Tridiagonal matrices should be square")

    return if m.nil?
    # Implementation specific assertions
    upper_dia = m.instance_variable_get(:@upper_dia)
    main_dia = m.instance_variable_get(:@main_dia)
    lower_dia = m.instance_variable_get(:@lower_dia)

    return if main_dia.nil? or upper_dia.nil? or lower_dia.nil?

    assert_equal(m.rows, main_dia.length, "Incorrect length for main diagonal")
    assert_equal(m.rows - 1, upper_dia.length, "Incorrect length for upper diagonal")
    assert_equal(m.rows - 1, lower_dia.length, "Incorrect length for lower diagonal")
  end

  def test_positive?
    pos_m = @factory.random(range: 1..MAX_VAL)
    neg_m = @factory.random(range: MIN_VAL..-1)

    # Preconditions
    begin

    end

    pos = pos_m.positive?
    neg = neg_m.positive?

    if not pos or neg
      puts "Ahhh"
    end

    # Postconditions
    begin
      assert_true(pos, 'Positive matrix declared non-positive')
      assert_false(neg, 'Non-positive matrix declared as positive')
    end

    assert_invariants(pos_m)
    assert_invariants(neg_m)
  end
end
