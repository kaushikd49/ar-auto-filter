require "rubygems"
require 'active_record'
require 'active_support/all'
require 'bundler/setup'
require "shoulda"
require "test/unit"
require "ar_cond_gen"
require_relative "helpers/db_setup_helper"

class ActiveRecordConditionBuilderTest < Test::Unit::TestCase
  include DbSetupHelper

  def setup
    super
    @builder = ActiveRecordConditionBuilder.new
    do_db_setups
  end

  context "inclusions check" do
    should "contain only expected associations for inclusions" do
      params = {:f1 => "f1_val", :f2 => "f2_val", :f3 => 4, :f4 => 41}
      1.upto(params.size) do
        assert_result_content(params)
        params.shift
      end
    end
  end

  context "where clause filter structure check" do
    should "contain appropriate kind filters - string or hash" do
      params = {:f1 => "f1_val", :f2 => "f2_val", :f3 => 4}
      result = get_build_result(params).last
      query_details = result[:root_model]

      # Check string filter exists and its structure
      association_containing_hash_filter = query_details.delete(:association2)
      assert_equal([{:t2 => {:c2 => "f2_val"}}], association_containing_hash_filter)

      # Check hash filter exists and its structure
      assert(query_details.all? do |association,filter_details|
        string_where_clause = filter_details.first
        string_where_clause.match(/t1.*c1.*f1_val/) or string_where_clause.match(/t3.*c3.*4/)
      end)
    end

    should "contain multiple kind of filters for a given association" do
      params = {:f1 => "f1_val", :f2 => "f2_val", :f3 => 4, :f4 => 5}
      query_spec = get_sample_query_spec
      query_spec[:root_model][:association2][:f4] =
          {
            :filter_type => :string, :filter_operator => :eq,
            :source_table => :t4, :column => :c4
          }

      result = @builder.emit_inclusion_and_filter_details(params, query_spec)
      assert_equal(2,result[:root_model][:association2].size)
    end

    should "contain join filters" do
      params = {:f2 => "f2_val", :f3 => 4}
      query_spec = get_sample_query_spec
      query_spec[:root_model][:association2][:join_filter] =
          {
             :source_table1 => :table1_name, :table1_column => :col1,
             :source_table2 => :table2_name, :table2_column => :col2,
          }
      result = @builder.emit_inclusion_and_filter_details(params, query_spec)

      assert_equal(2,result[:root_model][:association2].size)
      assert(result[:root_model][:association2].any? do |filter|
          filter.class == String and filter.match(/table1_name.*col1.*table2_name.*col2.*/)
      end)
    end
  end

  def assert_result_content(params)
    query_spec, result = get_build_result(params)
    associations_to_include = result[:root_model].keys
    associations_mapped_by_params = query_spec[:root_model].select do |association,filter_field_hash|
      (filter_field_hash.keys & params.keys).present?
    end.keys

    assert_equal(associations_to_include, associations_mapped_by_params)
  end

  def get_build_result(params)
    query_spec = get_sample_query_spec
    result = @builder.emit_inclusion_and_filter_details(params, query_spec)
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
                                :source_table => :t1, :column => :c1
                            }
                    },
                :association2 =>
                    {
                        :f2 =>
                            {
                                :filter_type => :hash, :filter_operator => :eq,
                                :source_table => :t2, :column => :c2
                            }
                    },
                :association3 =>
                    {
                        :f3 =>
                            {
                                :filter_type => :string, :filter_operator => :gteq,
                                :source_table => :t3, :column => :c3
                            }
                    }
            }
    }
  end
end
