require "***REMOVED***{File.dirname(__FILE__)}/capistrano_database"

set :application, "researchmatch"
set :repository,  "git://github.com/jonathank/ResearchMatch.git"
set :scm, "git"
***REMOVED*** Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :branch, "rails3"

set :machine_name, "upe.cs.berkeley.edu"

***REMOVED*** Directory for deployment on the production (remote) machine.
set :deploy_to, "/home/amber/researchmatch/"

role :web, "***REMOVED***{machine_name}"                          ***REMOVED*** Your HTTP server, Apache/etc
role :app, "***REMOVED***{machine_name}"                          ***REMOVED*** This may be the same as your `Web` server
role :db,  "***REMOVED***{machine_name}", :primary => true ***REMOVED*** This is where Rails migrations will run

set :user, "amber"

***REMOVED*** if you're still using the script/reaper helper you will need
***REMOVED*** these http://github.com/rails/irs_process_scripts
namespace :mod_rails do
  desc <<-DESC
  Restart the application altering tmp/restart.txt for mod_rails.
  DESC
  task :restart, :roles => :app do
    run "touch  ***REMOVED***{release_path}/tmp/restart.txt"
  end
  
  task :search_rebuild, :roles => :app do
  end
  
end
 
***REMOVED*** If you are using Passenger mod_rails uncomment this:
namespace :deploy do
***REMOVED*** task :start do ; end
***REMOVED*** task :stop do ; end
***REMOVED*** task :restart, :roles => :app, :except => { :no_release => true } do
***REMOVED***   run "***REMOVED***{try_sudo} touch ***REMOVED***{File.join(current_path,'tmp','restart.txt')}"
***REMOVED*** end
  %w(start restart).each { |name| task name, :roles => :app do mod_rails.restart end }
end
