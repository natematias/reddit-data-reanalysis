class ExtractIDs
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
    `bzip2 -dck #{SETTINGS["download_path"]}/#{data_type}/#{year}/#{file} | jq -r '.id' | ./strtonum_bases.awk > #{SETTINGS["download_path"]}/#{data_type}_ids/#{year}/#{file}`
  end
  
  def kickoff_sequential
    `mkdir -p #{SETTINGS["download_path"]}/comments_ids`
    comment_manifest.each do |year, month_files|
      `mkdir -p #{SETTINGS["download_path"]}/comments_ids/#{year}`
      month_files.each do |month_file|
        ExtractIDs.new.perform(year, month_file, "comments")
      end
    end
    `mkdir -p #{SETTINGS["download_path"]}/submissions_ids`
    submission_manifest.each do |year, month_files|
      `mkdir -p #{SETTINGS["download_path"]}/submissions_ids/#{year}`
      month_files.each do |month_file|
        ExtractIDs.new.perform(year, month_file, "submissions")
      end
    end
  end

  def kickoff
    `mkdir -p #{SETTINGS["download_path"]}/comments_ids`
    comment_manifest.each do |year, month_files|
      month_files.each do |month_file|
        ExtractIDs.perform_async(year, month_file, "comments")
      end
    end
    `mkdir -p #{SETTINGS["download_path"]}/submissions_ids`
    submission_manifest.each do |year, month_files|
      month_files.each do |month_file|
        ExtractIDs.perform_async(year, month_file, "submissions")
      end
    end
  end
end

