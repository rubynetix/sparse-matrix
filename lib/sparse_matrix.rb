# frozen_string_literal: true

require_relative 'matrix_exceptions'

# Compressed Sparse Row Matrix
class SparseMatrix
  attr_reader(:rows, :cols)

  def initialize(rows, cols = rows)
    raise TypeError unless rows > 0 && cols > 0

    @data = []
    @row_vector = Array.new(rows + 1, 0)
    @col_vector = []
    @rows = rows
    @cols = cols
  end

  class << self
    def zero(rows, cols = rows)
      SparseMatrix.new(rows, cols)
    end

    def identity(n)
      SparseMatrix.new(n).map_diagonal { 1 }
    end

    alias I identity
  end

  def nnz
    @data.size
  end

  def det
    unless square?
      raise MatrixExceptions::DimensionMismatchException, \
            'Matrix must be square'
    end
    unless @data.! empty?
      raise MatrixExceptions::EmptyMatrixException, \
            'Cannot calculate determinate for an empty matrix'
    end

    case @rows # TODO: note "I would much rather not have this switch-case (only bareiss); only kept at it's used in Matrix.rb"
      # Small matrices use Laplacian expansion by minors.
    when 0
      +1
    when 1
      @data[0]
    when 2
      at(0, 0) * at(1, 1) - at(0, 1) * at(1, 0)
    when 3
      determinant_3x3
    when 4
      determinant_4x4
    else
      # Bigger matrices use Gauss-Bareiss algorithm O(n^3)
      Matrix.determinant_bareiss
    end
  end

  def resize(rows, cols)
    raise NotImplementedError, 'Not implemented'
  end

  def set_zero
    raise 'Not implemented'
  end

  def set_identity
    raise 'Not implemented'
  end

  def at(row, col)
    _, val = get_index(row, col)
    return val unless val.nil?

    0
  end

  def sum
    total = 0
    map_nz { |val| total += val }
    total
  end

  def +(other)
    raise 'Not implemented'
  end

  def -(other)
    raise 'Not implemented'
  end

  def *(other)
    raise 'Not implemented'
  end

  def **(other)
    raise 'Not implemented'
  end

  def ==(other)
    raise 'Not implemented'
  end

  def to_s
    raise 'Not implemented'
  end

  def put(row, col, val)
    index, old_val = get_index(row, col)

    unless old_val.nil?
      # Updating an element
      if val == 0
        delete(row, index)
      else
        @data[index] = val
      end
      return
    end

    unless val == 0
      # Inserting a new element
      insert(row, col, index, val)
    end
  end

  def diagonal
    raise 'Not implemented'
  end

  def tridiagonal
    raise 'Not implemented'
  end

  def cofactor(row, col)
    raise 'Not implemented'
  end

  def adjoint
    raise 'Not implemented'
  end

  def inverse
    raise 'Not implemented'
  end

  def rank
    raise 'Not implemented'
  end

  def transpose
    raise 'Not implemented'
  end

  def trace
    raise 'Not implemented'
  end

  def nil?
    raise 'Not implemented'
  end

  def zero?
    raise 'Not implemented'
  end

  def identity?
    raise 'Not implemented'
  end

  def square?
    raise 'Not implemented'
  end

  def positive?
    raise 'Not implemented'
  end

  def invertible?
    raise 'Not implemented'
  end

  def symmetric?
    raise 'Not implemented'
  end

  def traceable?
    raise 'Not implemented'
  end

  def orthogonal?
    raise 'Not implemented'
  end

  def diagonal?
    raise 'Not implemented'
  end

  def lower_triangular?
    raise 'Not implemented'
  end

  def upper_triangular?
    raise 'Not implemented'
  end

  def lower_hessenberg?
    raise 'Not implemented'
  end

  def upper_hessenberg?
    raise 'Not implemented'
  end

  alias t transpose
  alias tr trace

  # Utility functions
  def map
    m = copy
    (0...m.rows - 1).each do |x|
      (0...m.cols - 1).each do |y|
        current = m.at(x, y)
        new_val = yield(current, x, y)
        m.put(x, y, new_val) if new_val != current
      end
    end
    m
  end

  def map_diagonal
    m = copy
    (0...m.rows - 1).each do |x|
      current = m.at(x, x)
      new_val = yield(current, x)
      m.put(x, x, new_val) if new_val != current
    end
    m
  end

  def map_nz
    (0..@rows - 1).each do |r|
      (0..@cols - 1).each do |c|
        yield(at(r, c)) unless at(r, c) == 0
      end
    end
  end

  private

  def plus_matrix(other)
    raise 'Not implemented'
  end

  def plus_scalar(other)
    raise 'Not implemented'
  end

  def mul_matrix(_x)
    raise 'Not implemented'
  end

  def mul_scalar(_x)
    raise 'Not implemented'
  end

  def rref
    raise 'Not implemented'
  end

  # Returns the index of the
  def get_index(row, col)
    row_start = @row_vector[row]
    row_end = @row_vector[row + 1]
    index = row_start

    while (index < row_end) && (col <= @col_vector[index])
      return [index, @data[index]] if @col_vector[index] == col

      index += 1
    end
    [index, nil]
  end

  def insert(row, col, index, val)
    @data.insert(index, val)
    @col_vector.insert(index, col)
    (row + 1..@rows).each do |r|
      @row_vector[r] += 1
    end
  end

  def delete(row, index)
    @data.delete_at(index)
    @col_vector.delete_at(index)
    (row + 1..@rows).each do |r|
      @row_vector[r] -= 1
    end
  end

  def determinant_3x3 # TODO: note "I would much rather not have this function; only kept at it's used in Matrix.rb"
    +at(0, 0) * at(1, 1) * at(2, 2) - at(0, 0) * at(1, 2) * at(2, 1) \
          - at(0, 1) * at(1, 0) * at(2, 2) + at(0, 1) * at(1, 2) * at(2, 0) \
          + at(0, 2) * at(1, 0) * at(2, 1) - at(0, 2) * at(1, 1) * at(2, 0)
  end

  def determinant_4x4 # TODO: note "I would much rather not have this function; only kept at it's used in Matrix.rb"
    +at(0, 0) * at(1, 1) * at(2, 2) * at(3, 3) \
          - at(0, 0) * at(1, 1) * at(2, 3) * at(3, 2) \
          - at(0, 0) * at(1, 2) * at(2, 1) * at(3, 3) \
          + at(0, 0) * at(1, 2) * at(2, 3) * at(3, 1) \
          + at(0, 0) * at(1, 3) * at(2, 1) * at(3, 2) \
          - at(0, 0) * at(1, 3) * at(2, 2) * at(3, 1) \
          - at(0, 1) * at(1, 0) * at(2, 2) * at(3, 3) \
          + at(0, 1) * at(1, 0) * at(2, 3) * at(3, 2) \
          + at(0, 1) * at(1, 2) * at(2, 0) * at(3, 3) \
          - at(0, 1) * at(1, 2) * at(2, 3) * at(3, 0) \
          - at(0, 1) * at(1, 3) * at(2, 0) * at(3, 2) \
          + at(0, 1) * at(1, 3) * at(2, 2) * at(3, 0) \
          + at(0, 2) * at(1, 0) * at(2, 1) * at(3, 3) \
          - at(0, 2) * at(1, 0) * at(2, 3) * at(3, 1) \
          - at(0, 2) * at(1, 1) * at(2, 0) * at(3, 3) \
          + at(0, 2) * at(1, 1) * at(2, 3) * at(3, 0) \
          + at(0, 2) * at(1, 3) * at(2, 0) * at(3, 1) \
          - at(0, 2) * at(1, 3) * at(2, 1) * at(3, 0) \
          - at(0, 3) * at(1, 0) * at(2, 1) * at(3, 2) \
          + at(0, 3) * at(1, 0) * at(2, 2) * at(3, 1) \
          + at(0, 3) * at(1, 1) * at(2, 0) * at(3, 2) \
          - at(0, 3) * at(1, 1) * at(2, 2) * at(3, 0) \
          - at(0, 3) * at(1, 2) * at(2, 0) * at(3, 1) \
          + at(0, 3) * at(1, 2) * at(2, 1) * at(3, 0)
  end

  # TODO: understand? otherwise won't use
  def determinant_bareiss
    raise NotImplementedError
    no_pivot = proc { return 0 }
    sign = +1
    pivot = 1
    @rows.times do |k|
      previous_pivot = pivot
      if (pivot = at(k, k)).zero?
        switch = (k + 1...@rows).find(no_pivot) do |row|
          at(row, k) != 0
        end
        a[switch], a[k] = a[k], a[switch]
        pivot = at(k, k)
        sign = -sign
      end
      (k + 1).upto(@rows - 1) do |i|
        ai = a[i]
        (k + 1).upto(@rows - 1) do |j|
          ai[j] = (pivot * at(i, j) - at(i, k) * at(k, j)) / previous_pivot
        end
      end
    end
    sign * pivot
  end


end
