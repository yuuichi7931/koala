# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/script_helper.rb'

class GooglePlayReviewTest < Test::Unit::TestCase
  def setup
    @obj = GooglePlayReview.new
  end

  # def teardown
  # end

  def test_get_reviews
    f = open(File.dirname(__FILE__) + '/reviews/google_play.txt')
    data = f.read
    reviews = @obj.get_reviews(data, 'com.twitter.android')
    expect = {:star=>2,
	 :user=>"age aze",
	 :date=>"2014年8月9日",
	 :title=>"反応しない",
	 :body=>
	  " 反応しない 各ニュースを見ようとタップしても何も反応せず。よって、ニュース一覧では見出ししか情報が入ってこない。Xperia so01f  全文を表示  ",
	 :version=>nil,
	 :device=>nil,
	 :app_id=>"com.twitter.android"}

    assert_equal(20, reviews.size)
    assert_equal(expect, reviews[12])
  end
end
