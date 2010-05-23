class Date
  # @api public
  def self.to_mongo(value)
    Time.utc(value.year, value.month, value.day)
  end

  # @api public
  def self.from_mongo(value)
    ::Date.new(value.year, value.month, value.day)
  end
end # Date
