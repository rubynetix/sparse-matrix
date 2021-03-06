# frozen_string_literal: true
require_relative 'matrix_common'
require_relative 'matrix_exceptions'
require_relative 'tridiagonal_iterator'


# Tridiagonal Sparse Matrix
class TriDiagonalMatrix
  include MatrixCommon
  attr_reader(:rows, :cols)

  def initialize(rows, cols: rows, val: 0)
    raise NonSquareException unless rows == cols
    # raise TypeError unless rows > 2 && cols > 2

    if rows.positive?
      @upper_dia = Array.new(rows-1, val)
      @main_dia = Array.new(rows, val)
      @lower_dia = Array.new(rows-1, val)
    else
      @upper_dia = []
      @main_dia = []
      @lower_dia = []
    end

    @rows = rows
    @cols = cols
  end

  def initialize_clone(other)
    super
    @upper_dia = other.instance_variable_get(:@upper_dia).clone
    @main_dia = other.instance_variable_get(:@main_dia).clone
    @lower_dia = other.instance_variable_get(:@lower_dia).clone
    @rows = other.rows
    @cols = other.cols
  end

  class << self
    include MatrixExceptions

    def create(rows, cols: rows, val: 0)
      TriDiagonalMatrix.new(rows, cols: cols, val: val)
    end

    def zero(rows, cols = rows)
      TriDiagonalMatrix.new(rows, cols: cols)
    end

    def identity(n)
      TriDiagonalMatrix.new(n).map_diagonal { 1 }
    end

    def [](*rows)
      # 0x0 matrix
      return TriDiagonalMatrix.new(rows.length) if rows.length.zero?

      raise ArgumentError unless rows.length == 3 and
          rows[0].length == rows[1].length - 1 and
          rows[2].length == rows[1].length - 1
      m = TriDiagonalMatrix.new(rows[1].length)
      m.instance_variable_set(:@upper_dia, rows[0])
      m.instance_variable_set(:@main_dia, rows[1])
      m.instance_variable_set(:@lower_dia, rows[2])
      m
    end

    def from_sparse_matrix(s)
      raise NonSquareException unless s.square?
      m = TriDiagonalMatrix.new(s.rows)
      s.iterator.iterate do |r, c, v|
        m.put(r, c, v) if r - c <= 1
      end
      m
    end

    alias I identity
  end

  def nnz
    @upper_dia.count { |x| x != 0 } + @main_dia.count { |x| x != 0 } + @lower_dia.count { |x| x != 0 }
  end

  def set_zero
    @upper_dia = Array.new(rows-1, 0)
    @main_dia = Array.new(rows, 0)
    @lower_dia = Array.new(rows-1, 0)
  end

  def set_identity
    @upper_dia = Array.new(rows-1, 0)
    @main_dia = Array.new(rows, 1)
    @lower_dia = Array.new(rows-1, 0)
  end

  def resize!(size, _ = size)
    if size > @rows
      size_up!(@main_dia, size)
      size_up!(@lower_dia, size - 1)
      size_up!(@upper_dia, size - 1)
    elsif size < @rows
      size_down!(@main_dia, size)
      size_down!(@lower_dia, size - 1)
      size_down!(@upper_dia, size - 1)
    end
    @rows = @cols = size
    self
  end

  def at(r, c)
    return nil? unless r < @rows && c < @cols

    diag, idx = get_index(r, c)

    return 0 if diag.nil? || diag.length == 0

    diag[idx]
  end

  def put(r, c, val)
    unless on_band?(r, c)
      # warn "Insertion at (#{r}, #{c}) would violate tri-diagonal structure. No element inserted."
      return false
    end

    resize!([r, c].max + 1) unless [r, c].max + 1 <= @rows
    diag, idx = get_index(r, c)
    diag[idx] = val unless diag.nil?
    true
  end

  # def +(o)
  #   o.is_a?(MatrixCommon) ? plus_matrix(o) : plus_scalar(o)
  # end
  #
  # def -(o)
  #   o.is_a?(MatrixCommon) ? plus_matrix(o * -1) : plus_scalar(-o)
  # end
  #
  # def *(o)
  #   o.is_a?(MatrixCommon) ? mul_matrix(o) : mul_scalar(o)
  # end

  def det
    prev_det = 1 # det of a 0x0 is 1
    det = @main_dia[0] # det of a 1x1 is the number itself
    index = 1
    while index < @rows
      temp_prev = det
      det = @main_dia[index] * det \
          - @lower_dia[index - 1] * @upper_dia[index - 1] * prev_det
      prev_det = temp_prev
      index += 1
    end
    det
  end

  def diagonal
    @main_dia.clone
  end

  def tridiagonal
    clone
  end

  def nil?
    @rows == 0 && @cols == 0
  end

  def iterator
    TriDiagonalIterator.new(@lower_dia, @main_dia, @upper_dia)
  end

  def symmetric?
    @lower_dia == @upper_dia
  end

  def transpose
    m = clone
    m.transpose!
    m
  end

  def transpose!
    temp = @lower_dia
    @lower_dia = @upper_dia
    @upper_dia = temp
  end

  def positive?
    @upper_dia.find(&:negative?).nil? and
        @main_dia.find(&:negative?).nil? and
        @lower_dia.find(&:negative?).nil?
  end

  def lower_triangular?
    @upper_dia.count { |x| x != 0 } == 0
  end

  def upper_triangular?
    @lower_dia.count { |x| x != 0 } == 0
  end

  def lower_hessenberg?
    true
  end

  def upper_hessenberg?
    true
  end

  def on_band?(r, c)
    (r - c).abs <= 1
  end

  def to_ruby_matrix
    matrix_array = Array.new(@rows) { Array.new(@cols, 0) }

    (0...@rows).each do |x|
      (0...@cols).each do |y|
        matrix_array[x][y] = at(x, y)
      end
    end

    Matrix[*matrix_array]
  end

  # Method aliases
  alias t transpose
  alias tr trace
  alias [] at
  alias get at
  alias set put
  alias []= put
  alias plus +
  alias subtract -
  alias multiply *
  alias exp **
  alias adjoint adjugate


private

  def to_sparse_matrix
    m = SparseMatrix.new(@rows, @cols)
    iterator.iterate{|r, c, val| m.put(r, c, val)}
    m
  end

  def plus_matrix(o)
    to_sparse_matrix + o
  end

  def mul_matrix(o)
    to_sparse_matrix * o
  end

  def size_up!(diag, len)
    diag.concat(Array.new(len - diag.length, 0))
  end

  def size_down!(diag, len)
    diag.slice!(len...diag.length) unless len >= diag.length
  end

  # Assumes that (r, c) is inside the matrix boundaries
  def get_index(r, c)
    return [nil, nil] unless on_band?(r, c)

    idx = [r, c].min

    if r == c
      return [@main_dia, idx]
    elsif
      r < c
      return [@upper_dia, idx]
    end
    [@lower_dia, idx]
  end
end
