# -*- encoding: utf-8 -*-

require 'rubygems'
require 'nokogiri'
require 'open-uri'

$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << File.dirname(__FILE__) + '/../config'
require 'abstract_ranking'

class GooglePlayRanking < AbstractRanking

  STORE_TYPE = 1

  # if script failed to register apps, this method returns -1
  # if script failed to register ranking records, this method returns -2
  def fetch_ranking(opt={})
    opt[:store_type] = STORE_TYPE
    rankings = croll(opt)
    (1..7).each do |page|
      opt[:page] = page
      result = croll(opt)
      rankings.concat result
    end

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

  def fetch_new_paid_ranking(opt)
    opt[:ranking_type] = 3
    fetch_ranking(opt)
  end

  def fetch_new_free_ranking(opt)
    opt[:ranking_type] = 4
    fetch_ranking(opt)
  end

  def get_ranking_url(opt)
    url = ""
    opt[:ranking_type] = 0 unless opt[:ranking_type]

    categories = {
      0 => 'topselling_free',
      1 => 'topselling_paid',
      2 => 'topgrossing',
      3 => 'topselling_new_paid',
      4 => 'topselling_new_free',
    }
    category = categories[opt[:ranking_type]]
    return url unless category
    
    if opt[:page]==nil || opt[:page]==0
      url = "https://play.google.com/store/apps/collection/#{category}"
    else 
      start = 24 * opt[:page].to_i
      url = "https://play.google.com/store/apps/collection/#{category}?start=#{start}&num=24"
    end

    return url
  end

  def croll(opt={})
    url = get_ranking_url(opt)
    opt[:base_url] = "https://play.google.com"

    begin
      html = open(url).read
    rescue Exception => e
      p e
    end
    rankings = get_ranking(html, opt)
    return rankings
  end

  def get_ranking(html, opt)
    records = [];
    begin
      doc = Nokogiri.HTML(html)
      doc.xpath('//li[@class="goog-inline-block"]').each do |node|
        app = parse_ranking_app(node, opt)
        records.push app
      end

      doc.xpath('//li[@class="goog-inline-block z-last-child"]').each do |node|
        app = parse_ranking_app(node, opt)
        records.push app
      end
    rescue => e
      p e
    end

    return records
  end

  def parse_ranking_app(node, opt)
      app = {}
      app["store_type"] = STORE_TYPE
      app["rank"]       = node.xpath(".//div[@class='ordinal-value']")[0].text
      app["app_id"]     = node["data-docid"]
      app["url"]        = opt[:base_url] + node.xpath(".//a")[0]["href"]
      app["thumbnail"]  = node.xpath(".//img")[0]["src"]
      app["developer"]  = node.xpath(".//a")[2].content
      app["name"]       = node.xpath(".//a")[1]["title"]
      app["developer"]  = node.xpath(".//a")[2].content
      if node.xpath(".//div[@class='ratings goog-inline-block']")[0]
        app["rating"]     = node.xpath(".//div[@class='ratings goog-inline-block']")[0]["title"]
      else
        app["rating"]     = ""
      end
      app["price"]      = node.xpath(".//span[@class='buy-offer default-offer']")[0]["data-docprice"]
      return app
  end

  def fetch_genres
    apps = RankingApps.no_genres
    apps.each do |app|
      html = croll_app(app[:app_id])
      next unless html

      target = RankingApps.filter(:app_id => app[:app_id]).first
      target[:genre] = get_genre(html)
      target.save
    end
  end

  def croll_app(app_id)
    url = "https://play.google.com/store/apps/details?id=#{app_id}"
    begin
      html = open(url).read
      return html
    rescue OpenURI::HTTPError
      return nil
    end
  end

  def get_genre(html)
    genre = ''
    doc = Nokogiri.HTML(html)
    find_category_flag = 0
    doc.xpath('//dl[@class="doc-metadata-list"]')[0].children.each do |child|
      if find_category_flag == 1
        genre = child.content
        break
      end

      find_category_flag = 1 if child.content=='カテゴリ:'
    end

    return genre
  end

end

class AppStoreRankingException < Exception; end
