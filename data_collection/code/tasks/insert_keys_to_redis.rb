class InsertKeysToRedis
  include Sidekiq::Worker
  ##hash_get_key_field, #hash_set, and #hash_get are all copied from http://redis.io/topics/memory-optimization
  #they efficiently store the data into Redis - this demonstration of the analysis used doesn't need much memory,
  #but in order to scan all of Reddit in memory, it requires 11GB of an RDB, which expands when actually loaded in memory.
  #without this optimization, the author was unable to store all IDs in the most simple key/value implementation with Redis
  #within 64GB of ram, which was the limit available to the author. Please follow the tutorial at the above URL for 
  #actual implementation and replication
  def hash_get_key_field(key)
      s = key.split(":")
      if s[1].length > 2
          {:key => s[0]+":"+s[1][0..-3], :field => s[1][-2..-1]}
      else
          {:key => s[0]+":", :field => s[1]}
      end
  end

  def hash_set(r,key,value)
      kf = hash_get_key_field(key)
      r.hset(kf[:key],kf[:field],value)
  end

  def hash_get(r,key)
      kf = hash_get_key_field(key)
      r.hget(kf[:key],kf[:field])
  end
  
  #for each source file, determine if the file refers to submissions (posts) or comments. Then, walk through and store all ids.
  def perform(source_file)
binding.pry
    metric_name = source_file.include?("submission") ? "submission_count" : "comment_count"
    redis_cli = source_file.include?("submission") ? REDIS_SUBMISSIONS : REDIS_COMMENTS
    CSV.foreach(source_file) do |row|
      hash_set(redis_cli,"obj:"+row[0],"1")
      redis_cli.incr(metric_name)
    end;false
  end

  #grab all relevant base_10 files and store all keys from file to memory in a hashmap
  def self.kickoff
    Dir[File.dirname(__FILE__) + '/../../extracted_data/*.csv'].select{|x| x.include?("base_10") && x.include?("sorted")}.each do |source_file|
      self.perform_async(source_file)
    end
  end

  def self.kickoff_noop
    puts Dir[File.dirname(__FILE__) + '/../../extracted_data/*.csv'].select{|x| x.include?("base_10")}
  end
end

