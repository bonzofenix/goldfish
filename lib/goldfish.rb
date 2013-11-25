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

  Post.all(:friendly_url.not => nil ).each do |p|
    get(p.friendly_url) do
      @post = p
      haml :'posts/show'
    end
  end

  namespace '/tags' do
    Tag.all.each do |tag|
      get("tags/#{tag.name}"){ render_posts tag.name }
    end
  end

  namespace '/posts' do
    get '/new' do
      @post = Post.new
      haml :'posts/new'
    end

    post do
      params['publish'] = (params['publish'] == 'on' ? true : false)
      params['tags'] = params['tags'].split(',').collect do |name|
        Tag.first_or_create(name: name.strip )
      end
      Post.new(params).save
    end

    put do
      @post = Post.get(params['id'].to_i)
      params['tags'] = params['tags'].split(',').collect do |name|
        Tag.first_or_create(name: name.strip )
      end
      @post.update(params) if @post
      redirect show_url_for(@post)
    end

    delete '/:year/:month/:title' do
      @post = find_post_for_title(params)
      haml :'posts/show'
    end

    get '/:year/:month/:title/edit' do
      @post = find_post_for_title(params)
      haml :'posts/edit'
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
    provider :github, 'b4cb81a0fbc5c85dcff0', 'cb6e1a55fc3e43f416b3f28c82bb0f661e7728bd'
  end

  get '/auth/:provider/callback' do
    setup_goldfish_owner
    return unless authenticated?
    save_github_json
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
    save_github_json unless File.exists?(json_file)
  end

  def save_github_json
    File.open('github_user_info.json', "w+") do |f|
      f.write(request.env['omniauth.auth'].to_json)
    end
  end

  def goldfish_owner
    JSON.parse(File.read('github_user_info.json'))
  end

  def goldfish_authenticated
    request.env['omniauth.auth']
  end

  def authenticated?
    if session[:authenticated]
      true
    elsif File.exists?(json_file)
      owner = goldfish_owner.fetch('info').fetch('nickname')
      logged_user = goldfish_authenticated.fetch('info').fetch('nickname') if goldfish_authenticated
      if owner == logged_user
        session[:authenticated] = true
        true
      else
        false
      end
    else
      false
    end
  end

  def json_file
    'github_user_info.json'
  end
end
