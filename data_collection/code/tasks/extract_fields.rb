class ExtractFields
  include Sidekiq::Worker
  sidekiq_options queue: :extract_ids
  def comment_manifest
    manifest = {}
    `ls #{SETTINGS["download_path"]}/comments`.split("\n").each do |year|
      manifest[year] ||= `ls #{SETTINGS["download_path"]}/comments/#{year}`.split("\n")
    end
    manifest
  end

  def submission_manifest
    manifest = {}
    `ls #{SETTINGS["download_path"]}/submissions`.split("\n").each do |year|
      manifest[year] ||= `ls #{SETTINGS["download_path"]}/submissions/#{year}`.split("\n")
    end
    manifest
  end
  
  def perform(year, file, data_type)
    if data_type == "comments"
      `bzip2 -dck #{SETTINGS["download_path"]}/#{data_type}/#{year}/#{file} | jq 'def to_i(base): explode | reverse | map(if . > 96  then . - 87 else . - 48 end) | reduce .[] as $c ([1,0]; (.[0] * base) as $b | [$b, .[1] + (.[0] * $c)]) | .[1]; [(.created_utc | tostring), .subreddit, .id, (.id | to_i(36)), .parent_id, (.parent_id | split("_") | last | to_i(36))] | @csv' | LC_ALL=C sort -nt',' -k4,4 -T #{SETTINGS["download_path"]}/tmp > #{SETTINGS["download_path"]}/#{data_type}_extracted/#{year}/#{file.gsub("bz2", "csv")}`
    elsif data_type == "submissions"
      `bzip2 -dck #{SETTINGS["download_path"]}/#{data_type}/#{year}/#{file} | jq 'def to_i(base): explode | reverse | map(if . > 96  then . - 87 else . - 48 end) | reduce .[] as $c ([1,0]; (.[0] * base) as $b | [$b, .[1] + (.[0] * $c)]) | .[1]; [(.created_utc | tostring), .subreddit, .id, (.id | to_i(36))] | @csv' | LC_ALL=C sort -nt',' -k4,4 -T #{SETTINGS["download_path"]}/tmp > #{SETTINGS["download_path"]}/#{data_type}_extracted/#{year}/#{file.gsub("bz2", "csv")}`
    end
  end
  
  def kickoff_sequential
    `mkdir -p #{SETTINGS["download_path"]}/tmp`
    `mkdir -p #{SETTINGS["download_path"]}/comments_extracted`
    comment_manifest.each do |year, month_files|
      `mkdir -p #{SETTINGS["download_path"]}/comments_extracted/#{year}`
      month_files.each do |month_file|
        ExtractFields.new.perform(year, month_file, "comments")
      end
    end
    `mkdir -p #{SETTINGS["download_path"]}/submissions_extracted`
    submission_manifest.each do |year, month_files|
      `mkdir -p #{SETTINGS["download_path"]}/submissions_extracted/#{year}`
      month_files.each do |month_file|
        ExtractFields.new.perform(year, month_file, "submissions")
      end
    end
  end

  def kickoff
    `mkdir -p #{SETTINGS["download_path"]}/tmp`
    `mkdir -p #{SETTINGS["download_path"]}/comments_extracted`
    comment_manifest.each do |year, month_files|
      `mkdir -p #{SETTINGS["download_path"]}/comments_extracted/#{year}`
      month_files.each do |month_file|
        ExtractFields.perform_async(year, month_file, "comments")
      end
    end
    `mkdir -p #{SETTINGS["download_path"]}/submissions_extracted`
    submission_manifest.each do |year, month_files|
      `mkdir -p #{SETTINGS["download_path"]}/submissions_extracted/#{year}`
      month_files.each do |month_file|
        ExtractFields.perform_async(year, month_file, "submissions")
      end
    end
  end
end

