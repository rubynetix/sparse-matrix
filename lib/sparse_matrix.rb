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

    alias :I :identity
  end

  def nnz
    @data.size
  end

  def det
    raise 'Not implemented'
  end

  def resize(rows, cols)
    raise "Not implemented"
  end

  def set_zero
    raise "Not implemented"
  end

  def set_identity
    raise "Not implemented"
  end

  def at(row, col)
    _, val = get_index(row, col)
    unless val.nil?
      return val
    end
    0
  end

  def sum
    total = 0
    map_nz{|val| total += val}
    total
  end

  def +(o)
    raise "Not implemented"
  end

  def -(o)
    raise "Not implemented"
  end

  def *(o)
    raise "Not implemented"
  end

  def **(o)
    raise "Not implemented"

  end

  def ==(o)
    raise "Not implemented"
  end

  def to_s
    raise "Not implemented"
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
    raise "Not implemented"
  end

  def tridiagonal
    raise "Not implemented"
  end

  def cofactor(row, col)
    raise "Not implemented"
  end

  def adjoint
    raise "Not implemented"
  end

  def inverse
    raise "Not implemented"
  end

  def rank
    raise "Not implemented"
  end

  def transpose
    raise "Not implemented"
  end

  def trace
    raise "Not implemented"
  end

  def nil?
    raise "Not implemented"
  end

  def zero?
    raise "Not implemented"
  end

  def identity?
    raise "Not implemented"
  end

  def square?
    raise "Not implemented"
  end

  def positive?
    raise "Not implemented"
  end

  def invertible?
    raise "Not implemented"
  end

  def symmetric?
    raise "Not implemented"
  end

  def traceable?
    raise "Not implemented"
  end

  def orthogonal?
    raise "Not implemented"
  end

  def diagonal?
    raise "Not implemented"
  end

  def lower_triangular?
    raise "Not implemented"
  end

  def upper_triangular?
    raise "Not implemented"
  end

  def lower_hessenberg?
    raise "Not implemented"
  end

  def upper_hessenberg?
    raise "Not implemented"
  end

alias_method :t, :transpose
alias_method :tr, :trace

  # Utility functions
  def map
    m = self.copy
    (0...m.rows-1).each do |x|
      (0...m.cols-1).each do |y|
        current = m.at(x, y)
        new_val = yield(current, x, y)
        m.put(x, y, new_val) if new_val != current
      end
    end
    m
  end

  def map_diagonal
    m = self.copy
    (0...m.rows-1).each do |x|
      current = m.at(x, x)
      new_val = yield(current, x)
      m.put(x, x, new_val) if new_val != current
    end
    m
  end

  def map_nz
    (0..@rows-1).each do |r|
      (0..@cols-1).each do |c|
        unless at(r, c) == 0
          yield(at(r,c))
        end
      end
    end
  end

private
  def plus_matrix(o)
    raise "Not implemented"
  end

  def plus_scalar(o)
    raise "Not implemented"
  end

  def mul_matrix(x)
    raise "Not implemented"
  end

  def mul_scalar(x)
    raise "Not implemented"
  end

  def rref
    raise "Not implemented"
  end

  # Returns the index of the
  def get_index(row, col)
    row_start, row_end = @row_vector[row], @row_vector[row + 1]
    index = row_start

    while index < row_end and col <= @col_vector[index]
      if @col_vector[index] == col
        return [index, @data[index]]
      end
      index += 1
    end
    [index, nil]
  end

  def insert(row, col, index, val)
    @data.insert(index, val)
    @col_vector.insert(index, col)
    (row+1..@rows).each do |r|
      @row_vector[r] += 1
    end
  end

  def delete(row, index)
    @data.delete_at(index)
    @col_vector.delete_at(index)
    (row+1..@rows).each do |r|
      @row_vector[r] -= 1
    end
  end
end
