class Time
  def qtr
    h, m = (((self.min+self.sec/60.0+self.usec/6.0e+7)*4.0)/60.0).round.divmod(4)
    ::Time.send(self.utc? ? :utc : :local,
                self.year, self.month, self.day,
                self.hour + h, m * 15, 0, 0)
  end
end
