# frozen_string_literal: true

require_relative 'sparse_matrix'
# Tridiagonal Sparse Matrix
class TriDiagonalMatrix < SparseMatrix
  attr_reader(:rows, :cols)

  def initialize(rows, cols = rows)
    raise TypeError unless rows > 2 && cols > 2

    @upper_dia = []
    @main_dia = []
    @lower_dia = []
    @rows = rows
    @cols = cols
  end

  def det
    # det of a 0x0 is 1
    # det of a 1x1 is the number itself
    prev_det = 1
    det = @main_dia[0]
    index = 1

    while index < @rows
      temp_prev = det
      det = @main_dia[index] * det \
          - @lower_dia[index - 1] * @upper_dia[index - 1] * prev_det
      prev_det = temp_prev
      index += 1
    end

    det
  end
end
