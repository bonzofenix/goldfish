require 'data_mapper'
sqlite_path = "sqlite3://#{Dir.pwd}/db/#{ENV['RACK_ENV']}.db"
DataMapper.setup(:default, ENV['DATABASE_URL'] || sqlite_path )
DataMapper::Model.raise_on_save_failure = false

class Post
  include DataMapper::Resource
  property :id,     Serial
  property :title,  String, required: true, unique: true , default: ''
  property :content, Text, required: true, required: true, default: ''
  property :friendly_url, String
  property :publish,  Boolean, required: true, default: false
  property :date,   DateTime, required: true, default: Time.now
  has n, :tags, :through => Resource


  def new?
    id == nil
  end

  def show_url
    "/posts/#{date.year}/#{date.month}/#{title.downcase.tr(" ","_")}"
  end

  default_scope(:default).update(:order => [:date.desc])
end

class Tag
  include DataMapper::Resource
  property :id, Serial
  property :name, String, required: true, unique: true
  has n, :posts, :through => Resource
end

DataMapper.finalize.auto_upgrade!
