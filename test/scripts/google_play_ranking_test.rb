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
      "rank"=>"9",
      "app_id"=>"jp.co.mcdonalds.android",
      "url"=> "https://play.google.com/store/apps/details?id=jp.co.mcdonalds.android&feature=apps_topselling_free",
      "thumbnail"=> "https://lh3.ggpht.com/kxjCwlsfs-lcTh1kJw4ociNTX1EEa80NDpdYnL_lzfwRiIF1TbH9yA78BhBplPm6Pd4=w78-h78",
      "developer"=>"日本マクドナルド株式会社",
      "name"=>"マクドナルド公式アプリ",
      "price"=>"無料",
      "rating"=>"評価: 星 3.6 個（良い）"}
    expect = {"store_type"=>1,
      "rank"=>9,
      "app_id"=>"jp.naver.SJLINEPANG",
      "url"=>"https://play.google.com/store/apps/details?id=jp.naver.SJLINEPANG",
      "thumbnail"=>
    "https://lh3.ggpht.com/qy40qQUSRMgNNkISVtr_neCP-ydrsDYT5ek0f5gWY6tvb7rxCZLeeVUZhx5HZjChvTM=w170",
      "developer"=>"LINE Corporation",
      "name"=>" LINE POP  ",
      "rating"=>3.61,
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
      "rank"=>"33",
      "app_id"=>"jp.dxumi",
      "url"=> "https://play.google.com/store/apps/details?id=jp.dxumi&feature=apps_topselling_new_paid",
      "thumbnail"=> "https://lh6.ggpht.com/81c6gcJrJeLXklCEhYo5U1yfg7sCC9v0eAMFBxGjaMV69sbUxVdP9czXBwV5-VNh2nll=w78-h78",
      "developer"=>"sanyohanbai co.,ltd",
      "name"=>"CRデラックス海物語",
      "rating"=>"評価: 星 3.8 個（良い）",
      "price"=>"￥1,300"}
    expect = {"store_type"=>1,
      "rank"=>9,
      "app_id"=>"net.kairosoft.android.noujou_ja",
      "url"=>
        "https://play.google.com/store/apps/details?id=net.kairosoft.android.noujou_ja",
      "thumbnail"=>
        "https://lh3.ggpht.com/-Lw2bRG72izB-f5vhBJLK4SZWX5WLS2BvqPzDAPu3NPIrAskVXfmU9IuYe213cb7oas=w170",
      "developer"=>"Kairosoft Co.,Ltd",
      "name"=>" 大空ヘクタール農園  ",
      "rating"=>4.75,
      "price"=>"￥450"}

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
