
module MatrixSolver
  def sum(m)
    res = 0
    it = m.iterator
    res += it.next while it.next?
    res
  end
end
