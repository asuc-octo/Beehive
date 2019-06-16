Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, :path => '/cas', :host => 'auth-test.berkeley.edu' if Rails.env.development?
  provider :cas, :path => '/cas', :host => 'auth-test.berkeley.edu' if  Rails.env.staging?
  provider :cas, :path => '/cas', :host => 'auth-test.berkeley.edu' if  Rails.env.test?
  provider :cas, :path => '/cas', :host => 'auth.berkeley.edu' if Rails.env.production?

  provider :shibboleth, {
    :shib_session_id_field     => "Shib-Session-ID",
    :shib_application_id_field => "Shib-Application-ID",
    :request_type              => :params,
    :name_field                => lambda {|request_param| "#{request_param.call('givenName')} #{request_param.call('surname')}"},
    :info_fields               => {
                                    :affiliation => "affiliation",
                                    :surname => "surname",
                                    :givenNAme => "givenName",
                                    :email => "mail"
                                  },
    :debug                     => true
  }

  #provider :developer unless Rails.env.production?
end

ResearchMatch::Application.config.auth_providers = {
  :cas => {:auth_field => :login, :auth_value => :uid},
  :shibboleth => {:auth_field => :shib_login, :auth_value => :uid}
}
