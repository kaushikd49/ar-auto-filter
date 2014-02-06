require 'rubygems'
require 'bundler/setup'
require 'active_record'
require "activerecord-auto_filter"
require_relative "test/helpers/sample_model_definitions"
require_relative "test/helpers/db_setup_helper"


#temp
require "./lib/activerecord-auto_filter/condition_builder"


include SampleModelDefinitions
include DbSetupHelper

def run_demo
  do_db_setups(true)
  create_tables()

  params = {:vertical => :book, :price_from => 100, :price_to => 600, :size => 100, :state => :approved}
  ar_with_query_builded = ActiveRecord::ConditionBuilder.new.apply_includes_and_where_clauses(params,get_query_spec)
  
  str = "\n" + "*"*40 + " Final query generated " + "*"*40 + "\n"
  puts str; ar_with_query_builded.inspect; puts
end


def create_tables
  ActiveRecord::Schema.define(:version => 20140124132738) do
    create_table :orders, :force => true do |t|
      t.text :user
      t.integer :quantity, :default => true
    end

    create_table :order_items, :force => true do |t|
      t.string :state
      t.integer :quantity
      t.references :order
    end

    create_table :order_item_units, :force => true do |t|
      t.integer :size, :default => true
      t.references :order_item
    end

    create_table :products, :force => true do |t|
      t.string :vertical
      t.integer :selling_price
      t.references :order
    end
  end
end


def get_query_spec
  {
      Order =>
          {
              :self =>
                  {
                      :fsn =>
                          {
                              :filter_type => :hash, :filter_operator => :eq,
                              :source_table_model => Order, :column => :fsn
                          }
                  },
              :order_items =>
                  {
                      :state =>
                          {
                              :filter_type => :hash, :filter_operator => :eq,
                              :source_table_model => OrderItem, :column => :state
                          }
                  },
              :product =>
                  {
                      :vertical =>
                          {
                              :filter_type => :hash, :filter_operator => :eq,
                              :source_table_model => Product, :column => :vertical
                          },
                      :price_from =>
                          {
                              :filter_type => :string, :filter_operator => :gteq,
                              :source_table_model => Product, :column => :selling_price
                          },
                      :price_to =>
                          {
                              :filter_type => :string, :filter_operator => :lt,
                              :source_table_model => Product, :column => :selling_price
                          }
                  },
              :order_item_units =>
                  {
                      :size =>
                          {
                              :filter_type => :hash, :filter_operator => :eq,
                              :source_table_model => OrderItemUnit, :column => :size
                          }
                  }
          }
  }
end




run_demo

