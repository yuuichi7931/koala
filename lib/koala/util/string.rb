class String
  def sjisable
    str = self
    str = str.exchange("U+301C", "U+2D") # wave-dash
    str = str.exchange("U+FF5E", "U+2D") # wave-dash
    str = str.exchange("U+2212", "U+2D") # full-width minus
    str = str.exchange("U+FF0D", "U+2D") # full-width minus
    str = str.exchange("U+00A2", "U+FFE0") # cent as currency
    str = str.exchange("U+00A3", "U+FFE1") # lb(pound) as currency
    str = str.exchange("U+00AC", "U+FFE2") # not in boolean algebra
    str = str.exchange("U+2014", "U+2015") # hyphen
    str = str.exchange("U+2016", "U+2225") # double vertical lines
    str = str.exchange("U+2122", "U+2015") # TM
  end

  def exchange(before_str,after_str)
    self.gsub( before_str.to_code.chr('UTF-8'),
              after_str.to_code.chr('UTF-8') )
  end

  def to_code
    return $1.to_i(16) if self =~ /U\+(\w+)/
      raise ArgumentError, "Invalid argument: #{self}"
  end
end

