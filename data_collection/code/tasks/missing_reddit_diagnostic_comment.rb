class MissingRedditDiagnosticComment
  include MongoMapper::Document
  include Sidekiq::Worker
  key :subreddit, String
  key :comment_id, String
  key :comment_id_int, Integer
  key :referring_comment_id, String
  key :referring_comment_id_int, Integer
  key :referring_time, Time


  def perform(rows)
    $redis_submissions.incr("total_complete")
    comment_parents = []
    post_parents = []
    rows.each do |row|
      if row["parent_type"] == "post"
        post_parents << row
      elsif row["parent_type"] == "comment"
        comment_parents << row
      end
    end;false
    if !comment_parents.empty?
      found_comment_parents = comment_parents.collect{|c| c["parent_id"] if InsertKeysToRedis.new.hash_get($redis_comments,"obj:"+c["parent_id_int"].to_s) == "1"}.compact.uniq
      missing_parents = comment_parents.select{|r| !found_comment_parents.include?(r["parent_id"])}
      MissingRedditDiagnosticComment.collection.insert(missing_parents.collect{|r| {subreddit: r["subreddit"], comment_id: r["parent_id"], comment_id_int: base_36_to_int(r["parent_id"]), referring_comment_id: r["comment_id"], referring_c$
    end
    if !post_parents.empty?
      found_post_parents = post_parents.collect{|c| c["parent_id"] if InsertKeysToRedis.new.hash_get($redis_submissions,"obj:"+c["parent_id_int"].to_s) == "1"}.compact
      missing_parents = post_parents.select{|r| !found_post_parents.include?(r["parent_id"])}
      MissingRedditDiagnosticSubmission.collection.insert(missing_parents.select{|r| !found_post_parents.include?(r["parent_id"])}.collect{|r| {subreddit: r["subreddit"], submission_id: r["parent_id"], submission_id_int: base_36_to_int(r$
    end
  end
end