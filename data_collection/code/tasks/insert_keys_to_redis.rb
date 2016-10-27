class InsertKeysToRedis
  include Sidekiq::Worker
  sidekiq_options :queue => :redis_set
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
  
  def perform(source_file)
    metric_name = source_file.include?("submission") ? "submission_count" : "comment_count"
    redis_cli = source_file.include?("submission") ? $redis_submissions : $redis_comments
    CSV.foreach(source_file) do |row|
      hash_set(redis_cli,"obj:"+base_36_to_int(row[2]).to_s,"1")
      redis_cli.incr(metric_name)
    end;false
  end

  def self.kickoff
    .each do |source_file|
      self.perform_async(source_file)
    end
  end
end

