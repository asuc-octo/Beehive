***REMOVED*** 
***REMOVED*** = Capistrano database.yml task
***REMOVED***
***REMOVED*** Provides a couple of tasks for creating the database.yml 
***REMOVED*** configuration file dynamically when deploy:setup is run.
***REMOVED***
***REMOVED*** Category::    Capistrano
***REMOVED*** Package::     Database
***REMOVED*** Author::      Simone Carletti <weppos@weppos.net>
***REMOVED*** Copyright::   2007-2010 The Authors
***REMOVED*** License::     MIT License
***REMOVED*** Link::        http://www.simonecarletti.com/
***REMOVED*** Source::      http://gist.github.com/2769
***REMOVED***
***REMOVED***
***REMOVED*** == Requirements
***REMOVED***
***REMOVED*** This extension requires the original <tt>config/database.yml</tt> to be excluded
***REMOVED*** from source code checkout. You can easily accomplish this by renaming
***REMOVED*** the file (for example to database.example.yml) and appending <tt>database.yml</tt>
***REMOVED*** value to your SCM ignore list.
***REMOVED***
***REMOVED***   ***REMOVED*** Example for Subversion
***REMOVED***
***REMOVED***   $ svn mv config/database.yml config/database.example.yml
***REMOVED***   $ svn propset svn:ignore 'database.yml' config
***REMOVED***
***REMOVED***   ***REMOVED*** Example for Git
***REMOVED***
***REMOVED***   $ git mv config/database.yml config/database.example.yml
***REMOVED***   $ echo 'config/database.yml' >> .gitignore 
***REMOVED***
***REMOVED*** 
***REMOVED*** == Usage
***REMOVED*** 
***REMOVED*** Include this file in your <tt>deploy.rb</tt> configuration file.
***REMOVED*** Assuming you saved this recipe as capistrano_database_yml.rb:
***REMOVED*** 
***REMOVED***   require "capistrano_database_yml"
***REMOVED*** 
***REMOVED*** Now, when <tt>deploy:setup</tt> is called, this script will automatically
***REMOVED*** create the <tt>database.yml</tt> file in the shared folder.
***REMOVED*** Each time you run a deploy, this script will also create a symlink
***REMOVED*** from your application <tt>config/database.yml</tt> pointing to the shared configuration file. 
***REMOVED*** 
***REMOVED*** == Custom template
***REMOVED*** 
***REMOVED*** By default, this script creates an exact copy of the default
***REMOVED*** <tt>database.yml</tt> file shipped with a new Rails 2.x application.
***REMOVED*** If you want to overwrite the default template, simply create a custom Erb template
***REMOVED*** called <tt>database.yml.erb</tt> and save it into <tt>config/deploy</tt> folder.
***REMOVED*** 
***REMOVED*** Although the name of the file can't be changed, you can customize the directory
***REMOVED*** where it is stored defining a variable called <tt>:template_dir</tt>.
***REMOVED*** 
***REMOVED***   ***REMOVED*** store your custom template at foo/bar/database.yml.erb
***REMOVED***   set :template_dir, "foo/bar"
***REMOVED*** 
***REMOVED***   ***REMOVED*** example of database template
***REMOVED***   
***REMOVED***   base: &base
***REMOVED***     adapter: sqlite3
***REMOVED***     timeout: 5000
***REMOVED***   ***REMOVED***
***REMOVED***     database: ***REMOVED***{shared_path}/db/development.sqlite3
***REMOVED***     <<: *base
***REMOVED***   ***REMOVED***
***REMOVED***     database: ***REMOVED***{shared_path}/db/test.sqlite3
***REMOVED***     <<: *base
***REMOVED***   ***REMOVED***
***REMOVED***     adapter: mysql
***REMOVED***     database: ***REMOVED***{application}_production
***REMOVED***     username: ***REMOVED***{user}
***REMOVED***     password: ***REMOVED***{Capistrano::CLI.ui.ask("Enter MySQL database password: ")}
***REMOVED***     encoding: utf8
***REMOVED***     timeout: 5000
***REMOVED***
***REMOVED*** Because this is an Erb template, you can place variables and Ruby scripts
***REMOVED*** within the file.
***REMOVED*** For instance, the template above takes advantage of Capistrano CLI
***REMOVED*** to ask for a MySQL database password instead of hard coding it into the template.
***REMOVED***
***REMOVED*** === Password prompt
***REMOVED***
***REMOVED*** For security reasons, in the example below the password is not
***REMOVED*** hard coded (or stored in a variable) but asked on setup.
***REMOVED*** I don't like to store passwords in files under version control
***REMOVED*** because they will live forever in your history.
***REMOVED*** This is why I use the Capistrano::CLI utility.
***REMOVED***

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :deploy do

    namespace :db do

      desc <<-DESC
        Creates the database.yml configuration file in shared path.

        By default, this task uses a template unless a template \
        called database.yml.erb is found either is :template_dir \
        or /config/deploy folders. The default template matches \
        the template for config/database.yml file shipped with Rails.

        When this recipe is loaded, db:setup is automatically configured \
        to be invoked after deploy:setup. You can skip this task setting \
        the variable :skip_db_setup to true. This is especially useful \ 
        if you are using this recipe in combination with \
        capistrano-ext/multistaging to avoid multiple db:setup calls \ 
        when running deploy:setup for all stages one by one.
      DESC
      task :setup, :except => { :no_release => true } do

        default_template = <<-EOF
        base: &base
          adapter: sqlite3
          timeout: 5000
        ***REMOVED***
          database: ***REMOVED***{shared_path}/db/development.sqlite3
          <<: *base
        ***REMOVED***
          database: ***REMOVED***{shared_path}/db/test.sqlite3
          <<: *base
        ***REMOVED***
          database: ***REMOVED***{shared_path}/db/production.sqlite3
          <<: *base
        EOF

        location = fetch(:template_dir, "config") + '/database.yml.erb'
        template = File.file?(location) ? File.read(location) : default_template

        config = ERB.new(template)

        run "mkdir -p ***REMOVED***{shared_path}/db" 
        run "mkdir -p ***REMOVED***{shared_path}/config" 
        put config.result(binding), "***REMOVED***{shared_path}/config/database.yml"
      end

      desc <<-DESC
        [internal] Updates the symlink for database.yml file to the just deployed release.
      DESC
      task :symlink, :except => { :no_release => true } do
        run "ln -nfs ***REMOVED***{shared_path}/config/database.yml ***REMOVED***{release_path}/config/database.yml" 
      end

    end

    after "deploy:setup",           "deploy:db:setup"   unless fetch(:skip_db_setup, false)
    after "deploy:finalize_update", "deploy:db:symlink"

  end

end
