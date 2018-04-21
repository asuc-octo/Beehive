class ApplicationMailer < ActionMailer::Base
  default_url_options[:host] = ROOT_URL
  default :from => "Berkeley Beehive <octobeehive@gmail.com>"
end
