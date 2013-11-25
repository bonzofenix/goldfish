require 'spec_helper'

describe Goldfish do
  it 'GET /' do
    get '/'
    last_response.should be_ok
  end

  describe 'GET /tags' do
    it 'returns only that tag' do
      t1 ,t2  = 2.times.map { create :tag, :with_post }
      get "/tags/#{t1.name}"
      r.body.should_not include(t2.name)
    end
  end
end
