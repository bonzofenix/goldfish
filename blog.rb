require 'sinatra'
require 'sinatra/simple-navigation'
require 'sinatra/partial'
require 'sinatra/namespace'
require 'haml'
require 'redcarpet'
require 'debugger'
require './models'

enable :partial_underscores

INDEX_CATEGORY = nil
PROFILE_IMAGE = 'http://www.gravatar.com/avatar/0cba58b9292100591739880d96f5f739.png?s=200'
GITHUB  = 'https://github.com/bonzofenix'

get('/'){ render_posts INDEX_CATEGORY }

namespace '/posts' do
  get('/new'){ haml :'posts/new' }

  Category.all.each do |category|
    get(category.name){ render_posts category.name }
  end


  post do
    params['publish'] = (params['publish'] == 'on' ? true : false)
    params['categories'] = params['categories'].split(',').collect do |name|
      Category.first_or_create(name: name.strip )
    end
    Post.new(params).save
  end

  get('/:category'){ render_posts params['category'] }

  get '/:year/:month/:title' do
    title = params['title'].downcase.gsub('_',' ')
    @post = Post.find(conditions: ["LOWER(title) like '%?%'", title]).first
    haml :'posts/show'
  end

  get { render_posts }

end

def render_posts(category = nil)
  @posts = ( category ? Category.first(name: category).posts : Post.all )
  haml :'posts/index'
end

