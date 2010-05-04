=begin

Product.count

module ActiveRecord
  module Compare
    def compare other
      if self.class == other.class
        mismatched_columns = []
        self.class.column_names.each do |col|
          unless (a = self.send(col)) == (b = other.send(col))
            mismatched_columns << col
            puts "#{col}: #{a.inspect}"
            puts "#{' ' * col.size}: #{b.inspect}"
          end
        end
        mismatched_columns unless mismatched_columns.empty?
      end
    end
  end
end

Product.send :include, ActiveRecord::Compare

def find_and_fix(code, vendor_name=nil, source=nil)
  bad = Product.find_all_by_code_and_vendor_name_and_source code, vendor_name, source

  while bad.size > 1 && (bad_columns = bad.first.compare(bad.last))
    changed_attr = bad_columns - %w[id created_at updated_at refreshed_at local_image]
    if changed_attr.empty?
      puts "No atypical columns mismatched, destroying last"
      bad.pop.destroy
    elsif changed_attr == %w[ has_colors ]
      if bad.last.has_colors
        gone = bad.shift
        puts "Only mismatch is has_colors, destroying #{gone.id}"
        gone.destroy
      elsif bad.first.has_colors
        gone = bad.pop
        puts "Only mismatch is has_colors, destroying #{gone.id}"
        gone.destroy
      else
        bad.pop
      end
    elsif changed_attr.include?('discontinued')
      if bad.last.discontinued?
        good = bad.first
        gone = bad.pop
      else
        good = bad.last
        gone = bad.shift
      end
      puts "Keeping #{good.id}, destroying discontinued #{gone.id}"
      gone.destroy
    elsif changed_attr.include?('trait_group') && bad.last.trait_group.nil?
      gone = bad.pop
      puts "Keeping #{bad.first.id} w/ trait_group #{bad.first.trait_group}, destroying ungrouped #{gone.id}"
      gone.destroy
    else
      bad.pop
    end
  end

  bad
end

codes = Product.connection.select_all(%{select code, vendor_name, source from products where priority = 1 group by code, vendor_name, source having count(*) > 1}).map{|row| [row['code'],row['vendor_name'],row['source']]}; codes.size

codes.each {|code,vendor_name,source| find_and_fix code, vendor_name, source; puts}

=end
