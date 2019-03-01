class ApplicationMailer < ActionMailer::Base
  default_url_options[:host] = ROOT_URL
  default :from => "Berkeley Beehive <octo.beehive@asuc.org>"
end
