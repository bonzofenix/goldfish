require 'sinatra'
require 'sinatra/partial'
require 'sinatra/namespace'
require 'haml'
require 'redcarpet'
require 'ostruct'
require './models'
require 'rack/codehighlighter'
require 'coderay'


use Rack::Codehighlighter, :coderay, markdown: true,
    element: "code", pattern: /\A:::(\w+)\s*(\n|&#x000A;)/i, logging: false


INDEX_CATEGORY = nil
PROFILE_IMAGE = 'http://www.gravatar.com/avatar/0cba58b9292100591739880d96f5f739.png?s=200'
GITHUB  = 'https://github.com/bonzofenix'
SIDEBAR_LINKS =
  [
  {text: 'About Me', url: '/about_me'},
  {text: 'Technology', url: '/tags/technology'}
]

require 'sinatra/simple-navigation'

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
  get('/new') do
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
  Post.first(conditions: ["LOWER(title) like ?", "%#{title}%"])
end

def render_posts(tag_name = nil)
  @posts = ( tag_name ? Tag.first(name: tag_name).posts : Post.all )
  haml :'posts/index'
end

