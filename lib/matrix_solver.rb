
module MatrixSolver
  def sum(m)
    res = 0
    it = m.iterator
    res += it.next while it.next?
    res
  end

  def det
    raise 'Not implemented'
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
end
