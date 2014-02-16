require 'active_record'
require "active_record/version"
require "./lib/activerecord-auto_filter/version"

class ActiveRecord::Base

  class << self


    ################################# Generic where clause and inclusion builder ###########################
    # Query specification format
    #
    #    {
    #         :self =>
    #           {
    #             <param_field> =>
    #               {
    #                 :filter_type => <:string|:hash>, :filter_operator => <:gt|:lt|:gteq|:lteq:in:not_in>,
    #                 :source_table_model => <ar_class>, :column => <col_name_sym>
    #               }
    #           }
    #         :association1 =>
    #           {
    #             <param_field> =>
    #               {
    #                 :filter_type => <:string|:hash>, :filter_operator => <:gt|:lt|:gteq|:lteq|:in|:not_in>,
    #                 :source_table_model => <ar_class>, :column => <col_name_sym>
    #               },
    #             ...
    #             :join_filter =>
    #               {
    #                 :source_table_model1 => <ar_class>, :table1_column => <column_name>,
    #                 :source_table_model2 => <ar_class>, :table2_column => <column_name>,
    #               },
    #             :is_inclusion_mandatory => <true|false>
    #           },
    #         ...
    #     }

  def apply_includes_and_where_clauses(params,query_spec)
      model = self
      inclusions, where_clauses = get_inclusions_and_where_clauses(params,query_spec)

      active_record = model.includes(inclusions)
      where_clauses.each { |e| active_record = active_record.where(e) }
      active_record
    end

    def get_inclusions_and_where_clauses(params,query_spec)
      result = emit_inclusion_and_filter_details(params,query_spec)
      inclusions = result.keys - [:self]
      where_clause_filters = result.values.flatten

      [inclusions, where_clause_filters]
    end

    def emit_inclusion_and_filter_details(params,query_spec)
      exclusions = [:join_filter,:is_inclusion_mandatory]
      query_spec.each_with_object({}) do |(association,association_filter_spec), res|
        join_spec, is_inclusion_mandatory = association_filter_spec.values_at(*exclusions)
        new_association_filter_spec = association_filter_spec.reject{|e| exclusions.include?(e)}
        association_model = (association == :self)? self : self.reflect_on_association(association.to_sym).klass
        join_filter = get_association_join_filter(join_spec, self, association_model)

        where_clause_filters =
            new_association_filter_spec.each_with_object([]) do |(param_field,filter_spec),filter_res|
              value = params[param_field]
              if value.present?
                filter_res << get_where_clause_filter(filter_spec, query_spec, value, association_model)
              end
            end

        if where_clause_filters.present?
          res[association] =  where_clause_filters
          res[association] << join_filter if join_filter.present?
        elsif is_inclusion_mandatory
          res[association] = (join_filter.present?)? [join_filter] : []
        end
      end
    end

    private
    def get_association_join_filter(join_filter, table1, table2)
      return if join_filter.blank?
      table1_col,table2_col = join_filter.values_at(:table1_column,:table2_column)
      get_where_clause_sql(table2.arel_table[table2_col], table1, table1_col, :eq)
    end

    def get_where_clause_filter(filter_spec, query_spec, value, table)
      case filter_spec[:filter_type]
        when :string
          construct_str_filter(value, filter_spec, table)
        when :hash
          construct_hash_filter(value, filter_spec, table)
        else
          raise Exception.new("Improper filter_type in #{query_spec}")
      end
    end

    def construct_str_filter(arg_value, filter_spec, table)
      operator, column = filter_spec.values_at(:filter_operator,:column)
      get_where_clause_sql(arg_value, table, column, operator)
    end

    def get_where_clause_sql(arg_value, table, column, operator)
      table_arel = table.arel_table
      sql = table_arel.where(table_arel[column].send(operator, arg_value)).to_sql
      sql.split("WHERE").last
    end

    def construct_hash_filter(arg_value, filter_spec, table)
      column = filter_spec[:column]
      hash_filter = {column => arg_value}
      (table != :self)? {table.table_name.to_sym => hash_filter} : hash_filter
    end
  end
end
