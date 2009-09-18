class Object
  def tap
    yield self if block_given?
    self
  end
end
