require 'bundler/setup'
require 'sinatra'

Sinatra::Base.root = File.join(File.dirname(__FILE__), '..')

require 'sinatra/simple-navigation'
require 'sinatra/base'
require 'sinatra/partial'
require 'sinatra/namespace'
require 'haml'
require 'json'
require 'redcarpet'
require 'ostruct'
require_relative 'models'
require 'rack/codehighlighter'
require 'coderay'
require 'omniauth'
require 'omniauth-github'

INDEX_CATEGORY = nil
PROFILE_IMAGE = 'http://www.gravatar.com/avatar/0cba58b9292100591739880d96f5f739.png?s=200'
GITHUB  = 'https://github.com/bonzofenix'
SIDEBAR_LINKS =
  [
    {text: 'About Me', url: '/about_me'},
    {text: 'Technology', url: '/tags/technology'}
]


class Goldfish < Sinatra::Base
  # set :root, "#{settings.root}/.."
  # set :root, File.dirname(__FILE__)
  register Sinatra::Namespace, Sinatra::Partial
  register Sinatra::SimpleNavigation
  set(:require_auth) do |auth|
    condition do
      halt 401 unless authenticated?
    end
  end


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

  not_found do
    puts request.env['PATH_INFO']
    @post = Post.first(:friendly_url => request.env['PATH_INFO'])
    haml :'posts/show' if @post && request.env['REQUEST_METHOD']== 'GET'
  end

  get '/tags/:name' do
    render_posts params['name']
  end

  namespace '/posts' do
    get '/new', require_auth: true  do
      @post = Post.new
      haml :'posts/new'
    end


    post require_auth: true do
      params['publish'] = (params['publish'] == 'on' ? true : false)
      params['tags'] = params['tags'].split(',').collect do |name|
        Tag.first_or_create(name: name.strip )
      end
      Post.new(params).save
    end
    get '/:year/:month/:title/edit', require_auth: true do
      @post = find_post_for_title(params)
      haml :'posts/edit'
    end

    put require_auth: true do
      @post = Post.get(params['id'].to_i)
      params['tags'] = params['tags'].split(',').collect do |name|
        Tag.first_or_create(name: name.strip )
      end
      @post.update(params) if @post
      redirect @post.show_url()
    end

    delete '/:year/:month/:title' do
      @post = find_post_for_title(params)
      @post.destroy
    end

    get '/:year/:month/:title' do
      @post = find_post_for_title(params)
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

  #------------ AUTHENTICATION ---------------

  use OmniAuth::Builder do
    if ENV['RACK_ENV'] == 'development'
      provider :github, 'b4cb81a0fbc5c85dcff0', 'cb6e1a55fc3e43f416b3f28c82bb0f661e7728bd'
    else
      provider :github, '1cd92b878b0360a58a62', '5bcd838aae2e9ea303a9198b50232bdd8f4ba5e2'
    end
  end

  get '/auth/:provider/callback' do
    setup_goldfish_owner
    return unless authenticated?
    save_goldfish_owner
    redirect '/'
  end

  get '/auth/failure' do
    erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
  end

  get '/auth/:provider/deauthorized' do
    erb "#{params[:provider]} has deauthorized this app."
  end

  get '/logout' do
    session[:authenticated] = false
    redirect '/'
  end

  def setup_goldfish_owner
    save_goldfish_owner unless File.exists?(owner_filename)
  end

  def save_goldfish_owner
    File.open('github_user_info.json', "w+") do |f|
      f.write(request.env['omniauth.auth'].to_json)
    end
  end

  def goldfish_owner
    JSON.parse(File.read(owner_filename)).fetch('info') if File.exists?(owner_filename)
  end

  def logged_user
    request.env['omniauth.auth'].fetch('info') if request.env['omniauth.auth']
  end


  def owner_filename
    'github_user_info.json'
  end

  def authenticated?
    if session[:authenticated]
      true
    elsif goldfish_owner && logged_user && goldfish_owner.fetch('nickname') == logged_user.fetch('nickname')
      session[:authenticated] = true
    else
      session[:authenticated] = nil
    end
  end

end
