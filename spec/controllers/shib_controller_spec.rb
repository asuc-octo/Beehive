require '../rails_helper'

RSpec.describe ShibController, type: :controller do
  
  before do
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:shibboleth]
  end

  test "filluser" do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:shibboleth] = OmniAuth::AuthHash.new({
      :provider => "shibboleth",
      :uid  => "hi",
      :info => {
        :name => "Test Test2",
        :email => "john@test.edu",
        :surname => "Test2" ,
        :givenName => "Test",
        :affiliation => "Staff@lbl.gov"
      }
    })
    print "Running test.."
    User.fill_from_shib


    end
    assert true

end













