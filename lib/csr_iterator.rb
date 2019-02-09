class CSRIterator

  def initialize(row_vec, col_vec, data)
    @row_vec = row_vec
    @col_vec = col_vec
    @data = data

    @row_idx = @row_vec.index{|val| val > 0}
    @col_idx = 0
  end

  def has_next?
    @col_idx < @col_vec.length and not @row_idx.nil?
  end

  def next
    row, col, val = @row_idx - 1, @col_vec[@col_idx], @data[@col_idx]
    @col_idx += 1
    if @col_idx >= @row_vec[@row_idx]
      @row_idx += 1
    end
    [row, col, val]
  end

  def iterate
    while has_next?
      yield(self.next)
    end
  end
end