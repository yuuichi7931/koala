# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/script_helper.rb'

class AppStoreRankingTest < Test::Unit::TestCase
  def setup
    @obj = AppStoreRanking.new
  end

  # def teardown
  # end

  def test_get_reviews
    # do something
  end

  def test_get_ranking_url
    opt = {:limit => 100}
    expect = "https://itunes.apple.com/jp/rss/topfreeapplications/limit=#{opt[:limit].to_s}/xml"
    assert_equal(expect, @obj.get_ranking_url(opt))

    opt = {:limit => 100,:genre => "6005"}
    expect = "https://itunes.apple.com/jp/rss/topfreeapplications/limit=#{opt[:limit].to_s}/genre=#{opt[:genre]}/xml"
    assert_equal(expect, @obj.get_ranking_url(opt))

    opt = {:limit => 100,:ranking_type => 1}
    expect = "https://itunes.apple.com/jp/rss/toppaidapplications/limit=#{opt[:limit].to_s}/xml"
    assert_equal(expect, @obj.get_ranking_url(opt))

    opt = {:limit => 100,:ranking_type => 2}
    expect = "https://itunes.apple.com/jp/rss/topgrossingapplications/limit=#{opt[:limit].to_s}/xml"
    assert_equal(expect, @obj.get_ranking_url(opt))
  end
end
