# -*- encoding: utf-8 -*-
$LOAD_PATH << File.dirname(__FILE__)
require 'abstract_review'

class GooglePlayReview < AbstractReview
  def fetch_reviews(app_id, pages)
    review = Kansou::GooglePlayReview.new(app_id)
    puts "processing ID:#{app_id} ...\n"

    reviews = review.fetch # => prints reviews as array
    insert_reviews(reviews)
  end
end
