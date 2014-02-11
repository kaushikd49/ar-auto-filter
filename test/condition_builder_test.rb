require "rubygems"
require 'bundler/setup'
require "shoulda"
require 'test/unit'
require "activerecord-auto_filter"

require_relative "helpers/db_setup_helper"
require_relative "../lib/activerecord-auto_filter/condition_builder"

class ConditionBuilderTest < Test::Unit::TestCase
  include DbSetupHelper # Arel has a dependency on db connection
  include ActiveRecord::ConditionBuilder

  class ModelA < ActiveRecord::Base; end
  class ModelB < ActiveRecord::Base; end
  class ModelC < ActiveRecord::Base; end

  def setup
    super
    do_db_setups
  end


  context "inclusions check" do
    should "contain only expected associations for inclusions" do
      params = {:f1 => :f1_val, :f2 => :f2_val, :f3 => 4, :f4 => 41}
      assert_associations_are_included(params, [:association2, :association3])

      params = {:f1 => :f1_val, :f2 => :f2_val, :f3 => 4}
      assert_associations_are_included(params, [:association2, :association3])

      params = {:f2 => :f2_val, :f3 => 4}
      assert_associations_are_included(params, [:association2, :association3])

      params = {:f3 => 4}
      assert_associations_are_included(params, [:association3])

      params = {:f2 => :f2_val}
      assert_associations_are_included(params, [:association2])
    end
  end

  context "where clause filter structure check" do
    should "contain appropriate kind filters - string or hash" do
      table1_name = ModelA.table_name.to_sym
      table2_name = ModelB.table_name.to_sym
      table3_name = ModelC.table_name.to_sym
      params = {:f1 => :f1_val, :f2 => :f2_val, :f3 => 4}
      query_details = get_generated_conditions(params).last

      # Check hash filter exists and its structure
      association_containing_hash_filter = query_details.delete(:association2)
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
      query_spec[:association2][:f4] = {
          :filter_type => :string, :filter_operator => :eq,
          :source_table_model => ModelB, :column => :c4
      }

      result = emit_inclusion_and_filter_details(params, query_spec)
      assert_equal(2,result[:association2].size)
    end

    should "contain join filters" do
      table1_model = ModelA
      table2_model = ModelB
      table1_name = table1_model.table_name
      table2_name = table2_model.table_name
      query_spec = get_sample_query_spec
      params = {:f2 => :f2_val, :f3 => 4}

      query_spec[:association2][:join_filter] = {
          :source_table_model1 => table1_model, :table1_column => :col1,
             :source_table_model2 => table2_model, :table2_column => :col2
      }
      result = emit_inclusion_and_filter_details(params, query_spec)

      assert_equal(2,result[:association2].size)
      assert(result[:association2].any? do |filter|
          filter.class == String and filter.match(/#{table1_name}.*col1.*#{table2_name}.*col2.*/)
      end)
    end
  end

  def assert_associations_are_included(params, expected_inclusions)
    query_spec = get_sample_query_spec()
    associations_actually_included, wh_clauses = get_inclusions_and_where_clauses(params, query_spec)
    assert_equal(expected_inclusions, associations_actually_included)
  end

  def get_generated_conditions(params)
    query_spec = get_sample_query_spec
    result = emit_inclusion_and_filter_details(params, query_spec)
    return query_spec, result
  end

  def get_sample_query_spec
    {
        :self =>
            {
                :f1 =>
                    {
                        :filter_type => :string, :filter_operator => :lt,
                        :source_table_model => ModelA, :column => :c1
                    }
            },
        :association2 =>
            {
                :f2 =>
                    {
                        :filter_type => :hash, :filter_operator => :eq,
                        :source_table_model => ModelB, :column => :c2
                    }
            },
        :association3 =>
            {
                :f3 =>
                    {
                        :filter_type => :string, :filter_operator => :gteq,
                        :source_table_model => ModelC, :column => :c3
                    }
            }
    }
  end
end
