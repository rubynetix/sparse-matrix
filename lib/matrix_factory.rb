class MatrixFactory

  def build(rows, cols = rows, block = Proc.new)
    m = new(rows, cols)

    (0..rows-1).each do |r|
      (0..cols-1).each do |c|
        m.put(r, c, block.call(r, c))
      end
    end
    m
  end

  def random(rows: rand(1..100), cols: rand(1..100), range: -100..100, fill_factor: rand(0..50))
    m = new(rows, cols)
    nnz = num_nz(rows, cols, fill_factor)

    while nnz > 0
      r, c = random_loc(rows, cols)
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
end