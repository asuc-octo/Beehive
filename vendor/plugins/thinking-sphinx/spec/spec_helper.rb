$:.unshift File.dirname(__FILE__) + '/../lib'
Dir[File.join(File.dirname(__FILE__), '../vendor/*/lib')].each do |path|
  $:.unshift path
end

require 'rubygems'
require 'fileutils'
require 'ginger'
require 'jeweler'

require "***REMOVED***{File.dirname(__FILE__)}/../lib/thinking_sphinx"

require 'will_paginate'

require "***REMOVED***{File.dirname(__FILE__)}/sphinx_helper"

ActiveRecord::Base.logger = Logger.new(StringIO.new)

Spec::Runner.configure do |config|
  %w( tmp tmp/config tmp/log tmp/db ).each do |path|
    FileUtils.mkdir_p "***REMOVED***{Dir.pwd}/***REMOVED***{path}"
  end
  
  Kernel.const_set :RAILS_ROOT, "***REMOVED***{Dir.pwd}/tmp" unless defined?(RAILS_ROOT)
  
  sphinx = SphinxHelper.new
  sphinx.setup_mysql
  
  require "***REMOVED***{File.dirname(__FILE__)}/fixtures/models"
  ThinkingSphinx.context.define_indexes
  
  config.before :all do
    %w( tmp tmp/config tmp/log tmp/db ).each do |path|
      FileUtils.mkdir_p "***REMOVED***{Dir.pwd}/***REMOVED***{path}"
    end
    
    ThinkingSphinx.updates_enabled = true
    ThinkingSphinx.deltas_enabled = true
    ThinkingSphinx.suppress_delta_output = true
    
    ThinkingSphinx::Configuration.instance.reset
    ThinkingSphinx::Configuration.instance.database_yml_file = "spec/fixtures/sphinx/database.yml"
  end
  
  config.after :all do
    FileUtils.rm_r "***REMOVED***{Dir.pwd}/tmp" rescue nil
  end
end

def minimal_result_hashes(*instances)
  instances.collect do |instance|
    {
      :weight     => 21,
      :attributes => {
        'sphinx_internal_id' => instance.id,
        'class_crc'          => instance.class.name.to_crc32
      }
    }
  end
end
