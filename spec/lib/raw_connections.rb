module DataMapper::Mongo::Spec
  module RawConnections
    # Returns a Mongo::Database instance which can be used for manually
    # adjusting the database used by repository +repo+.
    def database(repo = :default)
      DataMapper.repository(repo).adapter.send(:database)
    end
  end

  extend RawConnections
end
