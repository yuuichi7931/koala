# -*- encoding: utf-8 -*-

require 'rubygems'
require 'nokogiri'
require 'open-uri'

$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << File.dirname(__FILE__) + '/../config'
require 'abstract_ranking'

class GooglePlayRanking < AbstractRanking

  STORE_TYPE = 1
  PAGING_SIZE = 60

  # if script failed to register apps, this method returns -1
  # if script failed to register ranking records, this method returns -2
  def fetch_ranking(opt={})
    opt[:store_type] = STORE_TYPE
    rankings = croll(opt)
    (1..3).each do |page|
      opt[:page] = page
      result = croll(opt)
      rankings.concat result
    end
    puts rankings.length.to_s + " RECORDS"

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
    puts "GooglePlayRanking::fetch_free_ranking"
    opt[:ranking_type] = 0
    opt[:page] = nil
    fetch_ranking(opt)
  end

  def fetch_paid_ranking(opt)
    puts "GooglePlayRanking::fetch_paid_ranking"
    opt[:ranking_type] = 1
    opt[:page] = nil
    fetch_ranking(opt)
  end

  def fetch_grossing_ranking(opt)
    puts "GooglePlayRanking::fetch_grossing_ranking"
    opt[:ranking_type] = 2
    opt[:page] = nil
    fetch_ranking(opt)
  end

  def fetch_new_paid_ranking(opt)
    puts "GooglePlayRanking::fetch_new_paid_ranking"
    opt[:ranking_type] = 3
    opt[:page] = nil
    fetch_ranking(opt)
  end

  def fetch_new_free_ranking(opt)
    puts "GooglePlayRanking::fetch_new_free_ranking"
    opt[:ranking_type] = 4
    opt[:page] = nil
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
      start = PAGING_SIZE * opt[:page].to_i
      url = "https://play.google.com/store/apps/collection/#{category}?start=#{start}&num=#{PAGING_SIZE}"
    end
    puts "GET: " + url

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
      i = 0
      doc.xpath('//div[@class="card no-rationale square-cover apps small"]').each do |node|
        i += 1
        opt[:page] = 0 unless opt[:page]
        opt[:rank] = i + (PAGING_SIZE * opt[:page].to_i)
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
      app["rank"]       = opt[:rank]
      app["app_id"]     = node["data-docid"]
      app["url"]        = opt[:base_url] + node.xpath(".//a")[0]["href"]
      app["thumbnail"]  = node.xpath(".//img")[0]["src"]
      app["developer"]  = node.xpath(".//a[@class='subtitle']")[0].content
      app["name"]  = node.xpath(".//a[@class='title']")[0].content

      if node.xpath(".//div[@class='current-rating']")[0]
        rating = node.xpath(".//div[@class='current-rating']")[0]["style"].sub('width: ','').sub('%;','').to_f
        app["rating"] = rating_to_star rating
      else
        app["rating"] = ""
      end

      app["price"] = node.xpath(".//span[@class='price buy']")[0].content.strip
      return app
  end

  def rating_to_star(rating)
    star = 0
    if 0 < rating
      star = (rating / 20).round(2)
    end
    return star
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
