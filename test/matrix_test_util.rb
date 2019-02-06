module MatrixTestUtil
  def rand_range(l, h, size)
    i = 0
    a = []
    while i < size
      a.push(rand(l..h))
      i += 1
    end
    a
  end

  def rand_sparse(rows = rand(1..1000), cols = rand(1..1000), range = (-1000..1000))
    # TODO: Implementation
  end

  def rand_square_sparse(size: 1000, range: -1000..1000)
    rand_sparse(rows: size, cols: size, range: range)
  end

  def upper_triangular_matrix(n, l, h)
    # return a upper triangular matrix with n rows and columns
    # with non-zero values in the range l..h
    m = SparseMatrix.new(n, n)
    (0...m.rows).each do |y|
      (0...m.cols).each do |x|
        if y > x
          m.insert(x, y, 0)
        else
          if rand(0..1) == 0
            m.insert(x, y, 0)
          else
            m.insert(x, y, rand(l...h))
          end
        end
      end
    end
    m
  end

  def lower_triangular_matrix(n, l, h)
    # return a lower triangular matrix with n rows and columns
    # with non-zero values in the range l..h
    m = SparseMatrix.new(n, n)
    (0...m.rows).each do |y|
      (0...m.cols).each do |x|
        if x > y
          m.insert(x, y, 0)
        else
          if rand(0..1) == 0
            m.insert(x, y, 0)
          else
            m.insert(x, y, rand(l...h))
          end
        end
      end
    end
    m
  end

  def upper_hessenberg_matrix(n, l, h)
    # return a upper hessenberg matrix with n rows and columns
    # with non-zero values in the range l..h
    m = SparseMatrix.new(n, n)
    (0..m.rows).each do |y|
      (0..m.cols).each do |x|
        m.insert(x, y, rand(l...h)) if (y <= x + 1) && (rand(0..1) == 0)
      end
    end
    m
  end

  def lower_hessenberg_matrix(n, l, h)
    # return a lower hessenberg matrix with n rows and columns
    # with non-zero values in the range l..h
    m = SparseMatrix.new(n, n)
    (0..m.rows).each do |y|
      (0..m.cols).each do |x|
        m.insert(x, y, rand(l...h)) if (x <= y + 1) && (rand(0..1) == 0)
      end
    end
    m
  end

  def sparse_to_matrix(s)
    m = Matrix.build(s.rows, s.cols) { |_row, _col| 0 }
    it = s.iterator
    while s.next?
      e = s.next
      m[e.row][e.col] = e.val
    end
    m
  end

  def iterate_matrix(m)
    (0..m.rows - 1).each do |i|
      (0..m.cols - 1).each do |j|
        yield(i, j, m.at(i, j))
      end
    end
  end

  def char_count(c, s)
    cnt = 0
    s.each_char { |chr| cnt += 1 if c == chr }
    cnt
  end
end
