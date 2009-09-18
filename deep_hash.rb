def deep_hash(levels=1, default=nil)
  if levels == 0
    if default
      Hash.new { |h,k| h[k] = default }
    else
      Hash.new
    end
  else
    Hash.new { |h,k| h[k] = deep_hash(levels-1, default) }
  end
end

if File.expand_path($0) == File.expand_path(__FILE__)
  require 'test/unit'

  class DeepHashTest < Test::Unit::TestCase
    def test_zero_levels_and_no_default_is_normal_hash
      expected = Hash.new
      actual = deep_hash(0)
      assert_equal expected, actual
      assert_nil actual[:key]
      assert_equal [], actual.keys
    end

    def test_zero_levels_and_default_is_normal_hash
      expected = Hash.new(42)
      actual = deep_hash(0,42)
      assert_equal expected, actual
      assert_equal 42, actual[:key]
      assert_equal [:key], actual.keys
    end

    def test_one_level_and_no_default_is_simple_nested_hash
      expected = Hash.new {|h,k| h[k] = Hash.new}
      actual = deep_hash(1)
      assert_equal expected, actual
      assert_nil actual[1][:key]
      assert_equal [1], actual.keys
      assert_equal [], actual[1].keys
    end

    def test_one_level_and_default_is_simple_nested_hash
      expected = Hash.new {|h,k| h[k] = Hash.new(43)}
      actual = deep_hash(1,43)
      assert_equal expected, actual
      assert_equal 43, actual[1][:key]
      assert_equal [1], actual.keys
      assert_equal [:key], actual[1].keys
    end

    def test_three_levels_and_default_for_glenn
      expected = Hash.new {|h3,k3| h3[k3] = Hash.new {|h2,k2| h2[k2] = Hash.new {|h,k| h[k] = Hash.new(44) } } }
      actual = deep_hash(3, 44)
      assert_equal expected, actual
      assert(expected == actual, "Using ==")
      assert_equal 44, actual[:a][:b][:c][:d]
      actual[:a][:b][:c][:new] += 1
      assert_equal 45, actual[:a][:b][:c][:new]
      assert_equal [:d,:new], actual[:a][:b][:c].keys
    end
  end
end
