def last_change_user file
  File.read('.svn/entries').match(/\f\n#{Regexp.quote file}[^\f]*\n(\w+)\n\f/m)[1] if File.exist?('.svn/entries')
end
