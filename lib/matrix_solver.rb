
class MatrixSolver
  class << self
    def sum(m)
      res = 0
      it = m.iterator
      res += it.next while it.next?
      res
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
  end
end