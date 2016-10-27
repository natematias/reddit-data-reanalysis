class ParseSourceFile
  include Sidekiq::Worker
  def perform(source_file)
    current_rows = []
    CSV.foreach(source_file) do |row|
      current_rows << {time: Time.at(row[0].to_i), subreddit: row[1], comment_id: row[2], comment_id_int: base_36_to_int(row[2]), parent_id: row[3], parent_id_int: base_36_to_int(row[3]), parent_type: (row[3].include?("t3_") ? "post" : "comment")}
      if current_rows.length >= 500
        while Sidekiq::Queue.new.size > 1000
          sleep(1)
        end
        MissingRedditDiagnosticComment.perform_async(current_rows)
        current_rows = []
      end
    end
    MissingRedditDiagnosticComment.perform_async(current_rows)
  end

  def self.kickoff
    MissingRedditDiagnosticComment.collection.drop
    MissingRedditDiagnosticSubmission.collection.drop
    $redis_submissions.set("total_complete", "0")
    Dir[File.dirname(__FILE__) + '/../../extracted_data/*.csv'].select{|x| x.include?("comment") && x.include?("sparse")}.each do |source_file|
      self.perform_async(source_file)
    end
  end
end