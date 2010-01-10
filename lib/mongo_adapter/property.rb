module DataMapper
  class Property
    def from_mongo(value)
      if value
        primitive.respond_to?(:from_mongo) ? primitive.from_mongo(value) : value
      end
    end

    def to_mongo(value)
      if value
        if primitive.respond_to?(:to_mongo)
          primitive.to_mongo(value)
        else
          custom? ? type.dump(value, self) : value
        end
      end
    end
  end
end

class Class
  def self.from_mongo(value)
    Object.const_get(value)
  end

  def self.to_mongo(value)
    value.to_s
  end
end

class DateTime
  def self.from_mongo(value)
    value.to_datetime
  end

  def self.to_mongo(value)
    value.to_time.utc
  end
end

class Date
  def self.to_mongo(value)
    Time.utc(value.year, value.month, value.day)
  end

  def self.from_mongo(value)
    Date.new(value.year, value.month, value.day)
  end
end
