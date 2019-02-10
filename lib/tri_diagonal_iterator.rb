class TriDiagonalIterator
  def initialize(low_diag, main_diag, up_diag)
    @diags = [low_diag, main_diag, up_diag]
    @idx = 0
  end

  def has_next?
    @idx < @diags[1].length
  end

  def next
    block, offset = @idx % 3, @idx / 3

    val = @diags[block][offset]
    row = @idx + row_offset(@idx)
    col = @idx + col_offset(@idx)
    @idx += 1

    [row, col, val]
  end

  def iterate
    yield(self.next) while has_next?
  end

  private

  def row_offset(idx)
    # Element from lower diag is 1 row below.
    idx % 2 == 0 ? 1 : 0
  end

  def col_offset(idx)
    # Element from upper diag is 1 column ahead.
    idx % 2 == 1 ? 1 : 0
  end
end
