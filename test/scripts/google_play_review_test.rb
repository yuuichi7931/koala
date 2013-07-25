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
    expect = {:star=>3,
	 :user=>"ゆうこのだ",
	 :date=>"2013年7月15日",
	 :title=>"改善お願いします(；゜∀゜)",
	 :body=>
	  " 改善お願いします(；゜∀゜) ゲームは楽しいけれど、途中で画面が動かなくなり、電池を抜いて入れ直さないと動きません…改善お願いします(。>д<)  全文を表示  ",
	 :version=>nil,
	 :device=>nil,
	 :app_id=>"com.twitter.android"}


    assert_equal(10, reviews.size)
    assert_equal(expect, reviews[8])
  end
end
