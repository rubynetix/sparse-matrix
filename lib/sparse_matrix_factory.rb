require_relative 'sparse_matrix'

class SparseMatrixFactory

  def initialize(*args); end

  def build(rows, cols, block = Proc.new)
    m = SparseMatrix.new(rows, cols)

    (0..rows-1).each do |r|
      (0..cols-1).each do |c|
        m.put(r, c, block.call(r, c))
      end
    end
  end
end
