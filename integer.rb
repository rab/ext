class Integer
  # Get an alphabetic string like the column headings on a spreadsheet.
  def to_column
    return 'a' if zero?
    upper, lower = self.divmod 26
    unless upper.zero?
      column = (upper - 1).to_column
    else
      column = ''
    end
    column << (?a + lower).chr
  end
end
