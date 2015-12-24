# -*- encoding: utf-8 -*-
$LOAD_PATH << File.dirname(__FILE__)
require 'abstract_review'

class AppStoreReview < AbstractReview
  def fetch_reviews(app_id, pages=0)
    review = Kansou::AppStoreReview.new(app_id)
    (0..pages).each do |page|
      puts "processing ID:#{app_id} #{(page+1).to_s}/#{(pages+1).to_s}...\n"

      reviews = review.fetch(page) # => prints reviews as array
      insert_reviews(reviews)
    end
  end
end
