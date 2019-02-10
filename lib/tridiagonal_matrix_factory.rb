require_relative 'tridiagonal_matrix'

class TriDiagonalMatrixFactory
  def initialize(*args); end

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

  def random(rows: rand(1..100), cols: rand(1..100), range: -100..100, fill_factor: rand(0..50))
    m = new(rows)
    nnz = (rand(1..(3 * rows - 2)) * fill_factor / 100).floor

    while nnz > 0
      r = rand(0..rows - 1)
      c = r + rand(-1..1)
      if m.at(r, c) == 0
        m.put(r, c, rand(range))
        nnz -= 1
      end
    end
    m
  end

  def random_square(size: rand(1..100), range: -100..100, fill_factor: rand(0..50))
    random(rows: size, cols: size, range: range, fill_factor: fill_factor)
  end

  private

  def force_square(rows, cols)
    if rows != cols
      warn "Tried to create #{rows} x #{cols} tridiagonal matrix.\nForcing to square #{rows} x #{rows} matrix"
    end
    rows
  end
end
