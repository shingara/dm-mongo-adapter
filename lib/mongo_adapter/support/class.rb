class Class
  # @api public
  def self.to_mongo(value)
    value.name
  end

  # @api public
  def self.from_mongo(value)
    ActiveSupport::Inflector.classify(value)
  end
end # Class
