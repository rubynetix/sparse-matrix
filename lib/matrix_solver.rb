module MatrixSolver

  def sum(m)
    res = 0
    it = m.iterator
    while it.next?
      res += it.next
    end
    res
  end

end