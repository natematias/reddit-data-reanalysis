class CountParentReferences
  include Sidekiq::Worker
  sidekiq_options queue: :cpr
  def perform(year, file)
    daily_counts = {}
    hourly_counts = {}
    `mkdir #{SETTINGS["download_path"]}/comments_marked_summarized`
    `mkdir #{SETTINGS["download_path"]}/comments_marked_summarized/#{year}`
    daily_csv = CSV.open("#{SETTINGS["download_path"]}/comments_marked_summarized/#{year}/daily_#{file}", "w")
    hourly_csv = CSV.open("#{SETTINGS["download_path"]}/comments_marked_summarized/#{year}/hourly_#{file}", "w")
    CSV.foreach("#{SETTINGS["download_path"]}/comments_marked/#{year}/#{file}") do |row|
      daily_counts[Time.parse(row[3]).strftime("%Y-%m-%d")] ||= {"true" => 0, "false" => 0}
      daily_counts[Time.parse(row[3]).strftime("%Y-%m-%d")][row[0]] += 1
      hourly_counts[Time.parse(row[3]).strftime("%H")] ||= {"true" => 0, "false" => 0}
      hourly_counts[Time.parse(row[3]).strftime("%H")][row[0]] += 1
    end;false
    daily_counts.each do |time, counts|
      daily_csv << [time, counts["true"], counts["false"], counts["true"]+counts["false"]]
    end
    hourly_counts.each do |time, counts|
      hourly_csv << [time, counts["true"], counts["false"], counts["true"]+counts["false"]]
    end
    daily_csv.close
    hourly_csv.close
#    ParentReference.collection.insert(current_rows) if current_rows.empty? == false
  end

  def self.kickoff
    `ls #{SETTINGS["download_path"]}/comments_marked`.split("\n").each do |year|
      `ls #{SETTINGS["download_path"]}/comments_marked/#{year}`.split("\n").each do |file|
        CountParentReferences.perform_async(year, file)
      end
    end
  end
end

#`ls #{SETTINGS["download_path"]}/submissions_ids`.split("\n").each do |year|
#  `ls #{SETTINGS["download_path"]}/submissions_ids/#{year}`.split("\n").each do |file|
#    CheckGaps.perform_async(year, file, "submissions")
#  end
#end
