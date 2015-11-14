require 'em-pg-client'
require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class EmPgClientAdapter < PostgreSQLAdapter
      def adapter_name
        "something".freeze
      end
    end
  end
end

