require 'csv'
require 'sidekiq'
require 'sidekiq/api'
require 'time'
require 'json'
require 'redis'
require 'mongo_mapper'
$redis_submissions = Redis.new(db: 2)
$redis_comments = Redis.new(db: 3)
MongoMapper.connection = Mongo::MongoClient.new("localhost", 27017, :pool_size => 25, :op_timeout => 600000, :timeout => 600000, :pool_timeout => 600000)
MongoMapper.database = "reddit_diagnostics"
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/tasks/*.rb'].each {|file| require file }
