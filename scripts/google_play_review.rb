# -*- encoding: utf-8 -*-
$LOAD_PATH << File.dirname(__FILE__)
require 'abstract_review'

class GooglePlayReview < AbstractReview
  def fetch_reviews(app_id, pages)
    review = Kansou::GooglePlayReview.new(app_id)
    (0..pages).each do |page|
      puts "processing ID:#{app_id} #{(page+1).to_s}/#{(pages+1).to_s}...\n"

      reviews = review.fetch(page + 1) # => prints reviews as array
      insert_reviews(reviews)
    end
  end

end
