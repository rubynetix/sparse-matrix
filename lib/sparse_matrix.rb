class SparseMatrix

  def initialize(rows, cols = rows)
    raise "Not implemented"
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
    raise "Not implemented"
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
