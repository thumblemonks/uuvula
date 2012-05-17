require 'activerecord'
# This module adds support for reading and writing UUIDs from
# the database, assuming a BINARY(16) or VARBINARY(16) column UUID.
#
# Ideally, we could add a new attribute typecast to Rails, but this is
# non-trivial in Rails 2
#
# TODO: Add support for configurable UUID column name.
# TODO: Refactor into a gem.
module Uuvula
  def self.included(mod)
    mod.extend(ClassMethods)
    class << mod
      alias_method_chain :sanitize_sql_hash_for_conditions, :uuid_support
    end
  end

  def self.convert_uuid_to_raw(value)
    case value
    when UUIDTools::UUID
      value.raw
    when String
      case value.size
      when 36, 32
        value = value.gsub('-','')
        UUIDTools::UUID.parse_hexdigest(value).raw
      when 16
        value
      end
    else
      nil
    end
  end

  def self.define_uuid_reader(mod, column_name)
    method_body = <<-EOF
      def #{column_name}
        value = read_attribute_before_type_cast('#{column_name}')
        UUIDTools::UUID.parse_raw(value).hexdigest if value
      end
    EOF
    mod.send(:class_eval, method_body, __FILE__, __LINE__)
  end

  def self.define_uuid_writer(mod, column_name)
    method_body = <<-EOF
      def #{column_name}=(value)
        write_attribute('#{column_name}', Uuvula.convert_uuid_to_raw(value))
      end
    EOF
    mod.send(:class_eval, method_body, __FILE__, __LINE__)
  end

  def self.define_callbacks(mod, column_name)
    method_body = <<-EOF
      def _generate_uuid
        if self.#{column_name}.blank?
          self.#{column_name} = UUIDTools::UUID.timestamp_create
        end
      end
    EOF
    mod.send(:class_eval, method_body, __FILE__, __LINE__)
    mod.send(:before_save, :_generate_uuid)
  end
  
  module ClassMethods
    def uuid_column(column_name = :uuid)
      @uuid_column_name = column_name.to_sym
      Uuvula.define_uuid_reader(self, @uuid_column_name)
      Uuvula.define_uuid_writer(self, @uuid_column_name)
      Uuvula.define_callbacks(self, @uuid_column_name)
    end

    def sanitize_sql_hash_for_conditions_with_uuid_support(attrs, table_name = quoted_table_name)
      if @uuid_column_name && attrs.has_key?(@uuid_column_name)
        attrs[@uuid_column_name] = Uuvula.convert_uuid_to_raw(attrs[@uuid_column_name])
      end
      sanitize_sql_hash_for_conditions_without_uuid_support(attrs, table_name)
    end
  end
end

# TODO: leftover from before porting to a gem. Clean up.
ActiveRecord::Base.send(:include, Uuvula)
