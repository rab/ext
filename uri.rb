require 'uri'

# Born of discussion of RFC2396 on Ruby-Talk
# There's also the Addressable Gem: <http://Addressable.RubyForge.Org/>.

module URI
  # Return a canonicalized version of a given uri.
  #
  # canonicalize('http://www.Ruby-Lang.ORG/ARSE/done/../../rear/./end/.')
  # => "http://www.ruby-lang.org/rear/end/"
  def self.canonicalize(uri)
    u = uri.kind_of?(URI) ? uri : URI.parse(uri.to_s)
    u.normalize!
    newpath = u.path
    loop do
      ret = newpath.gsub!(%r{([^/]+)/\.\./?}) { |match| $1 == '..' ? match : '' }
      break if ret.nil?
    end
    u.path = newpath.gsub(%r{/\./}, '/').sub(%r{/\.\z}, '/')
    u.to_s
  end
end
