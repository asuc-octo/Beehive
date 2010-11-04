module ThinkingSphinx
  class Source
    module SQL
      ***REMOVED*** Generates the big SQL statement to get the data back for all the fields
      ***REMOVED*** and attributes, using all the relevant association joins. If you want
      ***REMOVED*** the version filtered for delta values, send through :delta => true in the
      ***REMOVED*** options. Won't do much though if the index isn't set up to support a
      ***REMOVED*** delta sibling.
      ***REMOVED*** 
      ***REMOVED*** Examples:
      ***REMOVED*** 
      ***REMOVED***   source.to_sql
      ***REMOVED***   source.to_sql(:delta => true)
      ***REMOVED***
      def to_sql(options={})
        sql = "SELECT "
        sql += "SQL_NO_CACHE " if adapter.sphinx_identifier == "mysql"
        sql += <<-SQL
***REMOVED***{ sql_select_clause options[:offset] }
FROM ***REMOVED***{ @model.quoted_table_name }
  ***REMOVED***{ all_associations.collect { |assoc| assoc.to_sql }.join(' ') }
***REMOVED***{ sql_where_clause(options) }
GROUP BY ***REMOVED***{ sql_group_clause }
        SQL

        sql += " ORDER BY NULL" if adapter.sphinx_identifier == "mysql"
        sql
      end

      ***REMOVED*** Simple helper method for the query range SQL - which is a statement that
      ***REMOVED*** returns minimum and maximum id values. These can be filtered by delta -
      ***REMOVED*** so pass in :delta => true to get the delta version of the SQL.
      ***REMOVED*** 
      def to_sql_query_range(options={})
        return nil if @index.options[:disable_range]
        
        min_statement = adapter.convert_nulls(
          "MIN(***REMOVED***{quote_column(@model.primary_key_for_sphinx)})", 1
        )
        max_statement = adapter.convert_nulls(
          "MAX(***REMOVED***{quote_column(@model.primary_key_for_sphinx)})", 1
        )

        sql = "SELECT ***REMOVED***{min_statement}, ***REMOVED***{max_statement} " +
              "FROM ***REMOVED***{@model.quoted_table_name} "
        if self.delta? && !@index.delta_object.clause(@model, options[:delta]).blank?
          sql << "WHERE ***REMOVED***{@index.delta_object.clause(@model, options[:delta])}"
        end

        sql
      end

      ***REMOVED*** Simple helper method for the query info SQL - which is a statement that
      ***REMOVED*** returns the single row for a corresponding id.
      ***REMOVED*** 
      def to_sql_query_info(offset)
        "SELECT * FROM ***REMOVED***{@model.quoted_table_name} WHERE " +
        "***REMOVED***{quote_column(@model.primary_key_for_sphinx)} = (($id - ***REMOVED***{offset}) / ***REMOVED***{ThinkingSphinx.context.indexed_models.size})"
      end

      def sql_select_clause(offset)
        unique_id_expr = ThinkingSphinx.unique_id_expression(offset)

        (
          ["***REMOVED***{@model.quoted_table_name}.***REMOVED***{quote_column(@model.primary_key_for_sphinx)} ***REMOVED***{unique_id_expr} AS ***REMOVED***{quote_column(@model.primary_key_for_sphinx)} "] + 
          @fields.collect     { |field|     field.to_select_sql     } +
          @attributes.collect { |attribute| attribute.to_select_sql }
        ).compact.join(", ")
      end

      def sql_where_clause(options)
        logic = []
        logic += [
          "***REMOVED***{@model.quoted_table_name}.***REMOVED***{quote_column(@model.primary_key_for_sphinx)} >= $start",
          "***REMOVED***{@model.quoted_table_name}.***REMOVED***{quote_column(@model.primary_key_for_sphinx)} <= $end"
        ] unless @index.options[:disable_range]

        if self.delta? && !@index.delta_object.clause(@model, options[:delta]).blank?
          logic << "***REMOVED***{@index.delta_object.clause(@model, options[:delta])}"
        end

        logic += (@conditions || [])
        logic.empty? ? "" : "WHERE ***REMOVED***{logic.join(' AND ')}"
      end

      def sql_group_clause
        internal_groupings = []
        if @model.column_names.include?(@model.inheritance_column)
           internal_groupings << "***REMOVED***{@model.quoted_table_name}.***REMOVED***{quote_column(@model.inheritance_column)}"
        end

        (
          ["***REMOVED***{@model.quoted_table_name}.***REMOVED***{quote_column(@model.primary_key_for_sphinx)}"] + 
          @fields.collect     { |field|     field.to_group_sql     }.compact +
          @attributes.collect { |attribute| attribute.to_group_sql }.compact +
          @groupings + internal_groupings
        ).join(", ")
      end

      def sql_query_pre_for_core
        if self.delta? && !@index.delta_object.reset_query(@model).blank?
          [@index.delta_object.reset_query(@model)]
        else
          []
        end
      end

      def sql_query_pre_for_delta
        [""]
      end

      def quote_column(column)
        @model.connection.quote_column_name(column)
      end

      def crc_column
        if @model.table_exists? &&
          @model.column_names.include?(@model.inheritance_column)
          
          adapter.cast_to_unsigned(adapter.convert_nulls(
            adapter.crc(adapter.quote_with_table(@model.inheritance_column), true),
            @model.to_crc32
          ))
        else
          @model.to_crc32.to_s
        end
      end
    end
  end
end