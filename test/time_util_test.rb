# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + '/test_helper'

class AppTest < Test::Unit::TestCase
  include Koala::Util::TimeUtil

  def test_get_month_list
    expect = ['2012-03',
      '2012-04',
      '2012-05',
      '2012-06',
      '2012-07',
      '2012-08',
      '2012-09',
      '2012-10',
      '2012-11',
      '2012-12',
      '2013-01',
      '2013-02',
      '2013-03',
      '2013-04',
      '2013-05',
      '2013-06',
      '2013-07',
    ]
    from = Time.parse('2012/03/03 12:33:22')
    to   = Time.parse('2013/07/03 17:30:22')
    assert_equal expect, get_month_list(from, to)
  end

end
