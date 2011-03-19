class DateTime
  # @api public
  def self.to_mongo(value)
    utc = value.new_offset(0)
    ::Time.utc(utc.year, utc.month, utc.day, utc.hour, utc.min, utc.sec)
  end

  # @api public
  def self.from_mongo(value)
    value.to_datetime
  end
end # DateTime
