require 'spec_helper'

describe Goldfish do
  it 'responds to /' do
    get '/'
    last_response.should be_ok
  end
end
