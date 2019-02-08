# Compressed Sparse Row Matrix
class SparseMatrix
  attr_reader(:data, :indices, :indptr)
  attr_reader(:rows, :cols, :nnz)

  def initialize(rows, cols = rows)
    raise TypeError unless rows >= 0 && cols >= 0
    @data = []
    @indices = []
    @indptr = []
    @rows = rows
    @cols = cols
    raise NotImplementedError
  end

  class << self
    def zero(rows, cols)
      raise "Not implemented"
    end

    def identity(n)
      raise "Not implemented"
    end

    alias :I :identity
  end

  def rows
    raise "Not implemented"
  end

  def cols
    raise "Not implemented"
  end

  def nnz
    raise "Not implemented"
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
    raise "Not implemented"
  end

  def sum
    raise "Not implemented"
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
    if @rows == 0 && @cols == 0
      "nil\n"
    else
      # "#{self.class}[" + @rows.collect{|row|
      #   "[" + row.collect{|e| e.to_s}.join(", ") + "]"
      # }.join(", ")+"]"
      raise "Not implemented"
    end
  end

  def insert(row, col, val)
    raise "Not implemented"
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
end
