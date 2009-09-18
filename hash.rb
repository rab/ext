# From Ezra Zygmuntowicz via ruby-talk
class Hash
  # lets through the keys in the argument
  # >> {:one => 1, :two => 2, :three => 3}.pass(:one)
  # => {:one=>1}
  def pass(*allowed_keys)
    self.reject { |k,v| ! allowed_keys.include?(k) }
  end

  # blocks the keys in the arguments
  # >> {:one => 1, :two => 2, :three => 3}.block(:one)
  # => {:two=>2, :three=>3}
  def block(*prohibited_keys)
    self.reject { |k,v| prohibited_keys.include?(k) }
  end
end
