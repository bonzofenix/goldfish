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
$settings = settings
class Goldfish < Sinatra::Base
  register Sinatra::Namespace, Sinatra::Partial
  register Sinatra::SimpleNavigation
  register Sinatra::BasicAuth

  authorize do |username, password|
    username == $settings.username && password == $settings.password
  end


  enable :sessions
  enable :partial_underscores
  enable :method_override

  before do
    params.delete('_method')
    params['id'] = params['id'].to_i if params['id']
  end

  get '/' do
    if $settings.respond_to? :post_in_index
      @post = find_post_for_title($settings.post_in_index)
      haml :'posts/show'
    else
      render_posts
    end
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
        @post = find_post_for_title(params['title'])
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
      @post = find_post_for_title(params['title'])
      @post.destroy!
    end

    get '/:year/:month/:title' do
      @post = find_post_for_title(params['title'])
      @comments = true
      haml :'posts/show'
    end



    get { render_posts }
  end


  def find_post_for_title(title)
    title = title.downcase.gsub('_',' ')
    Post.first(conditions: ["LOWER(title) like ?", "%#{title}%"])
  end

  def render_posts(tag_name = nil)
    @posts = ( tag_name ? Tag.first(name: tag_name).posts : Post.all)
    haml :'posts/index'
  end
end
