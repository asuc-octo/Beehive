module AfterCommit
  module ConnectionAdapters
    def self.included(base)
      base.class_eval do
        ***REMOVED*** The commit_db_transaction method gets called when the outermost
        ***REMOVED*** transaction finishes and everything inside commits. We want to
        ***REMOVED*** override it so that after this happens, any records that were saved
        ***REMOVED*** or destroyed within this transaction now get their after_commit
        ***REMOVED*** callback fired.
        def commit_db_transaction_with_callback
          increment_transaction_pointer
          committed = false
          result    = nil
          begin
            trigger_before_commit_callbacks
            trigger_before_commit_on_create_callbacks
            trigger_before_commit_on_update_callbacks
            trigger_before_commit_on_destroy_callbacks
            
            result = commit_db_transaction_without_callback
            committed = true
            
            trigger_after_commit_callbacks
            trigger_after_commit_on_create_callbacks
            trigger_after_commit_on_update_callbacks
            trigger_after_commit_on_destroy_callbacks
            result
          rescue
            committed ? result : rollback_db_transaction
          ensure
            AfterCommit.cleanup(self)
            decrement_transaction_pointer
          end
        end 
        alias_method_chain :commit_db_transaction, :callback

        ***REMOVED*** In the event the transaction fails and rolls back, nothing inside
        ***REMOVED*** should recieve the after_commit callback, but do fire the after_rollback
        ***REMOVED*** callback for each record that failed to be committed.
        def rollback_db_transaction_with_callback
          begin
            result = nil
            trigger_before_rollback_callbacks
            result = rollback_db_transaction_without_callback
            trigger_after_rollback_callbacks
            result
          ensure
            AfterCommit.cleanup(self)
          end
        end
        alias_method_chain :rollback_db_transaction, :callback
        
        def unique_transaction_key
          [object_id, transaction_pointer]
        end
        
        def old_transaction_key
          [object_id, transaction_pointer - 1]
        end
        
        protected
        
        def trigger_before_commit_callbacks
          AfterCommit.records(self).each do |record|
            record.send :callback, :before_commit
          end 
        end

        def trigger_before_commit_on_create_callbacks
          AfterCommit.created_records(self).each do |record|
            record.send :callback, :before_commit_on_create
          end 
        end
      
        def trigger_before_commit_on_update_callbacks
          AfterCommit.updated_records(self).each do |record|
            record.send :callback, :before_commit_on_update
          end 
        end
      
        def trigger_before_commit_on_destroy_callbacks
          AfterCommit.destroyed_records(self).each do |record|
            record.send :callback, :before_commit_on_destroy
          end 
        end

        def trigger_before_rollback_callbacks
          AfterCommit.records(self).each do |record|
            begin
              record.send :callback, :before_rollback
            rescue
              ***REMOVED***
            end
          end 
        end

        def trigger_after_commit_callbacks
          ***REMOVED*** Trigger the after_commit callback for each of the committed
          ***REMOVED*** records.
          AfterCommit.records(self).each do |record|
            begin
              record.send :callback, :after_commit
            rescue
              ***REMOVED***
            end
          end
        end
      
        def trigger_after_commit_on_create_callbacks
          ***REMOVED*** Trigger the after_commit_on_create callback for each of the committed
          ***REMOVED*** records.
          AfterCommit.created_records(self).each do |record|
            begin
              record.send :callback, :after_commit_on_create
            rescue
              ***REMOVED***
            end
          end
        end
      
        def trigger_after_commit_on_update_callbacks
          ***REMOVED*** Trigger the after_commit_on_update callback for each of the committed
          ***REMOVED*** records.
          AfterCommit.updated_records(self).each do |record|
            begin
              record.send :callback, :after_commit_on_update
            rescue
              ***REMOVED***
            end
          end
        end
      
        def trigger_after_commit_on_destroy_callbacks
          ***REMOVED*** Trigger the after_commit_on_destroy callback for each of the committed
          ***REMOVED*** records.
          AfterCommit.destroyed_records(self).each do |record|
            begin
              record.send :callback, :after_commit_on_destroy
            rescue
              ***REMOVED***
            end
          end
        end

        def trigger_after_rollback_callbacks
          ***REMOVED*** Trigger the after_rollback callback for each of the committed
          ***REMOVED*** records.
          AfterCommit.records(self).each do |record|
            begin
              record.send :callback, :after_rollback
            rescue
            end
          end 
        end
        
        def transaction_pointer
          Thread.current[:after_commit_pointer] ||= 0
        end
        
        def increment_transaction_pointer
          Thread.current[:after_commit_pointer] ||= 0
          Thread.current[:after_commit_pointer] += 1
        end
        
        def decrement_transaction_pointer
          Thread.current[:after_commit_pointer] ||= 0
          Thread.current[:after_commit_pointer] -= 1
        end
      end 
    end 
  end
end
