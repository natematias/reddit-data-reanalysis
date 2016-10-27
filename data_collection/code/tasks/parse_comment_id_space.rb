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
  def perform(source_file)
    to_insert = []
    prev_index = ParseCommentIdSpace.source_files.index(source_file)-1
    next_index = ParseCommentIdSpace.source_files.index(source_file)+1
    if next_index-prev_index != 1 && prev_index != -1
      prev_last = `tail #{ParseCommentIdSpace.dir+"/"+ParseCommentIdSpace.source_files[prev_index]}`.split("\n").last.to_i
      new_first = `head #{ParseCommentIdSpace.dir+"/"+ParseCommentIdSpace.source_files[prev_index+1]}`.split("\n").first.to_i
      if new_first-prev_last != 1
        to_insert << {id_start_range_inclusive: prev_last+1, id_end_range_inclusive: new_first-1, id_start_range_inclusive_36: base_10_to_36(prev_last+1), id_end_range_inclusive_36: base_10_to_36(new_first-1), width: (new_first-prev_last)-1, prev_file: prev_file, file: file, next_file: next_file}
      end
    end
    last_number = nil
    next_number = nil
    width = 0
    CSV.foreach(ParseCommentIdSpace.dir+"/"+source_file) do |id|
      if to_insert.length >= 3000
        ParseCommentIdSpace.collection.insert(to_insert)
        to_insert = []
      end
      id = id[0].to_i
      next if id == last_number
      if last_number.nil? #if we're starting the file
        last_number = id
      else #else we have set last and need to set new next
        next_number = id
      end
      if !last_number.nil? && !next_number.nil? #then we are in the space now
        if next_number-last_number != 1 #then there's a gap
          width = (next_number-last_number)-1
          to_insert << {id_start_range_inclusive: (next_number-width), id_end_range_inclusive: next_number-1, id_start_range_inclusive_36: base_10_to_36(next_number-width), id_end_range_inclusive_36: base_10_to_36(next_number-1), width: width, prev_file: prev_file, file: file, next_file: next_file} if (next_number-width) != next_number-1
        end
        last_number = next_number
        next_number = nil
      end
    end
    ParseCommentIdSpace.collection.insert(to_insert) if !to_insert.empty?
  end

  def self.dir
    "/home/dgaff/comment_ids"
  end
  def self.kickoff
    self.source_files.each do |source_file|
      self.perform_async(source_file)
    end
  end

  def self.source_files
    `ls #{self.dir}`.split("\n").reject{|x| x.include?(".csv")}.sort
  end
end
