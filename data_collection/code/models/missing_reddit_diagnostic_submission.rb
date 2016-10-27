class MissingRedditDiagnosticSubmission
  include MongoMapper::Document
  key :subreddit, String
  key :submission_id, String
  key :submission_id_int, Integer
  key :referring_comment_id, String
  key :referring_comment_id_int, Integer
  key :referring_time, Time
end