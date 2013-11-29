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
      last_response.body.should include(t1.name)
      last_response.body.should_not include(t2.name)
    end
  end

  describe 'posts' do
    let(:post){ create :post, friendly_url: '/a_friendly_url' }
    before{ post }

    it 'GET by friendly urls' do
      get post.friendly_url
      last_response.body.should include(post.title)
    end

    it 'GET by /year/month/title' do
      get post.show_url
      last_response.body.should include(post.title)
    end

    it 'DELETE a post' do
      expect do
        delete post.show_url
      end.to change{ Post.all.count }.from(1).to(0)
    end
  end


end
