class Range
  def random
    case self.begin <=> self.end
    when -1
      self.begin + rand(self.end - self.begin + (self.exclude_end? ? 0 : 1))
    when 0
      self.begin
    when +1
      self.begin - rand(self.begin - self.end + (self.exclude_end? ? 0 : 1))
    end
  end
end
