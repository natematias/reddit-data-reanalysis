require 'csv'
require 'sidekiq'
require 'sidekiq/api'
require 'time'
require 'json'
require 'redis'
$redis_submissions = Redis.new(db: 2)
$redis_comments = Redis.new(db: 3)
Dir[File.dirname(__FILE__) + '/tasks/*.rb'].each {|file| require file }
