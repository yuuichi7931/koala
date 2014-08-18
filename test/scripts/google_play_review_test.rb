# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/script_helper.rb'
require 'pp'

class GooglePlayReviewTest < Test::Unit::TestCase
  def setup
    app = Apps.new(
      :app_id => 'com.example',
      :name => 'example'
    )
    @obj = GooglePlayReview.new(app)
  end

  # def teardown
  # end

  def test_fetch_reviews
    @obj.stubs(:_get_csv_name).returns('reviews_com.example_201408.csv')
    @obj.stubs(:_get_csv_path).returns(File.dirname(__FILE__) + '/reviews/reviews_com.example_201408.csv')
    @obj.stubs(:_copy_csv).returns(1)

    @obj.fetch_reviews
  end

  def test__get_csv_name
    Time.stubs(:now).returns(Time.local(2014,8,14))
    assert_equal('reviews_com.example_201408.csv',@obj._get_csv_name)
  end

  def test__parse_csv
    @obj.stubs(:_get_csv_path).returns(File.dirname(__FILE__) + '/reviews/reviews_com.example_201408.csv')
    reviews = @obj._parse_csv 'test'
    assert_equal(3, reviews.size)

    expect = {
      :star=>"1",
      :date=> Time.at(1407032342061/1000),
      :title=>"Nice!!",
      :body=>"Great App!!!",
      :version=>"115",
      :device=>"201K",
      :app_id=> 'com.example'
    }
    assert_equal("1", reviews[1][:star])
    assert_equal(2014, reviews[1][:date].year)
    assert_equal(8, reviews[1][:date].mon)
    assert_equal(3, reviews[1][:date].day)
    assert_equal("Nice!!", reviews[1][:title])
    assert_equal("Great App!!!", reviews[1][:body])
    assert_equal("115", reviews[1][:version])
    assert_equal("201K", reviews[1][:device])
    assert_equal("com.example", reviews[1][:app_id])
  end
end
