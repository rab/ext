class String
  def cleave(middle=nil)
    middle ||= self.length/2
    return nil unless (-self.length ... self.length).include?(middle)

    middle += self.length if middle < 0

    early = self.rindex(' ', middle)
    late = self.index(' ', middle)

    if self[middle,1] == ' '
      [ self[0...middle], self[middle+1..-1] ]
    elsif early.nil? && late.nil?
      [ self.dup, '' ]
    elsif early.nil?
      [ self[0...late], self[late+1..-1] ]
    elsif late.nil?
      [ self[0...early], self[early+1..-1] ]
    else
      middle = middle - early < late - middle ? early : late
      [ self[0...middle], self[middle+1..-1] ]
    end
  end
end

if __FILE__ == $0
  require 'test/unit'
  class StringCleaveTest < Test::Unit::TestCase
    def test_nospaces
      assert_equal [ 'whole',
                     '' ], 'whole'.cleave
      assert_equal [ 'Supercalifragilisticexpialidocious',
                     '' ], 'Supercalifragilisticexpialidocious'.cleave
    end
    def test_exact_middle
      assert_equal [ 'fancy',
                     'split' ], 'fancy split'.cleave
      assert_equal [ 'All good Rubyists',
                     'know how to party' ], 'All good Rubyists know how to party'.cleave
    end
    def test_symmetric_not_middle # prefer longer one first
      { 0   => [ 'the', 'one top dog ear' ],
        4   => [ 'the', 'one top dog ear' ],
        5   => [ 'the one', 'top dog ear' ],
        nil => [ 'the one top', 'dog ear' ],
        -7  => [ 'the one top', 'dog ear' ],
        -6  => [ 'the one top dog', 'ear' ],
        -1  => [ 'the one top dog', 'ear' ],
      }.each do |pos,expected|
        assert_equal expected, 'the one top dog ear'.cleave(pos), ".cleave #{pos}"
      end
    end
    def test_closer_to_start
      assert_equal [ 'short',
                     'splitter' ], 'short splitter'.cleave
      assert_equal [ 'Four score and',
                     'seven years ago...' ], 'Four score and seven years ago...'.cleave
      assert_equal [ 'abc def',
                     'ghijklm nop' ] , 'abc def ghijklm nop'.cleave
    end
    def test_closer_to_end
      assert_equal [ 'extended',
                     'split' ], 'extended split'.cleave
      assert_equal [ 'abc defghi',
                     'jklm nop' ] , 'abc defghi jklm nop'.cleave
    end
    def test_with_cleave_point
      phrase = 'abc defg hijk'
      assert_equal 13, phrase.length, 'phrase.length'
      assert_equal [ 'abc defg', 'hijk' ], phrase.cleave, "defaulted"
      assert_equal [ 'abc defg', 'hijk' ], phrase.cleave(phrase.length/2), "same as default"
      (0 ... phrase.length/2).each do |pos|
        assert_equal [ 'abc', 'defg hijk' ], phrase.cleave(pos), "#{phrase.inspect}.cleave(#{pos}) (fhff)"
      end
      (phrase.length/2 ... phrase.length).each do |pos|
        assert_equal [ 'abc defg', 'hijk' ], phrase.cleave(pos), "#{phrase.inspect}.cleave(#{pos}) (lhff)"
      end
      (-phrase.length ... -(phrase.length/2+1)).each do |pos|
        assert_equal [ 'abc', 'defg hijk' ], phrase.cleave(pos), "#{phrase.inspect}.cleave(#{pos}) (fhfb)"
      end
      (-(phrase.length/2+1) ... 0).each do |pos|
        assert_equal [ 'abc defg', 'hijk' ], phrase.cleave(pos), "#{phrase.inspect}.cleave(#{pos}) (lhfb)"
      end
    end
    def test_same_from_front_and_back
      phrase = 'this is a test phrase having various words of differing sizes'
      (0 ... phrase.length).each do |pos|
        rpos = pos-phrase.length
        assert_equal phrase.cleave(pos), phrase.cleave(rpos), "#{phrase.inspect}.cleave(#{pos}) .cleave(#{rpos})"
        assert_equal phrase.cleave(rpos), phrase.cleave(pos), "#{phrase.inspect}.cleave(#{rpos}) .cleave(#{pos})"
      end
    end

    def test_invalid_arguments
      phrase='a b'
      ((-phrase.length-5 .. phrase.length+5).to_a - (-phrase.length ... phrase.length).to_a).each do |badpos|
        assert_nil phrase.cleave(badpos), "#{phrase.inspect}.cleave(#{badpos})"
      end
    end
  end
end
