# frozen_string_literal: true
require 'matrix'

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

  def upper_triangular_matrix(factory, n, l, h, fill_factor: 0.1)
    # return a upper triangular matrix with n rows and columns
    # with non-zero values in the range l..h
    m = factory.new(n, n)

    (0..n*n*fill_factor).each do
      x, y = factory.random_loc(m.rows, m.cols)
      m.put(y, x, rand(l...h)) if y > x
    end
    m
  end

  def lower_triangular_matrix(factory, n, l, h, fill_factor: 0.1)
    # return a lower triangular matrix with n rows and columns
    # with non-zero values in the range l..h
    m = factory.new(n, n)

    (0..n*n*fill_factor).each do
      x, y = factory.random_loc(m.rows, m.cols)
      m.put(y, x, rand(l...h)) if x < y
    end
    m
  end

  def upper_hessenberg_matrix(factory, n, l, h, fill_factor: 0.05)
    # return a upper hessenberg matrix with n rows and columns
    # with non-zero values in the range l..h
    m = factory.new(n, n)

    (0..n*n*fill_factor).each do
      x, y = factory.random_loc(m.rows, m.cols)
      m.put(y, x, rand(l...h)) if y <= x + 1
    end
    m
  end

  def lower_hessenberg_matrix(factory, n, l, h, fill_factor: 0.05)
    # return a lower hessenberg matrix with n rows and columns
    # with non-zero values in the range l..h
    m = factory.new(n, n)

    (0..n*n*fill_factor).each do
      x, y = factory.random_loc(m.rows, m.cols)
      m.put(y, x, rand(l...h)) if x <= y + 1
    end
    m
  end

  def sparse_to_matrix(s)
    a = Array.new(s.rows) { Array.new(s.cols) { 0 } }
    it = s.iterator
    while it.has_next?
      row, col, val = it.next
      a[row][col] = val
    end
    Matrix.build(s.rows, s.cols) { |i, j| a[i][j] }
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
