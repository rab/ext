#!/usr/bin/env ruby -I~/code/ruby/ext

require 'array' # for Array#random

if File.exist?("/usr/share/dict/words") && (ARGV[0] || '10') == '10'
  # From Jamis Buck via Twitter and Pastie:
  # http://pastie.org/231294
  # 2008-07-09
  def random_password(length=10)
    @words ||= File.readlines("/usr/share/dict/words").reject { |w| w.strip.length != length }.
      map { |w| w.strip.downcase }
    w1 = @words.random[0,3]
    w2 = @words.random[3,3]
    w3 = @words.random[6,4]
    return "%s%s%s%03d" % [w1, w2, w3, rand(1000)]
  end
else
  # Slightly different semantics (length is how many letters to put in the password)
  # with letter frequencies from
  # http://pages.central.edu/emp/LintonT/classes/spring01/cryptography/letterfreq.html
  def random_password(length=10)
    @letters ||= [ ['e',12702], ['t', 9056], ['a', 8167], ['o', 7507], ['i', 6966], ['n', 6749], ['s', 6327],
                   ['h', 6094], ['r', 5987], ['d', 4253], ['l', 4025], ['c', 2782], ['u', 2758], ['m', 2406],
                   ['w', 2360], ['f', 2228], ['g', 2015], ['y', 1974], ['p', 1929], ['b', 1492], ['v', 978],
                   ['k', 772], ['j', 153], ['x', 150], ['q', 95], ['z', 74] ].
      inject([]){|s,(l,f)|s.concat([l]*f)}.sort_by { rand }
    pswd = ''
    length.times { pswd << @letters.random }
    return "%s%03d" % [pswd, rand(1000)]
  end
end

if File.expand_path($0) == File.expand_path(__FILE__)
  length = (ARGV.shift || 10).to_i
  (ARGV.shift || 1).to_i.times do
    puts random_password(length)
  end
end

__END__
