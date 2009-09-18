#!/usr/bin/env ruby -w

module Enumerable
  # Similar to the sliding window of values offered by each_cons, but treating
  # the first values as if they wrapped around to the end of the enumeration
  def each_cycle(window, start=0)
    wrap_start = []
    cache = []
    each_with_index do |e,i|
      cache << e
      if i >= start + (window - 1)
        yield cache[start, window]
        cache.shift
      else
        wrap_start << e
      end
    end
    wrap_start.each do |e|
      cache << e
      yield cache[start, window]
      cache.shift
    end
    self
  end

  def sum
    inject(0){|s,e|s+e}
  end

  def product
    inject(1){|p,t|p*t}
  end

  # Like each_with_index, but the value is the array of block results.
  def map_with_index
    a = []
    each_with_index { |e,i| a << yield(e, i) }
    a
  end

  # Returns a Hash keyed by the value of the block to the number times that
  # value was returned.  If you have experience with the #group_by from
  # ActiveSupport, this would be like .group_by(&block).map{|k,a|[k,a.size]}
  # (except it is a Hash rather than an Array).
  def count_by
    counts = Hash.new(0)
    each {|e| counts[yield(e)] += 1}
    counts
  end

  # Return a minimum number of values from the enumeration as if to provide
  # victors in a competition.  The winner is actually two winners if there's a
  # tie. Similarly, a tie for third place puts four members in the top three.
  # By default, the meaning of "top" is the largest numeric value, but a block
  # can be given as with sort_by to give a different order (or to cope with
  # types that don't implement a unary minus (@-) for the default block
  # {|x|-x} that sorts in reverse).
  #
  # The test for a tie in the final place uses == so that should be
  # well-behaved for the elements of the enumeration.
  def top_n(n, &block)
    raise ArgumentError, "Must request at least one element" unless n >= 1
    block = lambda { |x| - x } if block.nil?
    input = []
    cutoff = nil
    self.dup.sort_by(&block).each_with_index do |x,i|
      if i < n
        input << (cutoff = x)
      elsif cutoff && x == cutoff
        input << x
      else
        break
      end
    end
    input
  end
end
# ----
if __FILE__ == $0
  require 'test/unit'
  class EachCycleTest < Test::Unit::TestCase
    def test_array_by_one
      input = %w[a b c d e]
      expects = [ %w[a],
                  %w[b],
                  %w[c],
                  %w[d],
                  %w[e] ]
      assert_cycles_are expects, input
    end

    def test_array_by_two
      input = %w[a b c d e]
      expects = [ %w[a b],
                  %w[b c],
                  %w[c d],
                  %w[d e],
                  %w[e a] ]
      assert_cycles_are expects, input
    end

    def test_array_by_three
      input = %w[a b c d e]
      expects = [ %w[a b c],
                  %w[b c d],
                  %w[c d e],
                  %w[d e a],
                  %w[e a b] ]
      assert_cycles_are expects, input
    end

    def test_range_by_three
      input = 'a'..'e'
      expects = [ %w[a b c],
                  %w[b c d],
                  %w[c d e],
                  %w[d e a],
                  %w[e a b] ]
      assert_cycles_are expects, input
    end

    def assert_cycles_are expected, input, message=nil
      cyc_size = expected.first.size
      message ||= "#{cyc_size} pieces from #{input.inspect}"
      actuals = []
      input.each_cycle(cyc_size) do |cyc|
        actuals << cyc
      end
      assert_equal expected.length, actuals.length, "wrong number of iterations? #{message}"
      assert_equal expected, actuals, "wrong contents? #{message}"
    end
  end

  class MapWithIndexTest < Test::Unit::TestCase
    def test_array_mapping
      input = [ 1, 2, 3 ]
      expects = [ [ 2, 0 ], [ 4, 1 ], [ 6, 2 ] ]
      assert_equal expects, input.map_with_index { |e,i| [ e * 2, i ] }
    end
    def test_range_mapping
      input = 'a'...'d'
      expects = [ '', 'b', 'cc' ]
      assert_equal expects, input.map_with_index { |e,i| e * i }
    end
  end

  class TopNTest < Test::Unit::TestCase
    def test_simple_nodups
      input = [ 1, 3, 7, 4, 10, 8, 9, 5, 2, 6]
      expects = [10,9,8]        # need a top_n_by(3) { |x| -x }
      assert_equal expects, input.top_n(3)
    end

    def test_simple_with_dups
      input = [1, 3, 3, 7, 3, 7, 7, 6, 8, 2]
      expects = {
        1 => [ 8 ],
        2 => [ 8, 7, 7, 7 ],
        3 => [ 8, 7, 7, 7 ],
        4 => [ 8, 7, 7, 7 ],
        5 => [ 8, 7, 7, 7, 6 ],
        6 => [ 8, 7, 7, 7, 6, 3, 3, 3 ],
        7 => [ 8, 7, 7, 7, 6, 3, 3, 3 ],
        8 => [ 8, 7, 7, 7, 6, 3, 3, 3 ],
        9 => [ 8, 7, 7, 7, 6, 3, 3, 3, 2 ],
        10 => [ 8, 7, 7, 7, 6, 3, 3, 3, 2, 1 ],
      }
      expects.each do |n,expect|
        assert_equal expect, input.top_n(n), "Top #{n} should give #{expect.inspect}"
      end
    end

    def test_simple_with_block
      input = [1, 3, 3, 7, 3, 7, 7, 6, 8, 2]
      pred = lambda { |x| x.odd? ? [ 0, x ] : [ 1, -x ] }
      expects = {
        1 => [ 1 ],
        2 => [ 1, 3, 3, 3 ],
        3 => [ 1, 3, 3, 3 ],
        4 => [ 1, 3, 3, 3 ],
        5 => [ 1, 3, 3, 3, 7, 7, 7 ],
        6 => [ 1, 3, 3, 3, 7, 7, 7 ],
        7 => [ 1, 3, 3, 3, 7, 7, 7 ],
        8 => [ 1, 3, 3, 3, 7, 7, 7, 8 ],
        9 => [ 1, 3, 3, 3, 7, 7, 7, 8, 6 ],
        10 =>[ 1, 3, 3, 3, 7, 7, 7, 8, 6, 2 ],
      }
      expects.each do |n,expect|
        assert_equal expect, input.top_n(n) { |x| x % 2 != 0 ? [ 0, x ] : [ 1, -x ] }, "Top #{n} should give #{expect.inspect}"
      end
    end

    def test_reasonable_n
      assert_raise(ArgumentError) { [ 1, 2 ].top_n(0) }
      assert_raise(ArgumentError) { [ 1, 2 ].top_n(0.5) }
      assert_nothing_raised {
        assert_equal [2],   [ 1, 2 ].top_n(1)
        assert_equal [2,1], [ 1, 2 ].top_n(2)
        assert_equal [2,1], [ 1, 2 ].top_n(3)
      }
    end

    def test_non_numeric_strings
      input = 'a'..'z'
      expects = %w[ a b c ]
      assert_equal expects, input.top_n(3) {|x| x}
    end
    def test_mixed
      input = [ 1..5, 'a'..'g', 3.14, false, :ruby ]
      expects = [ 1..5, 3.14, 'a'..'g' ]
      assert_equal expects, input.top_n(3) {|x| x.to_s}
    end
    def test_race_times
      input = [ 56.24, 55.18, 53.21, 54.18, 56.24, 55.95, 54.18, 54.19 ]
      expects = [ 53.21, 54.18, 54.18 ]
      assert_equal expects, input.top_n(3) {|x| x}
    end
    def test_weightlifting
      input = [ 245, 235, 250, 235, 240, 245, 240, 250 ]
      expects = [ 250, 250, 245, 245 ]
      assert_equal expects, input.top_n(3)
    end
  end
end
