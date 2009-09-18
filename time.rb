# Adds a Time.travel_to for testing support
#   This entry was posted by John Barnette on Wednesday, November 7th, 2007 at 12:54 am
#   http://geeksomnia.com/2007/11/07/timetravel_to/
#
# Time Flies While You're Having Fun Testing
#   Posted by Rick DeNatale on July 18, 2007
#   http://talklikeaduck.denhaven2.com/articles/2007/07/18/time-flies-while-youre-having-fun-testing


# This makes Time act more like the Enumerable it really is
# It also adds some Time travel methods

class Time
  class Slice < Array; end

  extend Enumerable

  def succ
    self + 1
  end

  def upto(other)
    self.to_i.upto(other.to_i) { |item| yield Time[item] }
  end

  def downto(other)
    self.to_i.downto(other.to_i) { |item| yield Time[item] }
  end

  class << self
    def [](*args)
      args = args.first .. (args.first + args.last) if args.length == 2
      index = args.first
      unless index.is_a? Range
        at(index)
      else
        index.inject(Time::Slice.new) {|state, item| state << at(item)}
      end
    end

    def first; self[0]; end
    def last; self[2**31-1]; end

    def each
      first.upto(last) { |item| yield item }
    end

    alias :old_now :now
    def now;
      at(old_now.to_i + (@offset || 0))
    end

    attr_accessor :offset

    def set(to)
      @offset ||= 0
      @offset += to.to_i - Time.now.to_i
      now
    end
    alias :now= :set

    alias :goto :set
    alias :travel :set
    def rewind; goto(Time.first); end

    # optimizations
    def max; last; end
    def min; first; end
    def include?(item); (first..last).include? item; end
    alias :member? :include?

    def speed
      @speed || 1
    end

    def speed=(new_speed)
      @speed = new_speed
      @time_mover.kill if @time_mover
      @time_mover = Thread.new(@speed) { |speed|
        begin
          loop {
            Time.now += speed - 1
            sleep 1
          }
        # stop dying at start or end of Time
        rescue ArgumentError
        end
      } if @speed != 1
    end

    def stop
      self.speed = 0
    end
  end
end
