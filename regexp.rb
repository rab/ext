class Regexp
  RFC822_EMAIL_ADDRESS =
    begin
      qtext = '[^\\x0d\\x22\\x5c\\x80-\\xff]' # not: FF " \ hi-bit
      dtext = '[^\\x0d\\x5b-\\x5d\\x80-\\xff]' # not: FF [ \ ] hi-bit
      # Any but: Ctrl-Spc    "     (    )    ,    .     :;<       >    @     [\]      Del-hibit
      atom = '[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+'
      quoted_pair = '\\x5c[\\x00-\\x7f]' # \_
      domain_literal = "\\x5b(?:#{dtext}|#{quoted_pair})*\\x5d" # like /\[.*\]/
      quoted_string = "\\x22(?:#{qtext}|#{quoted_pair})*\\x22"  # like /".*"/
      domain_ref = atom
      sub_domain = "(?:#{domain_ref}|#{domain_literal})"
      word = "(?:#{atom}|#{quoted_string})"
      domain = "#{sub_domain}(?:\\x2e#{sub_domain})*" # kinda:  word(\.word)*
      local_part = "#{word}(?:\\x2e#{word})*"
      addr_spec = "#{local_part}\\x40#{domain}" # words@sub.domain
      pattern = /\A#{addr_spec}\z/
    end
  # What about:
  #   "Rob Biedenharn" <rob@agileconsultingllc.com>
  # which is perfectly valid.
end
