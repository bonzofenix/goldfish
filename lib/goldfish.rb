require 'bundler/setup'
require 'sinatra'

Sinatra::Base.root = File.join(File.dirname(__FILE__), '..')

require 'sinatra/simple-navigation'
require 'sinatra/base'
require 'sinatra/partial'
require 'sinatra/namespace'
require "sinatra/basic_auth"
require "sinatra/config_file"
require 'haml'
require 'json'
require 'redcarpet'
require 'ostruct'
require_relative 'models'
require 'rack/codehighlighter'
require 'coderay'

config_file 'config/application.yml'

authorize do |username, password|
  username == settings.username && password == settings.password
end

INDEX_CATEGORY = nil
PROFILE_IMAGE = 'http://www.gravatar.com/avatar/0cba58b9292100591739880d96f5f739.png?s=200'
GITHUB  = 'https://github.com/bonzofenix'
SIDEBAR_LINKS =
  [
    {text: 'About Me', url: '/posts/2013/11/about_me'},
    {text: 'Email me', url: 'mailto:bonzofenix@gmail.com'},
    {text: 'Github', url: GITHUB},
    {text: 'Technology', url: '/tags/technology'}
]


class Goldfish < Sinatra::Base
  register Sinatra::Namespace, Sinatra::Partial
  register Sinatra::SimpleNavigation
  register Sinatra::BasicAuth


  enable :sessions
  enable :partial_underscores
  enable :method_override

  before do
    params.delete('_method')
    params['id'] = params['id'].to_i if params['id']
  end

  get '/' do
    render_posts
  end

  protect do
    get '/sudo' do
      haml :'sudo'
    end
  end

  not_found do
    puts request.env['PATH_INFO']
    @post = Post.first(:friendly_url => request.env['PATH_INFO'])
    haml :'posts/show' if @post && request.env['REQUEST_METHOD']== 'GET'
  end

  get '/tags/:name' do
    render_posts params['name']
  end

  namespace '/posts' do
    get '/new' do
      @post = Post.new
      haml :'posts/new'
    end

    protect do

      post do
        params['publish'] = (params['publish'] == 'on' ? true : false)
        params['tags'] = params['tags'].split(',').collect do |name|
          Tag.first_or_create(name: name.strip )
        end
        Post.new(params).save
      end

      get '/:year/:month/:title/edit' do
        @post = find_post_for_title(params)
        haml :'posts/edit'
      end

      put do
        @post = Post.get(params['id'].to_i)
        params['tags'] = params['tags'].split(',').collect do |name|
          Tag.first_or_create(name: name.strip )
        end
        @post.update(params) if @post
        redirect @post.show_url()
      end
    end

    delete '/:year/:month/:title' do
      @post = find_post_for_title(params)
      @post.destroy!
    end

    get '/:year/:month/:title' do
      @post = find_post_for_title(params)
      @comments = true
      haml :'posts/show'
    end



    get { render_posts }
  end


  def find_post_for_title(params)
    title = params['title'].downcase.gsub('_',' ')
    Post.first(conditions: ["LOWER(title) like ?", "%#{title}%"])
  end

  def render_posts(tag_name = nil)
    @posts = ( tag_name ? Tag.first(name: tag_name).posts : Post.all)
    haml :'posts/index'
  end
end
