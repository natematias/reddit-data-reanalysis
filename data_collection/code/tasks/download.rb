class Download

  def comments_partial_years
    {"2005" => ["12"]}
  end

  def submissions_partial_years
    {"2006" => "01".upto("07").to_a, "2007" => ["01", "02", "03", "06", "07", "10", "11", "12"]}
  end

  def comments_full_years
    Hash["2006".upto((Time.now.year-1).to_s).collect{|y| [y, full_year]}]
  end

  def submissions_full_years
    "2008".upto((Time.now.year-1).to_s)
  end

  def year_to_date
    {Time.now.year.to_s => "01".upto(("0"+(Time.now.strftime("%m").to_i-1).to_s).gsub("00", "0")[-2..1]).to_a}
  end

  def full_year
    "01".upto("12").to_a
  end

  def comments_to_date
    comments_partial_years.merge(comments_full_years).merge(year_to_date)
  end
  
  def submissions_to_date
    submissions_partial_years.merge(submissions_full_years).merge(year_to_date)
  end

  def comment_link(year, month)
    "http://files.pushshift.io/reddit/comments/RC_#{year}-#{month}.bz2"
  end

  def submission_link(year, month)
    "http://files.pushshift.io/reddit/submissions/RS_#{year}-#{month}.bz2"
  end

  def download_all
    `mkdir -p #{SETTINGS["download_path"]}`
    comments_to_date.each do |year, months|
      `mkdir -p #{SETTINGS["download_path"]}/comments`
      `mkdir -p #{SETTINGS["download_path"]}/comments/#{year}`
      months.each do |month|
        `mkdir -p #{SETTINGS["download_path"]}/comments/#{year}`
        `wget -P #{SETTINGS["download_path"]}/comments/#{year} #{comment_link(year, month)}`
      end
    end
    submissions_to_date.each do |year, months|
      `mkdir -p #{SETTINGS["download_path"]}/submissions`
      `mkdir -p #{SETTINGS["download_path"]}/submissions/#{year}`
      months.each do |month|
        `mkdir -p #{SETTINGS["download_path"]}/submissions/#{year}`
        `wget -P #{SETTINGS["download_path"]}/submissions/#{year} #{submission_link(year, month)}`
      end
    end
  end
end