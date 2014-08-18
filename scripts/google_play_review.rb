# -*- encoding: utf-8 -*-

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'net/http'
require 'net/https'
require "csv"

$LOAD_PATH << File.dirname(__FILE__)
require 'abstract_review'

class GooglePlayReview < AbstractReview
  CSV_DIR = File.dirname(__FILE__) + '/../csv'

  def initialize(app)
    @app = app
  end

  def fetch_reviews
    csv = _get_csv_name
    result = _copy_csv(csv)
    return if result == -1

    reviews = _parse_csv(csv)
    insert_reviews(reviews)
  end

  def _get_csv_name
    ym = Time.now.strftime("%Y%m")
    csv = "reviews_#{@app[:app_id]}_#{ym}.csv"
    return csv
  end

  def _get_csv_path(csv)
    csv_path = CSV_DIR + '/' + csv
  end

  def _copy_csv(csv)
    return -1 unless ScriptConfig::GS_COMMAND
    return -1 unless @app[:bucket_id]

    cmd = ScriptConfig::GS_COMMAND
    bucket_id = @app[:bucket_id]
    value = `#{cmd} cp gs://#{bucket_id}/reviews/#{csv} #{CSV_DIR}`
    return -1 if $? 
    return 1
  end

  def _parse_csv(csv)
    csv_path = _get_csv_path(csv)
    utf16 = open(csv_path, "rb:BOM|UTF-16"){|f| f.read }
    utf8 = utf16.encode("UTF-8")
    reviews = []
    CSV.parse(utf8, col_sep: ",", row_sep: "\n", headers: :first_row) do |row|
      next if row["Review Title"]==nil && row["Review Text"]==nil
      review = {
        :star => row["Star Rating"],
        :date => Time.at(row["Review Submit Millis Since Epoch"].to_f / 1000.0),
        :title => row["Review Title"],
        :body => row["Review Text"],
        :version => row["App Version"],
        :device => row["Reviewer Hardware Model"],
        :app_id => @app[:app_id]
      }
      reviews.push review
    end
    return reviews
  end
end
