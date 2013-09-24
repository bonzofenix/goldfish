require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")
class Post
  include DataMapper::Resource
  property :id,     Serial
  property :title,  String, required: true
  property :tag,  String, required: true
  property :content,Text, required: true
  property :date,   DateTime
end
DataMapper.finalize
