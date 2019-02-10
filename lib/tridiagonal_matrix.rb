# frozen_string_literal: true
require_relative 'sparse_matrix'
require_relative 'tri_diagonal_iterator'

# Tridiagonal Sparse Matrix
class TriDiagonalMatrix < SparseMatrix
  attr_reader(:rows, :cols)

  def initialize(rows, cols = rows)
    raise TypeError unless rows > 2 && cols > 2

    @upper_dia = Array.new(rows-1, 0)
    @main_dia = Array.new(rows, 0)
    @lower_dia = Array.new(rows-1, 0)
    @rows = rows
    @cols = cols
  end

  def det
    prev_det = 1 # det of a 0x0 is 1
    det = @main_dia[0] # det of a 1x1 is the number itself
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

  def nil?
    rows == 0 && cols == 0
  end

  def at(r, c)
    return nil? unless r < @rows && c < @cols

    diag, idx = get_index(r, c)

    return 0 if diag.nil? || diag.length == 0

    diag[idx]
  end

  def put(r, c, val)
    raise "Insertion violates tri-diagonal structure." unless on_band?(r, c)

    resize([r, c].max + 1) unless [r, c].max + 1 <= @rows
    diag, idx = get_index(r, c)
    diag[idx] = val unless diag.nil?
  end

  def resize(size)
    if size > @rows
      size_up!(@main_dia, size)
      size_up!(@lower_dia, size - 1)
      size_up!(@upper_dia, size - 1)
    elsif size < @rows
      size_down!(@main_dia, size)
      size_down!(@lower_dia, size - 1)
      size_down!(@upper_dia, size - 1)
    end
    @rows = @cols = size
    self
  end

  def iterator
    TriDiagonalIterator.new(@lower_dia, @main_dia, @upper_dia)
  end

  private

  def on_band?(r, c)
    (r - c).abs <= 1
  end

  def size_up!(diag, len)
    diag.concat(Array.new(len + 1 - diag.length, 0))
  end

  def size_down!(diag, len)
    diag.slice!(len...diag.length-1) unless len >= diag.length
  end

  # Assumes that (r, c) is inside the matrix boundaries
  def get_index(r, c)
    return [nil, nil] unless on_band?(r, c)

    idx = [r, c].min

    if r == c
      return [@main_dia, idx]
    elsif
      r < c
      return [@upper_dia, idx]
    end
    [@lower_dia, idx]
  end
end
