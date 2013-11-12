require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")
DataMapper::Model.raise_on_save_failure = true

class Post
  include DataMapper::Resource
  # default_order [:date.desc]
  property :id,     Serial
  property :title,  String, required: true, unique: true , default: ''
  property :short_description, String, required: true, default: ''
  property :content, Text, required: true, required: true, default: ''
  property :friendly_url, String
  property :publish,  Boolean, required: true, default: false
  property :date,   DateTime, required: true, default: Date.today
  has n, :tags, :through => Resource

  def new?
    id == nil
  end
end

class Tag
  include DataMapper::Resource
  property :id, Serial
  property :name, String, required: true, unique: true
  has n, :posts, :through => Resource
end

DataMapper.finalize.auto_upgrade!
