# frozen_string_literal: true

require_relative 'csr_iterator'

require_relative 'matrix_exceptions'

# Compressed Sparse Row Matrix
class SparseMatrix
  attr_reader(:rows, :cols)

  def initialize(rows, cols = rows)
    raise TypeError unless rows.positive? && cols.positive?

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

  def set_zero
    @data = []
    @row_vector = Array.new(rows + 1, 0)
    @col_vector = []
  end

  def set_identity
    set_zero
    map_diagonal_nocopy { 1 }
  end

  def resize(_rows, _cols)
    raise 'Not implemented'
  end

  def at(row, col)
    _, val = get_index(row, col)
    return val unless val.nil?

    0
  end

  def put(row, col, val)
    index, old_val = get_index(row, col)

    unless old_val.nil?
      # Updating an element
      if val.zero?
        delete(row, index)
      else
        @data[index] = val
      end
      return
    end

    unless val.zero?
      # Inserting a new element
      insert(row, col, index, val)
    end
  end

  def copy
    c = SparseMatrix.new(rows, cols)
    c.data = @data
    c.row_vector = @row_vector
    c.col_vector = @col_vector
  end

  def +(_other)
    raise 'Not implemented'
  end

  def -(_other)
    raise 'Not implemented'
  end

  def *(_other)
    raise 'Not implemented'
  end

  def **(_other)
    raise 'Not implemented'
  end

  def ==(_other)
    raise 'Not implemented'
  end

  def to_s
    s = ''
    (0..@rows - 1).each do |r|
      (0..@cols - 1).each do |c|
        s += "#{at(r, c)} "
      end
      s += "\n"
    end
    s
  end

  def empty_row?
    prev_cnt = @rows[0]
    (1..@rows - 1).each do |cnt|
      return 1 if cnt == prev_cnt

      prev_cnt = cnt
    end
    0
  end

  def empty_col?
    @col_vector.to_set.length == @cols
  end

  def det
    return 0 if empty_row? || empty_col?

    case @rows
    when 0
      +1
    when 1
      at(0, 0)
    when 2
      at(0, 0) * at(1, 1) - at(0, 1) * at(1, 0)
    else
      determinant_simple
    end
  end

  def sum
    total = 0
    map_nz_nocopy { |val| total += val }
    total
  end

  def diagonal
    throw RuntimeError unless square?
    diag = Array.new(@rows, 0)
    iter = iterator
    while iter.has_next?
      item = iter.next
      diag[item[0]] = item[2] if yield(item)
    end
    diag
  end

  def tridiagonal
    raise 'Not implemented'
  end

  def cofactor(_row, _col)
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
    @rows == @cols
  end

  def positive?
    raise 'Not implemented'
  end

  def invertible?
    raise 'Not implemented'
  end

  def symmetric?
    # TODO: Implement
    true
  end

  def traceable?
    raise 'Not implemented'
  end

  def orthogonal?
    raise 'Not implemented'
  end

  def diagonal?
    # TODO: Implement
    true
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

  def iterator
    CSRIterator.new(@row_vector, @col_vector, @data)
  end

  alias t transpose
  alias tr trace

  # Utility functions
  def map
    m = dup
    (0...m.rows).each do |x|
      (0...m.cols).each do |y|
        current = m.at(x, y)
        new_val = yield(current, x, y)
        m.put(x, y, new_val)
      end
    end
    m
  end

  def map_diagonal
    m = dup
    (0...m.rows).each do |x|
      current = m.at(x, x)
      new_val = yield(current, x)
      m.put(x, x, new_val)
    end
    m
  end

  def map_nz
    m = dup
    (0...m.rows).each do |r|
      (0...m.cols).each do |c|
        yield(m.at(r, c)) unless m.at(r, c).zero?
      end
    end
    m
  end

  protected

  def map_nocopy
    (0...@rows).each do |x|
      (0...@cols).each do |y|
        current = at(x, y)
        new_val = yield(current, x, y)
        put(x, y, new_val) if new_val != current
      end
    end
  end

  def map_diagonal_nocopy
    (0...@rows).each do |x|
      current = at(x, x)
      new_val = yield(current, x)
      put(x, x, new_val) if new_val != current
    end
  end

  def map_nz_nocopy
    # TODO: Optimize to O(m) time
    (0...@rows).each do |r|
      (0...@cols).each do |c|
        yield(at(r, c)) unless at(r, c).zero?
      end
    end
  end

  private

  attr_accessor(:data, :col_vector, :row_vector)

  def plus_matrix(_other)
    raise 'Not implemented'
  end

  def plus_scalar(_other)
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

  def determinant_simple
    det = 0
    (0..(@cols - 1)).each do |i|
      right = 1.0
      left = 1.0
      (diagonal { |item| item[1] == (item[0] + i) % @rows }).each { |i| right *= i }
      (diagonal { |item| item[1] == (item[0] + i) % @rows }).each { |i| left *= i }
      det += right - left
    end
    det
  end
end
