module WillPaginate
  ***REMOVED*** This is a feature backported from Rails 2.1 because of its usefullness not only with will_paginate,
  ***REMOVED*** but in other aspects when managing complex conditions that you want to be reusable.
  module NamedScope
    ***REMOVED*** All subclasses of ActiveRecord::Base have two named_scopes:
    ***REMOVED*** * <tt>all</tt>, which is similar to a <tt>find(:all)</tt> query, and
    ***REMOVED*** * <tt>scoped</tt>, which allows for the creation of anonymous scopes, on the fly: <tt>Shirt.scoped(:conditions => {:color => 'red'}).scoped(:include => :washing_instructions)</tt>
    ***REMOVED***
    ***REMOVED*** These anonymous scopes tend to be useful when procedurally generating complex queries, where passing
    ***REMOVED*** intermediate values (scopes) around as first-class objects is convenient.
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        named_scope :scoped, lambda { |scope| scope }
      end
    end

    module ClassMethods
      def scopes
        read_inheritable_attribute(:scopes) || write_inheritable_attribute(:scopes, {})
      end

      ***REMOVED*** Adds a class method for retrieving and querying objects. A scope represents a narrowing of a database query,
      ***REMOVED*** such as <tt>:conditions => {:color => :red}, :select => 'shirts.*', :include => :washing_instructions</tt>.
      ***REMOVED***
      ***REMOVED***   class Shirt < ActiveRecord::Base
      ***REMOVED***     named_scope :red, :conditions => {:color => 'red'}
      ***REMOVED***     named_scope :dry_clean_only, :joins => :washing_instructions, :conditions => ['washing_instructions.dry_clean_only = ?', true]
      ***REMOVED***   end
      ***REMOVED*** 
      ***REMOVED*** The above calls to <tt>named_scope</tt> define class methods <tt>Shirt.red</tt> and <tt>Shirt.dry_clean_only</tt>. <tt>Shirt.red</tt>, 
      ***REMOVED*** in effect, represents the query <tt>Shirt.find(:all, :conditions => {:color => 'red'})</tt>.
      ***REMOVED***
      ***REMOVED*** Unlike Shirt.find(...), however, the object returned by <tt>Shirt.red</tt> is not an Array; it resembles the association object
      ***REMOVED*** constructed by a <tt>has_many</tt> declaration. For instance, you can invoke <tt>Shirt.red.find(:first)</tt>, <tt>Shirt.red.count</tt>,
      ***REMOVED*** <tt>Shirt.red.find(:all, :conditions => {:size => 'small'})</tt>. Also, just
      ***REMOVED*** as with the association objects, name scopes acts like an Array, implementing Enumerable; <tt>Shirt.red.each(&block)</tt>,
      ***REMOVED*** <tt>Shirt.red.first</tt>, and <tt>Shirt.red.inject(memo, &block)</tt> all behave as if Shirt.red really were an Array.
      ***REMOVED***
      ***REMOVED*** These named scopes are composable. For instance, <tt>Shirt.red.dry_clean_only</tt> will produce all shirts that are both red and dry clean only.
      ***REMOVED*** Nested finds and calculations also work with these compositions: <tt>Shirt.red.dry_clean_only.count</tt> returns the number of garments
      ***REMOVED*** for which these criteria obtain. Similarly with <tt>Shirt.red.dry_clean_only.average(:thread_count)</tt>.
      ***REMOVED***
      ***REMOVED*** All scopes are available as class methods on the ActiveRecord::Base descendent upon which the scopes were defined. But they are also available to
      ***REMOVED*** <tt>has_many</tt> associations. If,
      ***REMOVED***
      ***REMOVED***   class Person < ActiveRecord::Base
      ***REMOVED***     has_many :shirts
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** then <tt>elton.shirts.red.dry_clean_only</tt> will return all of Elton's red, dry clean
      ***REMOVED*** only shirts.
      ***REMOVED***
      ***REMOVED*** Named scopes can also be procedural.
      ***REMOVED***
      ***REMOVED***   class Shirt < ActiveRecord::Base
      ***REMOVED***     named_scope :colored, lambda { |color|
      ***REMOVED***       { :conditions => { :color => color } }
      ***REMOVED***     }
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** In this example, <tt>Shirt.colored('puce')</tt> finds all puce shirts.
      ***REMOVED***
      ***REMOVED*** Named scopes can also have extensions, just as with <tt>has_many</tt> declarations:
      ***REMOVED***
      ***REMOVED***   class Shirt < ActiveRecord::Base
      ***REMOVED***     named_scope :red, :conditions => {:color => 'red'} do
      ***REMOVED***       def dom_id
      ***REMOVED***         'red_shirts'
      ***REMOVED***       end
      ***REMOVED***     end
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED***
      ***REMOVED*** For testing complex named scopes, you can examine the scoping options using the
      ***REMOVED*** <tt>proxy_options</tt> method on the proxy itself.
      ***REMOVED***
      ***REMOVED***   class Shirt < ActiveRecord::Base
      ***REMOVED***     named_scope :colored, lambda { |color|
      ***REMOVED***       { :conditions => { :color => color } }
      ***REMOVED***     }
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED***   expected_options = { :conditions => { :colored => 'red' } }
      ***REMOVED***   assert_equal expected_options, Shirt.colored('red').proxy_options
      def named_scope(name, options = {})
        name = name.to_sym
        scopes[name] = lambda do |parent_scope, *args|
          Scope.new(parent_scope, case options
            when Hash
              options
            when Proc
              options.call(*args)
          end) { |*a| yield(*a) if block_given? }
        end
        (class << self; self end).instance_eval do
          define_method name do |*args|
            scopes[name].call(self, *args)
          end
        end
      end
    end
    
    class Scope
      attr_reader :proxy_scope, :proxy_options

      [].methods.each do |m|
        unless m =~ /(^__|^nil\?|^send|^object_id$|class|extend|^find$|count|sum|average|maximum|minimum|paginate|first|last|empty\?|respond_to\?)/
          delegate m, :to => :proxy_found
        end
      end

      delegate :scopes, :with_scope, :to => :proxy_scope

      def initialize(proxy_scope, options)
        [options[:extend]].flatten.each { |extension| extend extension } if options[:extend]
        extend Module.new { |*args| yield(*args) } if block_given?
        @proxy_scope, @proxy_options = proxy_scope, options.except(:extend)
      end

      def reload
        load_found; self
      end

      def first(*args)
        if args.first.kind_of?(Integer) || (@found && !args.first.kind_of?(Hash))
          proxy_found.first(*args)
        else
          find(:first, *args)
        end
      end

      def last(*args)
        if args.first.kind_of?(Integer) || (@found && !args.first.kind_of?(Hash))
          proxy_found.last(*args)
        else
          find(:last, *args)
        end
      end

      def empty?
        @found ? @found.empty? : count.zero?
      end

      def respond_to?(method, include_private = false)
        super || @proxy_scope.respond_to?(method, include_private)
      end

      protected
      def proxy_found
        @found || load_found
      end

      private
      def method_missing(method, *args)
        if scopes.include?(method)
          scopes[method].call(self, *args)
        else
          with_scope :find => proxy_options do
            proxy_scope.send(method, *args) { |*a| yield(*a) if block_given? }
          end
        end
      end

      def load_found
        @found = find(:all)
      end
    end
  end
end
