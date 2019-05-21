ROOT_URLS = {'development' => 'http://localhost:3000',
             'test' => 'http://localhost:3000',
             'staging' => 'http://localhost:3000',
             'production' => 'http://beehive.berkeley.edu'}
CAS_LOGOUT_URLS = {'development' => 'https://auth-test.berkeley.edu/cas/logout',
             'test' => 'https://auth-test.berkeley.edu/cas/logout',
             'staging' => 'https://auth-test.berkeley.edu/cas/logout',
             'production' => 'https://auth.berkeley.edu/cas/logout'}
ROOT_URL = ROOT_URLS[Rails.env]
CAS_LOGOUT_URL = CAS_LOGOUT_URLS[Rails.env]
