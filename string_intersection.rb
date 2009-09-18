class String
  # Intersection of self and other is the longest prefix of self that is a
  # suffix of other or the longest suffix of self that is a prefix of other.
  #
  # Example:
  # * "gnome"  & "meat"     => "me"
  # * "goat"   & "long ago" => "go"
  # * "car"    & "boat"     => ""
  # * "carpet" & "car"      => "car"
  # 
  def &(other)
    raise ArgumentError, "Can't intersect String with #{other.class}" unless String === other
    '' unless String === other  # alternative to ArgumentError?
    n = size
    n = other.size if other.size < n
    result = ''
    0.upto(n) do |i|
      if self[0,i] == other[-i,i]
        result = self[0,i]
      elsif self[-i,i] == other[0,i]
        result = self[-i,i]
      end
    end
    result
  end
end

if __FILE__ == $0
  require 'test/unit'
  class StringIntersectionTest < Test::Unit::TestCase
    def setup
      @empty = ''
    end

    def test_empty_string
      assert_equal @empty, @empty & @empty, "empty with empty"
      assert_equal @empty, 'not' & @empty,  "non-empty with empty"
      assert_equal @empty, @empty & 'not',  "empty with non-empty"
    end

    def test_equal_strings
      s = "Some long string that I'm ready to take to the intersection"
      assert_equal s, s & s, "string with self"
    end

    def test_prefix
      assert_equal 'f', 'f' & 'fr', 'single char string as prefix of other'
      assert_equal 'f', 'fr' & 'f', 'other is single char prefix of string'
      assert_equal 'fred', 'fred' & 'fredrick', 'multi-char string as suffix of other'
      assert_equal 'fred', 'fredrick' & 'fred', 'other is multi-char suffix of string'
    end

    def test_suffix
      assert_equal 'r', 'r' & 'fr', 'single char string as suffix of other'
      assert_equal 'r', 'fr' & 'r', 'other is single char suffix of string'
      assert_equal 'rick', 'rick' & 'fredrick', 'multi-char string as suffix of other'
      assert_equal 'rick', 'fredrick' & 'rick', 'other is multi-char suffix of string'
    end

    def test_other_intersections
      assert_equal 'site', 'new web site' & 'site-wide policy'
    end

    def test_other_empty_intersections
      assert_equal @empty, 'fred' & 'ethel'
      assert_equal @empty, 'The quick brown fox jumps over the lazy dog.' & 'The lazy dog lies under the jumping fox.'
      assert_equal @empty, 'Blah, Blah, blah' & 'yada, yada, yada'
    end

    def test_invalid            # Note that these are NOT symmetric because :& exists for some other classes
      assert_raise(ArgumentError) { 'any' & 0 } # "Fixnum (has it's own :& method)"
      assert_raise(ArgumentError) { 'any' & 1.0 } # "Float"
      assert_raise(ArgumentError) { 'any' & [] } # "Array (has it's own :& method)"
      assert_raise(ArgumentError) { 'any' & {} } # "Hash"
      assert_raise(ArgumentError) { 'any' & nil } # 'nil'
      assert_raise(ArgumentError) { 'any' & true } # "true (has it's own :& method)"
      assert_raise(ArgumentError) { 'any' & false } # "false (has it's own :& method)"
    end
  end
end
