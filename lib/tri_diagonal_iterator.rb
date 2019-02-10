class TriDiagonalIterator
  def initialize(low_diag, main_diag, up_diag)
    @diags = [main_diag, up_diag, low_diag]
    @idx = 0
  end

  def has_next?
    @idx < (@diags[0].length + @diags[1].length + @diags[2].length)
  end

  def next
    diag, offset = @idx % 3, @idx / 3
    val = @diags[diag][offset]
    row = offset + row_offset(@idx)
    col = offset + col_offset(@idx)
    @idx += 1

    [row, col, val]
  end

  def iterate
    yield(self.next) while has_next?
  end

  private

  def row_offset(idx)
    # Element from lower diag is 1 row below.
    idx % 3 == 2 ? 1 : 0
  end

  def col_offset(idx)
    # Element from upper diag is 1 column ahead.
    idx % 3 == 1 ? 1 : 0
  end
end
