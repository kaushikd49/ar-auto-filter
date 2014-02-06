require "activerecord-auto_filter/version"
#require "./lib/activerecord-auto_filter/condition_builder"

module Activerecord::Base

  def self.apply_where_clause(params, query_spec)
    ActiveRecord::ConditionBuilder.new.apply_includes_and_where_clauses(params, query_spec)
  end
end
