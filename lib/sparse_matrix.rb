# frozen_string_literal: true
require 'matrix'
require_relative 'csr_iterator'
require_relative 'matrix_solver'
require_relative 'matrix_exceptions'


# Compressed Sparse Row Matrix
class SparseMatrix
  attr_reader(:rows, :cols)

  def initialize(rows, cols = rows)
    # If one dimension is 0, both dimensions must be 0
    if rows == 0 or cols == 0
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

  def +(o)
    o.is_a?(SparseMatrix) ? plus_matrix(o) : plus_scalar(o)
  end

  def -(o)
    o.is_a?(SparseMatrix) ? plus_matrix(o * -1) : plus_scalar(-o)
  end

  def *(o)
    o.is_a?(SparseMatrix) ? mul_matrix(o) : mul_scalar(o)
  end

  def /(o)
    throw TypeError unless o.is_a? SparseMatrix
    mul_matrix(o.inverse)
  end

  def **(x)
    throw NonSquareException unless square?
    throw TypeError unless x.is_a? Integer
    throw ArgumentError unless x > 1
    m_pow2 = dup
    while x.even?
      m_pow2 *= m_pow2
      x = x >> 1
    end
    new_m = m_pow2.dup
    x = x >> 1
    while x.positive?
      m_pow2 *= m_pow2
      new_m *= m_pow2 if x.odd?
      x = x >> 1
    end
    new_m
  end

  def ==(other)
    return false unless other.is_a? SparseMatrix
    return false unless (other.rows.equal? @rows) && (other.cols.equal? @cols)

    iter = iterator
    o_iter = other.iterator
    while iter.has_next? && o_iter.has_next?
      return false unless iter.next == o_iter.next
    end
    !iter.has_next? && !o_iter.has_next?
  end

  def to_s
    return "null\n" if null?

    it = iterator
    col_width = Array.new(cols, 1)

    while it.has_next?
      _, c, val = it.next
      col_width[c] = [col_width[c], val.to_s.length].max
    end

    s = ""
    (0...rows).each do |r|
      (0...cols).each do |c|
        s += at(r, c).to_s.rjust(col_width[c])
        s += " " if c < cols - 1
      end
      s += "\n"
    end
    s
  end

  def det
    raise 'NonSquareException' unless square?

    to_ruby_matrix.det
  end

  def sum
    total = 0
    map_nz! { |val| total += val }
    total
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

  def minor(row, col)
    minor_submatrix(row, col).det
  end

  def cofactor
    raise NonSquareException, "Cannot get cofactor matrix from non-square matrix" unless square?

    m = SparseMatrix.new(rows, cols)
    (0...rows).each do |r|
      (0...cols).each do |c|
        if r + c % 2 == 0
          sign = 1
        else
          sign = -1
        end

        m.put(r, c, sign * minor(r, c))
      end
    end
    m
  end

  def adjugate
    cofactor.transpose
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

  def trace
    raise NonTraceableException unless traceable?

    diagonal.sum(init=0)
  end

  def null?
    @rows.zero? || @cols.zero?
  end

  def zero?
    nnz.zero?
  end

  def identity?
    # TODO: Optimize using diagonal iterator
    return false unless square?
    map_diagonal! do |v|
      return false unless v == 1
      v
    end
    nnz == @rows
  end

  def square?
    @rows == @cols
  end

  def positive?
    @data.find(&:negative?).nil?
  end

  def invertible?
    !det.zero?
  end

  def symmetric?
    self == dup.transpose
  end

  def traceable?
    square?
  end

  def orthogonal?
    return false unless square?
    t = transpose
    i = t * self
    i.identity?
  end

  ##
  # Returns true if the matrix only contains non-zero values on the main diagonal
  def diagonal?
    iter = iterator
    if square?
      while iter.has_next?
        item = iter.next
        return false if item[0] != item[1] && item[2] != 0
      end
    else
      return false
    end
    true
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
  alias insert put
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
    map {|val, _, _| val + x }
  end

  def mul_matrix(x)
    MatrixSolver.matrix_mult(self, x, SparseMatrix.new(rows, x.cols))
  end

  def mul_scalar(x)
    map {|val, _, _| val * x }
  end

  def rref
    raise 'Not implemented'
  end

  def bsearch_cols(c_start, c_end, val)
    return c_start if c_start >= c_end

    mid = (c_end + c_start) / 2
    return mid if @col_vector[mid] == val
    return bsearch_cols c_start, mid, val if @col_vector[mid] > val

    bsearch_cols mid, c_end, val
  end

  def minor_submatrix(row, col)
    m = SparseMatrix.new(rows-1, cols-1)
    it = iterator
    while it.has_next?
      r, c, val = it.next
      new_row = r > row ? r - 1 : r
      new_col = c > col ? c - 1 : c

      if r != row and c != col
        m.put(new_row, new_col, val)
      end
    end
    m
  end

  # Returns the [index, val] corresponding to
  # an element in the matrix at position row, col
  # If a value does not exist at that location, the val returned is nil
  # and the index indicates the insertion location
  def get_index(row, col)
    r_start = @row_vector[row]
    r_end = @row_vector[row + 1]

    index = bsearch_cols r_start, r_end, col
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
