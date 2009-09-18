# from: Daniel DeLorme <dan-ml@dan42.com>
# (via ruby-talk@ruby-lang.org)

class NilClass
  def ergo
    @blackhole ||= Object.new.instance_eval do
      class << self
        for m in public_instance_methods
          undef_method(m.to_sym) unless m =~ /^__.*__$/
        end
      end
      def method_missing(*args); nil; end
      self
    end
    @blackhole unless block_given?
  end
end

class Object
  def ergo
    if block_given?
      yield(self)
    else
      self
    end
  end
end
