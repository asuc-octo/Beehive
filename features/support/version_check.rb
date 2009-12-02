require 'cucumber/formatter/ansicolor'
extend Cucumber::Formatter::ANSIColor
if Cucumber::VERSION != '0.4.4'
warning = <<-WARNING
***REMOVED***{red_cukes(15)} 

         ***REMOVED***{red_cukes(1)}   R O T T E N   C U C U M B E R   A L E R T    ***REMOVED***{red_cukes(1)}

Your ***REMOVED***{__FILE__.gsub(/version_check.rb$/, 'env.rb')} file was generated with Cucumber 0.4.4,
but you seem to be running Cucumber ***REMOVED***{Cucumber::VERSION}. If you're running an older 
version than ***REMOVED***{Cucumber::VERSION}, just upgrade your gem. If you're running a newer 
version than ***REMOVED***{Cucumber::VERSION} you should:

  1) Read http://wiki.github.com/aslakhellesoy/cucumber/upgrading
  
  2) Regenerate your cucumber environment with the following command:

     ruby script/generate cucumber

If you get prompted to replace a file, hit 'd' to see the difference.
When you're sure you have captured any personal edits, confirm that you
want to overwrite ***REMOVED***{__FILE__.gsub(/version_check.rb$/, 'env.rb')} by pressing 'y'. Then reapply any
personal changes that may have been overwritten, preferably in separate files.

This message will then self destruct.

***REMOVED***{red_cukes(15)}
WARNING
warn(warning)
at_exit {warn(warning)}
end