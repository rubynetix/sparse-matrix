# frozen_string_literal: true
require 'matrix'
require_relative 'csr_iterator'
require_relative 'matrix_common'
require_relative 'matrix_exceptions'


# Compressed Sparse Row Matrix
class SparseMatrix
  include MatrixCommon
  attr_reader(:rows, :cols)

  def initialize(rows, cols = rows)
    # If one dimension is 0, both dimensions must be 0
    if rows.zero? or cols.zero?
      rows = 0
      cols = 0
    end

    @data = []
    @row_vector = Array.new(rows + 1, 0)
    @col_vector = []
    @rows = rows
    @cols = cols
  end

  def initialize_clone(other)
    super
    @data = other.instance_variable_get(:@data).clone
    @row_vector = other.instance_variable_get(:@row_vector).clone
    @col_vector = other.instance_variable_get(:@col_vector).clone
    @rows = other.rows
    @cols = other.cols
  end

  class << self
    include MatrixExceptions
    def create(rows, cols: rows, val: 0)
      m = SparseMatrix.new(rows, cols)
      m.map! {|_, _, _| val} unless val == 0
      m
    end

    def identity(n)
      SparseMatrix.new(n).map_diagonal { 1 }
    end

    def [](*rows)
      # 0x0 matrix
      return SparseMatrix.new(rows.length) if rows.length.zero?

      m = SparseMatrix.new(rows.length, rows[0].length)

      (0...m.rows).each do |r|
        (0...m.cols).each do |c|
          m.put(r, c, rows[r][c])
        end
      end
      m
    end

    def from_ruby_matrix(ruby_matrix)
      return SparseMatrix.new(ruby_matrix.row_count) if ruby_matrix.row_count.zero?

      m = SparseMatrix.new(ruby_matrix.row_count, ruby_matrix.column_count)

      (0...m.rows).each do |r|
        (0...m.cols).each do |c|
          m.put(r, c, ruby_matrix[r, c])
        end
      end
      m
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
    map_diagonal! { 1 }
  end

  def resize!(rows, cols)
    if rows < @rows
      last_idx = @row_vector[rows]
      @row_vector = @row_vector.take(rows+1)
      @data = @data.take(last_idx)
      @col_vector = @col_vector.take(last_idx)
    elsif rows > @rows
      (@rows...rows).each do
        @row_vector.push(nnz)
      end
    end

    if cols < @cols
      row_dec = 0
      new_data_vector = []
      new_col_vector = []

      (0...rows).each do |r|
        idx, row_end = @row_vector[r], @row_vector[r+1]
        while idx < row_end and idx < nnz and @col_vector[idx] < cols
          new_data_vector.push(@data[idx])
          new_col_vector.push(@col_vector[idx])
          idx += 1
        end

        @row_vector[r] -= row_dec
        row_dec += row_end - idx
      end

      @row_vector[rows] -= row_dec
      @data = new_data_vector
      @col_vector = new_col_vector
    end

    @rows = rows
    @cols = cols
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
      return true
    end

    unless val.zero?
      # Inserting a new element
      insert(row, col, index, val)
    end
    true
  end

  def /(o)
    throw TypeError unless o.is_a? SparseMatrix
    mul_matrix(o.inverse)
  end

  ##
  # Returns an array containing the values along the main diagonal of the matrix
  def diagonal
    raise NonSquareException, "Can not get diagonal of non-square matrix." unless square?

    diag = Array.new(@rows, 0)
    iter = iterator
    while iter.has_next?
      item = iter.next
      diag[item[0]] = item[2] if item[0] == item[1]
    end
    diag
  end

  def tridiagonal
    map { |val, r, c| (r == c || c == r - 1 || c == r + 1) ? val : 0 }
  end

  def inverse
    raise 'NotInvertibleException' unless invertible?

    inverse = to_ruby_matrix.inv
    SparseMatrix.from_ruby_matrix(inverse)
  end

  def rank
    to_ruby_matrix.rank
  end

  def transpose
    m = SparseMatrix.new(cols, rows)
    iter = iterator
    while iter.has_next?
      row, col, val = iter.next
      m.put col, row, val
    end
    m
  end

  ##
  # Returns true if all the entries above the main diagonal are zero.
  # Returns false otherwise.
  def lower_triangular?
    return false unless square?
    iter = iterator
    while iter.has_next?
      item = iter.next
      return false if item[1] > item[0] && item[2] != 0
    end
    true
  end

  ##
  # Returns true if all the entries below the main diagonal are zero.
  # Returns false otherwise.
  def upper_triangular?
    return false unless square?
    iter = iterator
    while iter.has_next?
      item = iter.next
      return false if item[0] > item[1] && item[2] != 0
    end
    true
  end

  ##
  # Returns true if all the entries above the first superdiagonal are zero.
  # Returns false otherwise.
  def lower_hessenberg?
    return false unless square?
    iter = iterator
    while iter.has_next?
      r, c, v = iter.next
      return false if c > (r + 1) && v != 0
    end
    true
  end

  ##
  # Returns true if all the entries below the first subdiagonal diagonal are zero.
  # Returns false otherwise.
  def upper_hessenberg?
    return false unless square?
      iter = iterator
      while iter.has_next?
        r, c, v = iter.next
        return false if r > (c + 1) && v != 0
      end
      true
  end

  def to_ruby_matrix
    matrix_array = Array.new(@rows) { Array.new(@cols, 0) }

    (0...@rows).each do |x|
      (0...@cols).each do |y|
        matrix_array[x][y] = at(x, y)
      end
    end

    Matrix[*matrix_array]
  end

  def iterator
    CSRIterator.new(@row_vector, @col_vector, @data)
  end

  # Utility functions
  def map
    m = clone
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
    m = clone
    (0...m.rows).each do |x|
      current = m.at(x, x)
      new_val = yield(current, x)
      m.put(x, x, new_val)
    end
    m
  end

  def map_nz
    m = clone
    m.iterator.iterate{|_, _, val| yield(val) unless val.zero?}
    m
  end

  def map!
    (0...@rows).each do |x|
      (0...@cols).each do |y|
        current = at(x, y)
        new_val = yield(current, x, y)
        put(x, y, new_val) if new_val != current
      end
    end
  end

  def map_diagonal!
    (0...@rows).each do |x|
      current = at(x, x)
      new_val = yield(current, x)
      put(x, x, new_val) if new_val != current
    end
  end

  def map_nz!
    # TODO: Optimize to O(m) time
    (0...@rows).each do |r|
      (0...@cols).each do |c|
        yield(at(r, c)) unless at(r, c).zero?
      end
    end
  end

  # Method aliases
  alias t transpose
  alias tr trace
  alias [] at
  alias get at
  alias set put
  alias []= put
  alias plus +
  alias subtract -
  alias multiply *
  alias exp **
  alias adjoint adjugate

  private

  def plus_matrix(o)
    map {|val, r, c| val + o.at(r, c)}
  end

  def plus_scalar(x)
    map { |val, _, _| val + x }
  end

  def mul_scalar(x)
    map {|val, _, _| val * x }
  end

  def mul_matrix(x)
    res = SparseMatrix.new(rows, x.cols)

    (0...@rows).each do |r|
      (0...@cols).each do |c|
        dot_prod = 0
        (0...@cols).each do |i|
          dot_prod += at(r, i) * x.at(i, c)
        end
        res.put(r, c, dot_prod)
      end
    end
    res
  end

  def rref
    raise 'Not implemented'
  end

  # Returns the [index, val] corresponding to
  # an element in the matrix at position row, col
  # If a value does not exist at that location, the val returned is nil
  # and the index indicates the insertion location
  def get_index(row, col)
    index, row_end = @row_vector[row], @row_vector[row + 1]

    while (index < row_end) and (index < nnz) and (col >= @col_vector[index])
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
end
