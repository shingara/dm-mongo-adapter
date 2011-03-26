class DateTime
  SEC_FRACTION_TO_USEC = 10**6 * (RUBY_VERSION < '1.9' ? 60 * 60 * 24 : 1)

  # @api public
  def self.to_mongo(value)
    utc  = value.new_offset(0)
    usec = utc.sec_fraction * SEC_FRACTION_TO_USEC
    ::Time.utc(utc.year, utc.month, utc.day, utc.hour, utc.min, utc.sec, usec)
  end

  # @api public
  def self.from_mongo(value)
    value.to_datetime
  end
end # DateTime
