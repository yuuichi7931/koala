# -*- encoding: utf-8 -*-

$LOAD_PATH << File.dirname(__FILE__)
require 'app_store_ranking'
require 'google_play_ranking'

class AppRanking
  def initialize
    super
  end

  def fetch
    begin
      fetch_apple_ranking
    rescue
    end

    begin
      fetch_google_ranking
    rescue
    end
  end

  def fetch_apple_ranking
    opt = {:limit=>200}
    
    task = AppStoreRanking.new
    task.fetch_free_ranking(opt)
    task.fetch_paid_ranking(opt)
    task.fetch_grossing_ranking(opt)
    task.fetch_new_ranking(opt)

    if defined? AppConfig::APP_STORE_RANKING_GENRES
      AppConfig::APP_STORE_RANKING_GENRES.each do |genre|
        opt[:genre] = genre[:id]
        result = task.fetch_free_ranking(opt)
        unless result==1
          puts "fetch_apple_ranking returned error: " + result.to_s
          return false
        end
      end
    end

    #task.fetch_rating

    return true
  end

  def fetch_google_ranking
    opt = {}
    task = GooglePlayRanking.new
    result = task.fetch_free_ranking(opt)
    unless result==1
      puts "fetch_google_ranking returned error: " + result.to_s
    end
    task.fetch_paid_ranking(opt)
    task.fetch_grossing_ranking(opt)
    task.fetch_new_paid_ranking(opt)
    task.fetch_new_free_ranking(opt)

    task.fetch_genres

    return true
  end
end
