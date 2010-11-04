module ThinkingSphinx
  module Deltas
    class DefaultDelta
      attr_accessor :column
      
      def initialize(index, options)
        @index  = index
        @column = options.delete(:delta_column) || :delta
      end
      
      def index(model, instance = nil)
        return true unless ThinkingSphinx.updates_enabled? &&
          ThinkingSphinx.deltas_enabled?
        return true if instance && !toggled(instance)
        
        update_delta_indexes model
        delete_from_core     model, instance if instance
        
        true
      end
      
      def toggle(instance)
        instance.delta = true
      end
      
      def toggled(instance)
        instance.delta
      end
      
      def reset_query(model)
        "UPDATE ***REMOVED***{model.quoted_table_name} SET " +
        "***REMOVED***{model.connection.quote_column_name(@column.to_s)} = ***REMOVED***{adapter.boolean(false)} " +
        "WHERE ***REMOVED***{model.connection.quote_column_name(@column.to_s)} = ***REMOVED***{adapter.boolean(true)}"
      end
      
      def clause(model, toggled)
        "***REMOVED***{model.quoted_table_name}.***REMOVED***{model.connection.quote_column_name(@column.to_s)}" +
        " = ***REMOVED***{adapter.boolean(toggled)}"
      end
      
      private
      
      def update_delta_indexes(model)
        config = ThinkingSphinx::Configuration.instance
        rotate = ThinkingSphinx.sphinx_running? ? "--rotate" : ""
        
        output = `***REMOVED***{config.bin_path}***REMOVED***{config.indexer_binary_name} --config "***REMOVED***{config.config_file}" ***REMOVED***{rotate} ***REMOVED***{model.delta_index_names.join(' ')}`
        puts(output) unless ThinkingSphinx.suppress_delta_output?
      end
      
      def delete_from_core(model, instance)
        model.core_index_names.each do |index_name|
          model.delete_in_index index_name, instance.sphinx_document_id
        end
      end
      
      def adapter
        @adapter = @index.model.sphinx_database_adapter
      end
    end
  end
end
