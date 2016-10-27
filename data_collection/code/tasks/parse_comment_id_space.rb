class ParseCommentIdSpace
  include MongoMapper::Document
  include Sidekiq::Worker
  key :id_start_range_inclusive, Integer
  key :id_end_range_inclusive, Integer
  key :id_start_range_inclusive_36, String
  key :id_end_range_inclusive_36, String
  key :width, Integer
  key :prev_file, String
  key :file, String
  key :next_file, String
  #for each source file, walk through the sequential IDs and identify gaps
  def perform(source_file)
    IdSpacer.check_gaps(source_file, ParseCommentIdSpace)
  end

  def self.kickoff
    self.source_files.each do |source_file|
      self.perform_async(source_file)
    end
  end

  def self.source_files
    Dir[File.dirname(__FILE__) + '/../../extracted_data/*.csv'].select{|x| x.include?("comments") && x.include?("_sorted")}
  end
end
