require_relative 'tridiagonal_matrix'
require_relative 'matrix_factory'

class TriDiagonalMatrixFactory < MatrixFactory
  def initialize(suppress_warnings: false)
    @suppress_warnings = suppress_warnings
  end

  def new(rows, cols = rows)
    n = force_square(rows, cols)
    TriDiagonalMatrix.new(n)
  end

  def zero(rows, cols = rows)
    n = force_square(rows, cols)
    new(n)
  end

  def identity(n)
    new(n).map_diagonal { 1 }
  end

  def random_loc(rows, _ = rows)
    r = rand(0..rows - 1)
    [r, r + rand(-1..1)]
  end

  private

  def force_square(rows, cols)
    if rows != cols
      warn "Tried to create #{rows} x #{cols} tridiagonal matrix.\nForcing to square #{rows} x #{rows} matrix" unless @suppress_warnings
    end
    rows
  end

  def num_nz(rows, cols, fill_factor)
    (((3 * rows) - 2) * fill_factor / 100).floor
  end
end