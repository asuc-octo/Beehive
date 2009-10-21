require 'rake/testtask'

desc 'Test the will_paginate plugin.'
Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.libs << 'test'
end

***REMOVED*** I want to specify environment variables at call time
class EnvTestTask < Rake::TestTask
  attr_accessor :env

  def ruby(*args)
    env.each { |key, value| ENV[key] = value } if env
    super
    env.keys.each { |key| ENV.delete key } if env
  end
end

for configuration in %w( sqlite3 mysql postgres )
  EnvTestTask.new("test_***REMOVED***{configuration}") do |t|
    t.pattern = 'test/finder_test.rb'
    t.verbose = true
    t.env = { 'DB' => configuration }
    t.libs << 'test'
  end
end

task :test_databases => %w(test_mysql test_sqlite3 test_postgres)

desc %{Test everything on SQLite3, MySQL and PostgreSQL}
task :test_full => %w(test test_mysql test_postgres)

desc %{Test everything with Rails 2.1.x, 2.0.x & 1.2.x gems}
task :test_all do
  all = Rake::Task['test_full']
  versions = %w(2.3.2 2.2.2 2.1.0 2.0.4 1.2.6)
  versions.each do |version|
    ENV['RAILS_VERSION'] = "~> ***REMOVED***{version}"
    all.invoke
    reset_invoked unless version == versions.last
  end
end

def reset_invoked
  %w( test_full test test_mysql test_postgres ).each do |name|
    Rake::Task[name].instance_variable_set '@already_invoked', false
  end
end

task :rcov do
  excludes = %w( lib/will_paginate/named_scope*
                 lib/will_paginate/core_ext.rb
                 lib/will_paginate.rb
                 rails* )
  
  system %[rcov -I***REMOVED***lib test/*.rb -x ***REMOVED***{excludes.join(',')}]
end
