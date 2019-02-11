# frozen_string_literal: true

class CSRIterator
  def initialize(row_vec, col_vec, data)
    @row_vec = row_vec
    @col_vec = col_vec
    @data = data
    @row_idx = @row_vec.index { |val| val > 0 }
    @col_idx = 0

  end

  def has_next?
    (@col_idx < @col_vec.length) && !@row_idx.nil?
  end

  def next
    row = @row_idx - 1
    col = @col_vec[@col_idx]
    val = @data[@col_idx]
    @col_idx += 1
    @row_idx += 1 while @col_idx >= @row_vec[@row_idx] and (@col_idx < @col_vec.length)
    [row, col, val]
  end

  def iterate
    yield(self.next) while has_next?
  end
end
