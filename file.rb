class File
  def to_s expand=false
    File.platform(expand ? File.expand_path(path) : path)
  end
  def self.platform(str)
    str.gsub('/', SEPARATOR)
  end

  # Returns a relative path to <tt>target</tt> from the current directory or
  # the supplied <tt>from</tt> location (which can be the name of a file or a
  # directory).
  def self.relative_path target, from='.'
    from = File.expand_path(from.to_s)
    from = File.dirname(from) unless File.directory?(from)
    from = from.split(SEPARATOR)

    target = File.expand_path(target.dup).split(SEPARATOR)

    result = ''
    while from.first == target.first
      from.shift
      target.shift
    end
    result << "..#{SEPARATOR}" * from.size
    result << File.join(*target)
    result
  end

=begin
  # http://blog.zenspider.com/archives/2006/08/i_miss_perls_b.html
  def self.binary? path
    s = (File.read(path, 4096) || "").split(//)
    ((s.size - s.grep(" ".."~").size) / s.size.to_f) > 0.30
  end
  # Nobuyoshi Nakada <nobu@ruby-lang.org>
  def self.binary? path
    s = read(path, 4096) and
      !s.empty? and
      (/\0/n =~ s or s.count("\t\n\r\s-~").to_f/s.size<=0.7)
  end
=end

end
# ----
if __FILE__ == $0
  require 'test/unit'
  require 'fileutils'
  class FileRelativePathTest < Test::Unit::TestCase
    def setup
      @tmpdir = case
                when ENV['TMPDIR'] && File.directory?(ENV['TMPDIR']) : ENV['TMPDIR']
                when ENV['TMP']    && File.directory?(ENV['TMP'])    : ENV['TMP']
                when File.directory?('/tmp') : '/tmp'
                end
      @testdir = File.join(@tmpdir, $$.to_s)
      Dir.mkdir(@testdir)
    end

    def teardown
      FileUtils.rm_rf(@testdir)
      @testdir = nil
      @tmpdir = nil
    end

    def test_local_file
      expected = 'here'
      actual = File.expand_path(expected, '.')
      assert_equal expected, File.relative_path(actual)
    end

    def test_file_in_sister_dir
      %w[ brother sister ].each do |d|
        FileUtils.mkdir_p(File.join(@testdir, d))
      end
      actual   = File.expand_path('sister/file', @testdir)
      starting = File.join(@testdir, 'brother')
      expected = '../sister/file'
      assert_equal expected, File.relative_path(actual, starting)
    end

    def test_aunt_dir
      %w[ mom/me aunt ].each do |d|
        FileUtils.mkdir_p(File.join(@testdir, d))
      end
      actual   = File.expand_path('aunt', @testdir)
      starting = File.expand_path('mom/me', @testdir)
      expected = '../../aunt'
      assert_equal expected, File.relative_path(actual, starting)
    end

    def test_cousin_file
      %w[ mom/me aunt/cousin ].each do |d|
        FileUtils.mkdir_p(File.join(@testdir, d))
      end
      actual   = File.expand_path('aunt/cousin/file', @testdir)
      starting = File.expand_path('mom/me/file',      @testdir)
      FileUtils.touch([actual, starting])
      expected = '../../aunt/cousin/file'
      assert_equal expected, File.relative_path(actual, starting)
    end

  end

end
