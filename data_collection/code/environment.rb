def base_36_to_int(reddit_id)
  reddit_id.split("_").last.to_i(36)
end
def base_10_to_36(number)
  number.to_s(36)
end
require 'csv'
require 'sidekiq'
require 'sidekiq/api'
require 'time'
require 'json'
require 'redis'
require 'mongo_mapper'
require 'pry'
require 'yaml'
SETTINGS = YAML.load(File.read("config.yml")) rescue {"download_path" => "#{`pwd`.strip}/../data"}
REDIS_SUBMISSIONS = Redis.new(db: 2)
REDIS_COMMENTS = Redis.new(db: 3)
MongoMapper.connection = Mongo::MongoClient.new("localhost", 27017, :pool_size => 25, :op_timeout => 600000, :timeout => 600000, :pool_timeout => 600000)
MongoMapper.database = "reddit_diagnostic_test"
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/tasks/*.rb'].each {|file| require file }
