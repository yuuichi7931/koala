# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + '/test_helper'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Koala::Helpers

  def test_formatted_date
    assert_equal '2012/03/03', formatted_date('2012/03/03 12:33:22')
  end

  def test_formatted_rate
    assert_equal '2.0', formatted_rate('aaa2.0bjeiwahf')
  end

  def test_add_wbr
    assert_equal '1234', add_wbr('1234')
    assert_equal '1234<wbr>5678', add_wbr('12345678')
  end

  def test_ranking_title
    expect = 'ランキング > App Store > トップ無料 ( 2013/03/03 )'
    assert_equal expect, ranking_title(0,0,'2013/03/03')

    expect = 'ランキング > Google Play > トップ無料 ( 2013/03/03 )'
    assert_equal expect, ranking_title(1,0,'2013/03/03')
  end

  def test_get_genre
    app = {:name => 'test', :genre => 'ソーシャルネットワーキング'}
    expect = {:name=>"ソーシャルネットワーキング", :id=>"6005"}
    assert_equal expect, get_genre(app)
  end
end
