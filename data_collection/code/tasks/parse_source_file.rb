class CheckParentReferences
  include Sidekiq::Worker
  sidekiq_options queue: :cpr
  def perform(year, file, data_type)
    current_rows = []
    `mkdir #{SETTINGS["download_path"]}/#{data_type}_marked`
    csv = CSV.open("#{SETTINGS["download_path"]}/#{data_type}_marked/#{year}/#{file}", "w")
    File.foreach("#{SETTINGS["download_path"]}/#{data_type}_extracted/#{year}/#{file}") do |row|
      row = row.split(",").collect{|x| x.strip.gsub("\\", "").gsub("\"", "")}
      parent_type = row[4].split("_").first == "t3" ? "submissions" : "comments"
      metric_name = parent_type == "submissions" ? "submission_count" : "comment_count"
      redis_cli = parent_type == "submissions" ? REDIS_SUBMISSIONS : REDIS_COMMENTS
      found = InsertKeysToRedis.new.hash_get(redis_cli,row[5].to_s) == "1" ? true : false
      csv << [found, year, file, Time.at(row[0].to_i), row[1], row[2], row[3], row[4], row[5], parent_type]
#      current_rows << {found: found, source_year: year, source_file: file, time: Time.at(row[0].to_i), subreddit: row[1], comment_id: row[2], comment_id_int: row[3], parent_id: row[4], parent_id_int: row[5], parent_type: parent_type}
#      if current_rows.length >= 500
#        while Sidekiq::Queue.new.size > 1000
#          sleep(1)
#        end
#        ParentReference.collection.insert(current_rows) if current_rows.empty? == false
#        current_rows = []
#      end
    end
    csv.close
#    ParentReference.collection.insert(current_rows) if current_rows.empty? == false
  end

  def self.kickoff
    MissingRedditDiagnosticComment.collection.drop
    MissingRedditDiagnosticSubmission.collection.drop
    REDIS_SUBMISSIONS.set("total_complete", "0")
    `ls #{SETTINGS["download_path"]}/comments_ids`.split("\n").each do |year|
      `ls #{SETTINGS["download_path"]}/comments_ids/#{year}`.split("\n").each do |file|
        CheckParentReferences.perform_async(year, file, "comments")
      end
    end
  end
end

#`ls #{SETTINGS["download_path"]}/submissions_ids`.split("\n").each do |year|
#  `ls #{SETTINGS["download_path"]}/submissions_ids/#{year}`.split("\n").each do |file|
#    CheckGaps.perform_async(year, file, "submissions")
#  end
#end
