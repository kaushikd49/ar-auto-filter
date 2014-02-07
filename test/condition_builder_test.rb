require "rubygems"
require 'active_record'
require 'active_support/all'
require 'bundler/setup'
require "shoulda"
require "test/unit"
require "activerecord-auto_filter"

require_relative "helpers/sample_model_definitions"
require_relative "helpers/db_setup_helper"
require_relative "../lib/activerecord-auto_filter/condition_builder"

class ConditionBuilderTest < Test::Unit::TestCase
  include SampleModelDefinitions
  include DbSetupHelper
  include ActiveRecord::ConditionBuilder

  def setup
    super
    do_db_setups
  end

  context "inclusions check" do
    should "contain only expected associations for inclusions" do
      params = {:f1 => :f1_val, :f2 => :f2_val, :f3 => 4, :f4 => 41}
      1.upto(params.size) do
        assert_presence_of_correct_associations(params)
        params.shift
      end
    end
  end

  context "where clause filter structure check" do
    should "contain appropriate kind filters - string or hash" do
      table1_name = Order.table_name.to_sym
      table2_name = OrderItem.table_name.to_sym
      table3_name = Product.table_name.to_sym
      params = {:f1 => :f1_val, :f2 => :f2_val, :f3 => 4}
      result = get_generated_conditions(params).last
      query_details = result[:root_model]

      # Check string filter exists and its structure
      association_containing_hash_filter = query_details.delete(:association2)
      assert_equal([{table2_name => {:c2 => :f2_val}}], association_containing_hash_filter)

      # Check hash filter exists and its structure
      assert(query_details.all? do |association,filter_details|
        string_where_clause = filter_details.first
        string_where_clause.match(/#{table1_name}.*c1.*f1_val/) or string_where_clause.match(/#{table3_name}.*c3.*4/)
      end)
    end

    should "contain multiple kind of filters for a given association" do
      params = {:f1 => :f1_val, :f2 => :f2_val, :f3 => 4, :f4 => 5}
      query_spec = get_sample_query_spec
      query_spec[:root_model][:association2][:f4] =
          {
            :filter_type => :string, :filter_operator => :eq,
            :source_table_model => OrderItemUnit, :column => :c4
          }

      result = emit_inclusion_and_filter_details(params, query_spec)
      assert_equal(2,result[:root_model][:association2].size)
    end

    should "contain join filters" do
      table1_model = Order
      table2_model = OrderItem
      table1_name = table1_model.table_name
      table2_name = table2_model.table_name
      query_spec = get_sample_query_spec
      params = {:f2 => :f2_val, :f3 => 4}

      query_spec[:root_model][:association2][:join_filter] =
          {
             :source_table_model1 => table1_model, :table1_column => :col1,
             :source_table_model2 => table2_model, :table2_column => :col2,
          }
      result = emit_inclusion_and_filter_details(params, query_spec)

      assert_equal(2,result[:root_model][:association2].size)
      assert(result[:root_model][:association2].any? do |filter|
          filter.class == String and filter.match(/#{table1_name}.*col1.*#{table2_name}.*col2.*/)
      end)
    end
  end

  def assert_presence_of_correct_associations(params)
    query_spec, result = get_generated_conditions(params)
    associations_to_be_included = result[:root_model].keys

    associations_actually_included =
        query_spec[:root_model].select do |association,filter_field_hash|
          (filter_field_hash.keys & params.keys).present?
        end.keys

    assert_equal(associations_to_be_included, associations_actually_included)
  end

  def get_generated_conditions(params)
    query_spec = get_sample_query_spec
    result = emit_inclusion_and_filter_details(params, query_spec)
    return query_spec, result
  end

  def get_sample_query_spec
    {
        :root_model =>
            {
                :self =>
                    {
                        :f1 =>
                            {
                                :filter_type => :string, :filter_operator => :lt,
                                :source_table_model => Order, :column => :c1
                            }
                    },
                :association2 =>
                    {
                        :f2 =>
                            {
                                :filter_type => :hash, :filter_operator => :eq,
                                :source_table_model => OrderItem, :column => :c2
                            }
                    },
                :association3 =>
                    {
                        :f3 =>
                            {
                                :filter_type => :string, :filter_operator => :gteq,
                                :source_table_model => Product, :column => :c3
                            }
                    }
            }
    }
  end
end
