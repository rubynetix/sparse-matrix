# frozen_string_literal: true
require_relative 'csr_iterator'
require_relative 'matrix_solver'

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
        while idx < row_end and idx < nnz and cols > @col_vector[idx]
          new_data_vector.push(@data[idx])
          new_col_vector.push(@col_vector[idx])
          row_dec += 1
          idx += 1
        end

        @row_vector[r] -= row_dec
      end

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
      return
    end

    unless val.zero?
      # Inserting a new element
      insert(row, col, index, val)
    end
  end

  def +(o)
    o.is_a?(SparseMatrix) ? plus_matrix(o) : plus_scalar(o)
  end

  def -(o)
    o.is_a?(SparseMatrix) ? plus_matrix(-o) : plus_scalar(-o)
  end

  def *(o)
    o.is_a?(SparseMatrix) ? mul_matrix(o) : mul_scalar(o)
  end

  def **(o)
    raise 'Not implemented'
  end

  def ==(o)
    raise 'Not implemented'
  end

  def to_s
    s = ""
    (0..@rows-1).each do |r|
      (0..@cols-1).each do |c|
        s += "#{at(r, c)} "
      end
      s += "\n"
    end
    s
  end

  def det
    raise 'Not implemented'
  end

  def sum
    total = 0
    map_nz! { |val| total += val }
    total
  end

  def diagonal
    raise 'Not implemented'
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
    raise 'NotInvertibleException' unless invertible?

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
    # TODO: Implement in O(m) time
    (0..@rows-1).each do |r|
      (0..@cols-1).each do |c|
        return false if at(r, c).negative?
      end
    end
    true
  end

  def invertible?
    det != 0
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
    (0...m.rows).each do |r|
      (0...m.cols).each do |c|
        yield(m.at(r, c)) unless m.at(r, c).zero?
      end
    end
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

private

  def plus_matrix(o)
    raise 'Not implemented'
  end

  def plus_scalar(x)
    map {|val, _, _| val + x }
  end

  def mul_matrix(x)
    MatrixSolver.matrix_mult(self, x, SparseMatrix.zero(rows, x.cols))
  end

  def mul_scalar(x)
    map {|val, _, _| val * x }
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
