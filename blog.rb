require 'sinatra'
require 'sinatra/simple-navigation'
require 'sinatra/namespace'
require 'haml'
require './model/post.rb'
require 'debugger'



get '/' do
  haml :index
end
namespace '/posts' do
  %w{ /music /technology /trips}.each do |tag|
    get(tag){ render_posts tag }
  end

  get{ render_posts}

  get '/new' do
    haml :new
  end

  post do
    debugger
     :index
  end
end

def render_posts(tag = nil)
  @posts = if tag
   Post.all(tag: tag)
  else
    Post.all
  end

  haml :posts
end

