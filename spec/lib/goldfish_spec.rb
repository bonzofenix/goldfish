require 'spec_helper'

describe Goldfish do
  let(:bpost){ create :post }

  it 'GET /' do
    get '/'
    last_response.should be_ok
  end

  describe 'protected endpoints' do
    describe 'when user is not logged in' do
      it 'denies permition on GET /sudo' do
        get "/sudo"
        last_response.status.should be(401)
      end

      it 'denies permition on GET by /year/month/title/edit' do
        get "#{bpost.show_url}/edit"
        last_response.status.should be(401)
      end

      it 'denies permition on DELETE /posts' do
        delete bpost.show_url
        last_response.status.should be(401)
      end

      it 'denies permition on POST /posts' do
        post '/posts'
        last_response.status.should be(401)
      end

      it 'denies permition on POST /posts' do
        put '/posts'
        last_response.status.should be(401)
      end
    end

    describe 'when user logged in' do
      before do
        authorize 'admin', 'admin'
      end

      it 'POST on /posts' do
        expect do
          post '/posts', {'post' => attributes_for(:post),
            'tags' => 'tag_1, tag2'}
        end.to change{ Post.all.count }.from(0).to(1)
      end

      it 'PUT on /posts' do
        bpost
        expect do
          put '/posts', {'post' => { 'id' =>  bpost.id,
            'content' => 'this is new content',
            'tags' => 'tag_1, tag2'}}
        end.to change{ Post.first.content }
      end

      it 'GET by /year/month/title/edit' do
        get "#{bpost.show_url}/edit"
        last_response.should be_ok
      end

      it 'DELETE a post' do
        bpost
        expect do
          delete bpost.show_url
        end.to change{ Post.all.count }.from(1).to(0)
      end
    end
  end

  describe 'Showing posts' do
    let(:bpost){ create :post, friendly_url: '/a_friendly_url' }

   it 'GET by friendly urls' do
      get bpost.friendly_url
      last_response.body.should include(bpost.title)
    end

    it 'GET by /year/month/title' do
      get bpost.show_url
      last_response.body.should include(bpost.title)
    end

    it 'GET by /tags' do
      t1 ,t2  = 2.times.map { create :tag, :with_post }
      get "/tags/#{t1.name}"
      last_response.body.should include(t1.name)
      last_response.body.should_not include(t2.name)
    end
  end
end
