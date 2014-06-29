ENV['RACK_ENV'] = 'test'

require 'database_cleaner'
require 'factory_girl'
require 'dm-transactions'
require 'rack/test'


FactoryGirl.find_definitions

Dir.chdir "#{Dir.pwd}/spec/dummy"
require 'goldfish'
RSpec.configure do |c|
  c.include Rack::Test::Methods
  c.include FactoryGirl::Syntax::Methods

  def app() described_class end

  c.before do
    DatabaseCleaner.clean
    DatabaseCleaner.start
  end

  c.after do
      DatabaseCleaner.clean
  end
end

