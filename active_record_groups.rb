require 'pp'
require 'fastercsv'

module ActiveRecord
  module Groups
    def groups(*columns)
      return if columns.empty?
      options = columns.last.is_a?(Hash) ? columns.pop.dup : {}
      select = columns.join(',') + ',count(*) AS count_all'
      group  = columns.join(',')
      columns = (columns + ['count_all']).map{|c|c.to_s}
      find(:all, options.merge({ :select => select,
                                 :group => group })).map {|rec|
        rec['count_all'] = rec['count_all'].to_i
        rec.attributes(:only => columns).values_at(*columns)
      }
    end
  end
end

pp StagedProduct.count
class StagedProduct
  extend ActiveRecord::Groups
end

filename = 'log/staged-counts.csv'
cols = [ :vendor_name, :source, :permanent, :suppressed, :ignored_vendor ]
result = StagedProduct.groups(*cols)
FasterCSV.open(filename, 'w') do |csv|
  csv << cols
  result.each {|r| csv << r }
end
puts "%5d rows in %s"%[result.size, filename]
