# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + '/test_helper'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Koala::Helpers

  def app
    Sinatra::Application
  end

  def test_my_default
    get '/'
    assert_equal 200, last_response.status
  end

  def test_app_id
    get '/app/123'
    assert_equal 200, last_response.status
  end

  def test_app_id_with_version
    get '/app/123/1.2.1'
    assert_equal 200, last_response.status
  end

  def test_default_ranking
    get '/ranking'
    assert_equal 200, last_response.status
  end

  def test_default_graph
    get '/graph'
    assert_equal 200, last_response.status
  end

  def test_some_graph
    get '/graph', :app_id => 'hoge'
    assert_equal 200, last_response.status
  end

  def test_with_params
    get '/meet', :name => 'Frank'
    assert_equal 404, last_response.status
  end

  def test_post_app
    post '/app/create', :app_id => 'com.example', :app_name => 'test_app'
    assert_equal 200, last_response.status
  end
end
