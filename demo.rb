require 'bundler/setup'
require "logger"
require "./lib/activerecord-auto_filter"
require_relative "test/helpers/data_layer_setup"

include DataLayerSetup

QUERY_SPEC = {
    :self =>
        {
            :product_id =>
                {
                    :filter_operator => :eq, :column => :product_id
                }
        },
    :order_items =>
        {
            :state =>
                {
                    :filter_operator => :eq, :column => :state
                }
        },
    :product =>
        {
            :vertical =>
                {
                    :filter_operator => :eq, :column => :vertical
                },
            :price_from =>
                {
                    :filter_operator => :gteq, :column => :selling_price
                },
            :price_to =>
                {
                    :filter_operator => :lt, :column => :selling_price
                }
        },
    :order_item_units =>
        {
            :size =>
                {
                    :filter_operator => :eq, :column => :size
                }
        }
}

def demo
  pretty_print("DB setups started")
  setup_datalayer(true)
  pretty_print("DB setups complete")
  run_demo_with_joins
  run_demo_with_no_joins
end

def run_demo_with_joins
  pretty_print("Demo with joins")
  params = {:vertical => :book, :price_from => 100, :price_to => 600, :size => 100, :state => :approved}
  generate_demo(params)
end

def run_demo_with_no_joins
  pretty_print("Demo without joins")
  params = {:product_id => :f1}
  generate_demo(params)
end

def generate_demo(params)
  ar_with_query_builded = Order.apply_includes_and_where_clauses(params, QUERY_SPEC)
  puts  "Params for this demo are #{params}"
  pretty_print("Final query generated is below")
  ar_with_query_builded.inspect
  puts "\n"
end

def pretty_print(string)
  num_stars = (100-string.size)/2
  puts "\n" + "*" * num_stars + " #{string} " + "*" * num_stars + "\n"
end


demo()