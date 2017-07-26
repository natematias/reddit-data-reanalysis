class InsertKeysToRedis
  include Sidekiq::Worker
  sidekiq_options queue: :insert_keys
  ##hash_get_key_field, #hash_set, and #hash_get are all copied from http://redis.io/topics/memory-optimization
  #they efficiently store the data into Redis - this demonstration of the analysis used doesn't need much memory,
  #but in order to scan all of Reddit in memory, it requires 11GB of an RDB, which expands when actually loaded in memory.
  #without this optimization, the author was unable to store all IDs in the most simple key/value implementation with Redis
  #within 64GB of ram, which was the limit available to the author. Please follow the tutorial at the above URL for 
  #actual implementation and replication
  def hash_get_key_field(key)
    if key.length > 3
      {:key => key[0..-4], :field => key[-3..-1]}
    else
      {:key => "", :field => key}
    end
  end

  def hash_set(r,key,value)
    kf = hash_get_key_field(key)
    r.hset(kf[:key],kf[:field],value)
  end
  
  def hash_m_set(r,keyval_map)
    keyval_map.each do |key, values|
      r.hmset(*[key,values.collect{|v| [v, "1"]}].flatten)
    end
  end

  def hash_get(r,key)
    kf = hash_get_key_field(key)
    r.hget(kf[:key],kf[:field])
  end
  
  #for each source file, determine if the file refers to submissions (posts) or comments. Then, walk through and store all ids.
  def perform(year, file, data_type)
    metric_name = data_type == "submissions" ? "submission_count" : "comment_count"
    redis_cli = data_type == "submissions" ? REDIS_SUBMISSIONS : REDIS_COMMENTS
    mapped = {}
    count = 0
    CSV.foreach("#{SETTINGS["download_path"]}/comments_ids/#{year}/#{file}") do |row|
      mapped[row.first[0..-4]] ||= []
      mapped[row.first[0..-4]] << row.first[-3..-1]
      count += 1
      if count > 100000
        hash_m_set(r,mapped)
        mapped = {}
        count = 0
      end
    end;false
    #8.627484257263278 with 1k
    #8.495383921663342 with 10k
    #8.256297051107357 with 100k
    #8.808857838182384 with 1m
    #hash_set(redis_cli,row[0],"1")
    #redis_cli.incr(metric_name)
  end

  #grab all relevant base_10 files and store all keys from file to memory in a hashmap
  def self.kickoff
    `ls #{SETTINGS["download_path"]}/comments_ids`.split("\n").each do |year|
      `ls #{SETTINGS["download_path"]}/comments_ids/#{year}`.split("\n").each do |file|
        InsertKeysToRedis.perform_async(year, file, "comments")
      end
    end
    `ls #{SETTINGS["download_path"]}/submissions_ids`.split("\n").each do |year|
      `ls #{SETTINGS["download_path"]}/submissions_ids/#{year}`.split("\n").each do |file|
        InsertKeysToRedis.perform_async(year, file, "submissions")
      end
    end
  end
end