require 'test/unit'
require 'activerecord'
require 'uuidtools'
require 'uuvula'
require 'sqlite3'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => File.join(File.dirname(__FILE__), 'test.db')

module BetterUUID
  class CreateSchema < ActiveRecord::Migration
    def self.up
      create_table :uuid_active_record_tests, :force => true do |t|
        t.binary :uuid, :limit => 16
      end
    end
  end

  CreateSchema.suppress_messages { CreateSchema.migrate(:up) }
end

class UuidActiveRecordTest < ::ActiveRecord::Base
  uuid_column :uuid
end

