require 'active_support'
require 'will_paginate/core_ext'

***REMOVED*** = You *will* paginate!
***REMOVED***
***REMOVED*** First read about WillPaginate::Finder::ClassMethods, then see
***REMOVED*** WillPaginate::ViewHelpers. The magical array you're handling in-between is
***REMOVED*** WillPaginate::Collection.
***REMOVED***
***REMOVED*** Happy paginating!
module WillPaginate
  class << self
    ***REMOVED*** shortcut for <tt>enable_actionpack</tt> and <tt>enable_activerecord</tt> combined
    def enable
      enable_actionpack
      enable_activerecord
    end
    
    ***REMOVED*** hooks WillPaginate::ViewHelpers into ActionView::Base
    def enable_actionpack
      return if ActionView::Base.instance_methods.include_method? :will_paginate
      require 'will_paginate/view_helpers'
      ActionView::Base.send :include, ViewHelpers

      if defined?(ActionController::Base) and ActionController::Base.respond_to? :rescue_responses
        ActionController::Base.rescue_responses['WillPaginate::InvalidPage'] = :not_found
      end
    end
    
    ***REMOVED*** hooks WillPaginate::Finder into ActiveRecord::Base and classes that deal
    ***REMOVED*** with associations
    def enable_activerecord
      return if ActiveRecord::Base.respond_to? :paginate
      require 'will_paginate/finder'
      ActiveRecord::Base.send :include, Finder

      ***REMOVED*** support pagination on associations
      a = ActiveRecord::Associations
      returning([ a::AssociationCollection ]) { |classes|
        ***REMOVED*** detect http://dev.rubyonrails.org/changeset/9230
        unless a::HasManyThroughAssociation.superclass == a::HasManyAssociation
          classes << a::HasManyThroughAssociation
        end
      }.each do |klass|
        klass.send :include, Finder::ClassMethods
        klass.class_eval { alias_method_chain :method_missing, :paginate }
      end
      
      ***REMOVED*** monkeypatch Rails ticket ***REMOVED***2189: "count breaks has_many :through"
      ActiveRecord::Base.class_eval do
        protected
        def self.construct_count_options_from_args(*args)
          result = super
          result[0] = '*' if result[0].is_a?(String) and result[0] =~ /\.\*$/
          result
        end
      end
    end

    ***REMOVED*** Enable named_scope, a feature of Rails 2.1, even if you have older Rails
    ***REMOVED*** (tested on Rails 2.0.2 and 1.2.6).
    ***REMOVED***
    ***REMOVED*** You can pass +false+ for +patch+ parameter to skip monkeypatching
    ***REMOVED*** *associations*. Use this if you feel that <tt>named_scope</tt> broke
    ***REMOVED*** has_many, has_many :through or has_and_belongs_to_many associations in
    ***REMOVED*** your app. By passing +false+, you can still use <tt>named_scope</tt> in
    ***REMOVED*** your models, but not through associations.
    def enable_named_scope(patch = true)
      return if defined? ActiveRecord::NamedScope
      require 'will_paginate/named_scope'
      require 'will_paginate/named_scope_patch' if patch

      ActiveRecord::Base.send :include, WillPaginate::NamedScope
    end
  end

  module Deprecation ***REMOVED*** :nodoc:
    extend ActiveSupport::Deprecation

    def self.warn(message, callstack = caller)
      message = 'WillPaginate: ' + message.strip.gsub(/\s+/, ' ')
      ActiveSupport::Deprecation.warn(message, callstack)
    end
  end
end

if defined? Rails
  WillPaginate.enable_activerecord if defined? ActiveRecord
  WillPaginate.enable_actionpack if defined? ActionController
end
