# -*- encoding: utf-8 -*-
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'time'

$LOAD_PATH << File.dirname(__FILE__)
require 'abstract_ranking'

class AppStoreRanking < AbstractRanking

  STORE_TYPE = 0

  # if script failed to register apps, this method returns -1
  # if script failed to register ranking records, this method returns -2
  def fetch_ranking(opt)
    if opt[:limit]==nil
      opt[:limit] = 100
    end
    opt[:store_type] = STORE_TYPE

    url = get_ranking_url(opt)

    xml = open(url).read
    rankings = parse_rankings(xml)
    if register_apps(rankings)
      unless register_rankings(rankings, opt)
        return -2
      end
    else
      return -1
    end
    return 1
  end

  def fetch_free_ranking(opt)
    opt[:ranking_type] = 0
    fetch_ranking(opt)
  end

  def fetch_paid_ranking(opt)
    opt[:ranking_type] = 1
    fetch_ranking(opt)
  end

  def fetch_grossing_ranking(opt)
    opt[:ranking_type] = 2
    fetch_ranking(opt)
  end

  def fetch_new_ranking(opt)
    opt[:ranking_type] = 3
    fetch_ranking(opt)
  end

  def get_ranking_url(opt)
    url = ""
    opt[:ranking_type] = 0 unless opt[:ranking_type]
    categories = {
      0 => 'topfreeapplications',
      1 => 'toppaidapplications',
      2 => 'topgrossingapplications',
      3 => 'newapplications',
    }
    category = categories[opt[:ranking_type]]
    return url unless category
    
    if opt[:genre]==nil || opt[:genre].empty?
      url = "https://itunes.apple.com/jp/rss/#{category}/limit=#{opt[:limit].to_s}/xml"
    else 
      url = "https://itunes.apple.com/jp/rss/#{category}/limit=#{opt[:limit].to_s}/genre=#{opt[:genre]}/xml"
    end

    return url
  end

  def parse_rankings(xml)
    document = Nokogiri::XML(xml)
    ns = {
      "atom" => "http://www.w3.org/2005/Atom",
      "im" => "http://itunes.apple.com/rss"
    }

    apps = []
    rank = 1
    document.xpath('.//atom:entry', ns).each do |elm|
      app = {}
      app["store_type"] = STORE_TYPE
      app["app_id"]     = elm.xpath('.//atom:id',ns)[0]["id"].to_s
      app["name"]       = elm.xpath('.//im:name',ns)[0].content
      app["genre"]      = elm.xpath('.//atom:category',ns)[0]["label"]
      app["developer"]  = elm.xpath('.//im:artist',ns)[0].content
      app["price"]      = elm.xpath('.//im:price',ns)[0].content
      app["url"]        = elm.xpath('.//atom:link',ns)[0]["href"]
      app["thumbnail"]  = elm.xpath('.//im:image[@height="100"]',ns)[0].content
      app["rank"]       = rank
      apps.push app

      rank += 1
    end

    return apps
  end
end

class AppStoreRankingException < Exception; end
