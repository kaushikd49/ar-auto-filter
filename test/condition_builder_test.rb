require "rubygems"
require 'bundler/setup'
require "shoulda"
require 'test/unit'
require_relative "../lib/activerecord-auto_filter"
require_relative "helpers/db_setup_helper"

class ConditionBuilderTest < Test::Unit::TestCase
  include DbSetupHelper # Arel has a dependency on db connection

  def setup
    do_db_setups
  end

  context "inclusions check" do
    should "contain only expected associations for inclusions" do
      params = {:f1 => :f1_val, :f2 => :f2_val, :f3 => 4, :f4 => 41}
      assert_associations_are_included(params, [:order_items, :product])

      params = {:f1 => :f1_val, :f2 => :f2_val, :f3 => 4}
      assert_associations_are_included(params, [:order_items, :product])

      params = {:f2 => :f2_val, :f3 => 4}
      assert_associations_are_included(params, [:order_items, :product])

      params = {:f3 => 4}
      assert_associations_are_included(params, [:product])

      params = {:f2 => :f2_val}
      assert_associations_are_included(params, [:order_items])
    end
  end

  context "where clause filter structure check" do
    should "contain appropriate kind filters - string or hash" do
      table1_name = Order.table_name.to_sym
      table2_name = OrderItem.table_name.to_sym
      table3_name = Product.table_name.to_sym
      params = {:f1 => :f1_val, :f2 => :f2_val, :f3 => 4}
      query_details = Order.emit_inclusion_and_filter_details(params, get_sample_query_spec)

      # Check hash filter exists and its structure
      association_containing_hash_filter = query_details.delete(:order_items)
      assert_equal([{table2_name => {:c2 => :f2_val}}], association_containing_hash_filter)

      # Check string filter exists and its structure
      assert(query_details.all? do |association,filter_details|
        string_where_clause = filter_details.first
        string_where_clause.match(/#{table1_name}.*c1.*f1_val/) or string_where_clause.match(/#{table3_name}.*c3.*4/)
      end)
    end

    should "contain multiple kind of filters for a given association" do
      params = {:f1 => :f1_val, :f2 => :f2_val, :f3 => 4, :f4 => 5}
      query_spec = get_sample_query_spec
      query_spec[:order_items][:f4] = {
          :filter_type => :string, :filter_operator => :eq,
          :source_table_model => OrderItem, :column => :c4
      }

      result = Order.emit_inclusion_and_filter_details(params, query_spec)
      assert_equal(2,result[:order_items].size)
    end

    should "contain join filters" do
      table1_model = Order
      table2_model = OrderItem
      table1_name = table1_model.table_name
      table2_name = table2_model.table_name
      query_spec = get_sample_query_spec
      params = {:f2 => :f2_val, :f3 => 4}

      query_spec[:order_items][:join_filter] = {
          :source_table_model1 => table1_model, :table1_column => :col1,
          :source_table_model2 => table2_model, :table2_column => :col2
      }
      result = Order.emit_inclusion_and_filter_details(params, query_spec)

      assert_equal(2,result[:order_items].size)
      assert(result[:order_items].any? do |filter|
          filter.class == String and filter.match(/#{table1_name}.*col1.*#{table2_name}.*col2.*/)
      end)
    end
  end

  def assert_associations_are_included(params, expected_inclusions)
    query_spec = get_sample_query_spec()
    associations_actually_included, wh_clauses = Order.get_inclusions_and_where_clauses(params, query_spec)
    assert_equal(expected_inclusions, associations_actually_included)
  end

  def get_sample_query_spec
    {
        :self =>
            {
                :f1 =>
                    {
                        :filter_type => :string, :filter_operator => :lt, :column => :c1
                    }
            },
        :order_items =>
            {
                :f2 =>
                    {
                        :filter_type => :hash, :filter_operator => :eq, :column => :c2
                    }
            },
        :product =>
            {
                :f3 =>
                    {
                        :filter_type => :string, :filter_operator => :gteq, :column => :c3
                    }
            }
    }
  end
end
