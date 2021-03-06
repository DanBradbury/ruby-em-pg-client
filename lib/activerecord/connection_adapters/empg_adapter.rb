require 'em-pg-client'
require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class EmPgAdapter < PostgreSQLAdapter
      def adapter_name
        "EMPg".freeze
      end
    end
  end
end
