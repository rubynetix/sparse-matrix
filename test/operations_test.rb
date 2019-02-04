require 'test/unit'
require_relative '../lib/sparse_matrix'

module TestUtil
  def rand_range(l, h, size)
    i = 0
    a = []
    a.push(rand(l..h)) while i < size
    a
  end

  def self.rand_matrix(rows = 100, cols = rows,
      scarcity = 0.4, range = (-1000..1000))
    arr = Array.new(rows, Array.new(cols, 0))
    arr.map! {|row| row.map {rand < scarcity ? rand(range) : 0}}
    arr
  end

  def sparse_to_matrix(s)
    m = Matrix.build(s.rows, s.cols) {|_row, _col| 0}
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
    s.each_char {|chr| cnt += 1 if c == chr}
    cnt
  end
end

class MatrixOperationsTest < Test::Unit::TestCase

  def setup;
  end

  def teardown;
  end

  def tst_plus_num;
  end

  def tst_plus_mat;
  end

  def tst_sub_num;
  end

  def tst_sub_mat;
  end

  def tst_mult_num;
  end

  def tst_mult_mat;
  end

  def tst_exponential;
  end

  def tst_equals;
  end
end
