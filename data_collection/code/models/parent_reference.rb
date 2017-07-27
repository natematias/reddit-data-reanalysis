class ParentReference
  include MongoMapper::Document
  key :found, Boolean
  key :source_year, String
  key :source_file, String
  key :time, Time
  key :subreddit, String
  key :comment_id, String
  key :comment_id_int, Integer
  key :parent_id, String
  key :parent_id_int, Integer
  key :parent_type, String
end