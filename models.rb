require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")
DataMapper::Model.raise_on_save_failure = true

class Post
  include DataMapper::Resource
  property :id,     Serial
  property :title,  String, required: true, unique: true , default: ''
  property :short_description, String, required: true, default: ''
  property :content, Text, required: true, required: true, default: ''
  property :publish,  Boolean, required: true, default: false
  property :date,   DateTime, required: true, default: Date.today
  has n, :categories, :through => Resource

  def new?
    !saved?
  end
end

class Category
  include DataMapper::Resource
  property :id, Serial
  property :name, String, required: true, unique: true
  property :show_in_navigation,  Boolean, required: true, default: false
  has n, :posts, :through => Resource
end

DataMapper.finalize.auto_upgrade!
