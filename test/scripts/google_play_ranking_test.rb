# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/script_helper.rb'

class GooglePlayRankingTest < Test::Unit::TestCase
  def setup
    @obj = GooglePlayRanking.new
  end

  # def teardown
  # end

  def test_get_ranking
    f = open(File.dirname(__FILE__) + '/ranking/topselling_free.html')
    data = f.read
    opt = {:base_url => "https://play.google.com"}
    records = @obj.get_ranking(data, opt)

    expect = {"store_type"=>1,
      "rank"=>9,
      "app_id"=>"jp.co.yahoo.android.yjtop",
      "url"=> "https://play.google.com/store/apps/details?id=jp.co.yahoo.android.yjtop",
      "thumbnail"=> "https://lh5.ggpht.com/hDO1Bl22b3qn98cZyzJvcFxysiiLrwC4ps_FlKNDIVQofEtyCCN2UqK-__YF3duOyjc=w170",
      "developer"=>"Yahoo Japan Corp.",
      "name"=>"   Yahoo! JAPAN   ",
      "rating"=>4.12,
      "price"=>"無料"}

    assert_equal(60, records.size)
    assert_equal(expect, records[8])
  end

  def test_get_new_paid_ranking
    f = open(File.dirname(__FILE__) + '/ranking/topselling_paid.html')
    data = f.read
    opt = {:base_url => "https://play.google.com"}
    records = @obj.get_ranking(data, opt)

    expect = {"store_type"=>1,
      "rank"=>9,
      "app_id"=>"com.square_enix.android_googleplay.dq8j",
      "url"=> "https://play.google.com/store/apps/details?id=com.square_enix.android_googleplay.dq8j",
      "thumbnail"=> "https://lh5.ggpht.com/fbk12U4BDy2TfC_biaojagY-x4TpmifO-napNG-RzWxELQpMigBRlaJ-dkQxjVp8ANkn=w170",
      "developer"=>"SQUARE ENIX Co.,Ltd.",
      "name"=>"   ドラゴンクエストVIII 空と海と大地と呪われし姫君   ",
      "rating"=>4.33,
      "price"=>"￥2,800"}

    assert_equal(60, records.size)
    assert_equal(expect, records[8])
  end

  def test_get_ranking_url
    opt = {}
    expect = "https://play.google.com/store/apps/collection/topselling_free"
    assert_equal(expect, @obj.get_ranking_url(opt))

    opt = {:page => 1,:ranking_type => 1}
    expect = "https://play.google.com/store/apps/collection/topselling_paid?start=60&num=60"
    assert_equal(expect, @obj.get_ranking_url(opt))

    opt = {:page => 1,:ranking_type => 2}
    expect = "https://play.google.com/store/apps/collection/topgrossing?start=60&num=60"
    assert_equal(expect, @obj.get_ranking_url(opt))

    opt = {:page => 1,:ranking_type => 3}
    expect = "https://play.google.com/store/apps/collection/topselling_new_paid?start=60&num=60"
    assert_equal(expect, @obj.get_ranking_url(opt))

    opt = {:page => 1,:ranking_type => 4}
    expect = "https://play.google.com/store/apps/collection/topselling_new_free?start=60&num=60"
    assert_equal(expect, @obj.get_ranking_url(opt))
  end
end
