# require 'database_cleaner'
require 'goldfish'
require 'dm-transactions'

require 'rack/test'



# DatabaseCleaner[:data_mapper].strategy = :transaction
OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:github] = {
  'uid' => '1337',
  'provider' => 'github',
  'info' => {
    'name' => 'bonzofenix',
    'username' => 'bonzofenix'
  }
}


# For RSpec 2.x
RSpec.configure do |c|
  c.include Rack::Test::Methods
  def app() described_class end
  # c.before do
# request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
      # # DatabaseCleaner.start
  # end

  # c.after :each do
      # DatabaseCleaner.clean
  # end
end
