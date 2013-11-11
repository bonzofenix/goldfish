require 'sinatra'
require 'sinatra/simple-navigation'
require 'sinatra/partial'
require 'sinatra/namespace'
require 'haml'
require 'redcarpet'
require 'ostruct'
require './models'
require 'rack/codehighlighter'
DataMapper::Logger.new(STDOUT, :debug)

use Rack::Codehighlighter, :coderay, :markdown => true,
    :element => "pre>code", :pattern => /\A:::(\w+)\s*(\n|&#x000A;)/i, :logging => false


INDEX_CATEGORY = nil
PROFILE_IMAGE = 'http://www.gravatar.com/avatar/0cba58b9292100591739880d96f5f739.png?s=200'
GITHUB  = 'https://github.com/bonzofenix'

enable :partial_underscores
enable :method_override

before do
  params.delete('_method')
  params['id'] = params['id'].to_i if params['id']
end

get('/'){ render_posts INDEX_CATEGORY }

Category.all.each do |category|
  get("/#{category.name}"){ render_posts category.name }
end

namespace '/posts' do
  get('/new'){ haml :'posts/new' }

  post do
    params['publish'] = (params['publish'] == 'on' ? true : false)
    params['categories'] = params['categories'].split(',').collect do |name|
      Category.first_or_create(name: name.strip )
    end
    Post.new(params).save
  end

  put do
    @post = Post.get(params['id'].to_i)
    params['categories'] = params['categories'].split(',').collect do |name|
      Category.first_or_create(name: name.strip )
    end
    @post.update(params) if @post
    redirect show_url_for(@post)
  end

  get '/:year/:month/:title' do
    @post = find_post_for_title(params)
    haml :'posts/show'
  end

  get '/:year/:month/:title/edit' do
    @post = find_post_for_title(params)
    haml :'posts/edit'
  end

  get { render_posts }
end

def show_url_for(post)
  "/posts/#{post.date.year}/#{post.date.month}/#{post.title.downcase.tr(" ","_")}"
end

def find_post_for_title(params)
  title = params['title'].downcase.gsub('_',' ')
  res = Post.all(conditions: ["LOWER(title) like ?", "%#{title}%"])
    # logger.info res.inspect
    res.first
end

def render_posts(category = nil)
  @posts = ( category ? Category.first(name: category).posts : Post.all )
  haml :'posts/index'
end

