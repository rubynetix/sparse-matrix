# frozen_string_literal: true
#
module MatrixCommon
  def identity?
    return false unless square?

    map_diagonal! do |v|
      return false unless v == 1
      v
    end
    nnz == rows
  end

  def square?
    rows == cols
  end

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

  def invertible?
    !det.zero?
  end

  def sum
    total = 0
    map_nz! { |val| total += val }
    total
  end

  def matrix_mult(m1, m2, res)
    (0...m1.rows).each do |r|
      (0...m2.cols).each do |c|
        dot_prod = 0
        (0...m1.cols).each do |i|
          dot_prod += m1.at(r, i) * m2.at(i, c)
        end
        res.put(r, c, dot_prod)
      end
    end
    res
  end

  def +(o)
    o.is_a?(MatrixCommon) ? plus_matrix(o) : plus_scalar(o)
  end

  def -(o)
    o.is_a?(MatrixCommon) ? plus_matrix(o * -1) : plus_scalar(-o)
  end

  def *(o)
    o.is_a?(MatrixCommon) ? mul_matrix(o) : mul_scalar(o)
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

  def det
    raise 'NonSquareException' unless square?

    to_ruby_matrix.det
  end

  def trace
    raise NonTraceableException unless traceable?

    diagonal.sum(init=0)
  end

  def adjugate
    cofactor.transpose
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

  def minor(row, col)
    minor_submatrix(row, col).det
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

  def map_nz!
    # TODO: Optimize to O(m) time
    (0...@rows).each do |r|
      (0...@cols).each do |c|
        yield(at(r, c)) unless at(r, c).zero?
      end
    end
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

  def map_diagonal!
    (0...@rows).each do |x|
      current = at(x, x)
      new_val = yield(current, x)
      put(x, x, new_val) if new_val != current
    end
  end

  private

  def plus_scalar(x)
    map { |val, _, _| val + x }
  end

  def mul_scalar(x)
    map {|val, _, _| val * x }
  end

end
