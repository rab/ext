# Copyright (c) 2008 Rob Biedenharn
#   Rob [at] AgileConsultingLLC.com
#   Rob_Biedenharn [at] alum.mit.edu
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Inspiration from:
#
# Upload a file via POST with Net::HTTP
#  http://www.realityforge.org/articles/2006/03/02/upload-a-file-via-post-with-net-http
#
# Standup 04/27/07: Testing File Uploads
#  http://pivots.pivotallabs.com/users/damon/blog/articles/227-standup-04-27-07-testing-file-uploads
#  (including the comments)

require 'net/https'
require "rubygems"
gem 'mime-types'
require "mime/types"
require "base64"
require 'cgi'

class Net::HTTP::Post
  # Create a multipart form having the parts as defined by the Hash.  Keys
  # should be simple names, but values can be files or suitably file-like
  # approximations.  If the value is an IO (like a File or a StringIO), its
  # read method will be used to get the content and if it responds to :path,
  # the filename attribute will be taken from the File.basename of the path.
  # To override the filename, the value can be a pair of an IO object and a
  # string.  The filename will be used by MIME::Types to guess the
  # Content-Type with a default of 'application/octet-stream'.
  #
  # Sample code:
  #
  # url = URI.parse('https://www.example.com/todo.cgi')
  #
  # File.open(File.expand_path('script/test.png'), 'r') do |file|
  #   http = Net::HTTP.new(url.host, url.port)
  #   begin
  #     http.start do |http|
  #       request = Net::HTTP::Post.new(url.path)
  #       request.basic_auth 'lonely_user', 'really_long_password'
  #       request.multipart_params = {'file' => file, 'title' => 'title'}
  #       response = http.request(request)
  #       case response
  #       when Net::HTTPSuccess, Net::HTTPRedirection
  #         # OK
  #       else
  #         response.error!
  #       end
  #
  #       response.value
  #       puts response.body
  #     end
  #   rescue Net::HTTPServerException => e
  #     p e
  #   end
  # end
  #
  def multipart_params=(param_hash={})
    boundary_token = [Array.new(8) {rand(256)}].join
    self.content_type = "multipart/form-data; boundary=#{boundary_token}"
    boundary_marker = "--#{boundary_token}\r\n"
    self.body = param_hash.map { |param_name, param_value|
      boundary_marker + case param_value
                        when Array
                          file_to_multipart(param_name, *param_value)
                        when IO
                          file_to_multipart(param_name, param_value)
                        else
                          text_to_multipart(param_name, param_value.to_s)
                        end
    }.join('') + "--#{boundary_token}--\r\n"
  end

  protected

  # filename is optional if file_or_content.is_a?(File)
  def file_to_multipart(key, file_or_content, filename=nil)
    # puts "multipart gets: key=#{key.inspect}, file_or_content as #{file_or_content.class.name}, filename=#{filename.inspect}"

    case file_or_content
    when File, StringIO
      file = file_or_content
      filename ||= File.basename(file.path) if file.respond_to?(:path)
      content = file.read
    else
      filename ||= 'data'
      content = file_or_content
    end

    mime_types = MIME::Types.of(filename) rescue []
    mime_type = mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type
    part = %Q{Content-Disposition: form-data; name="#{key}"; filename="#{filename}"\r\n}
    part += "Content-Transfer-Encoding: binary\r\n"
    part += "Content-Length: #{content.length}\r\n"
    part += "Content-Type: #{mime_type}\r\n\r\n#{content}\r\n"
  end

  def text_to_multipart(key,value)
    # puts "multipart gets: key=#{key.inspect}, value=#{value.inspect}"

    "Content-Disposition: form-data; name=\"#{key}\"\r\n\r\n#{value}\r\n"
  end
end
