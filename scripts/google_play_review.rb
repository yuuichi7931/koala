# -*- encoding: utf-8 -*-

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'net/http'
require 'net/https'

$LOAD_PATH << File.dirname(__FILE__)
require 'abstract_review'

class GooglePlayReview < AbstractReview

  def initialize
    super
  end

  def get_reviews(html, app_id)
    dates = []
    titles = []
    bodies = []
    stars = []
    users = []
    versions = []
    devices = []
    i = 0

    doc = Nokogiri.HTML(html,nil,"UTF-8")
    doc.xpath("//div[@class='single-review']").each do |node|
      node.xpath(".//span[@class='review-title']").each do |title_node|
        titles.push(title_node.text)
      end

      body_node = node.xpath(".//div[@class='review-body']")
      if 0 < body_node.count
        bodies.push(body_node.text)
      else
        bodies.push("")
      end

      node.xpath(".//span[@class='review-date']").each do |date_node|
        dates.push(date_node.text)
      end

      node.xpath(".//div[@class='current-rating']").each do |star_node|
        if md = star_node.attributes['style'].value.match("width: ([0-9]+)")
          star  = md[1].to_i / 20
          stars.push(star)
        end 
      end

      node.xpath("//span[@class='author-name']").each do |user_node|
        users.push(user_node.text.strip)
      end
    end

    items = [];
    count = stars.size - 1
    (0..count).each do |key|
      item = {
        :star => stars[key],
        :user => users[key],
        :date => dates[key],
        :title => titles[key],
        :body => bodies[key],
        :version => versions[key],
        :device => devices[key],
        :app_id => app_id
      }
      items.push(item)
    end
    return items
  end

  def fetch_reviews(app_id, pages)
    (0..pages).each do |page|
      puts "processing ID:#{app_id} #{(page+1).to_s}/#{(pages+1).to_s}...\n"

        http = Net::HTTP.new('play.google.com', 443)
      http.use_ssl = true
      path = "/store/getreviews"
      data = "id=#{app_id}&reviewSortOrder=0&reviewType=1&pageNum=#{page}"
        response = http.post(path, data)
      html_string = JSON.parse(response.body.gsub(/\)\]\}\'/,""))[0][2]
      reviews = get_reviews(html_string, app_id)
      insert_reviews(reviews)
    end
  end

  def get_version(text)
    version = nil
    if /、バージョン ([0-9\.]+)/ =~ text
      version = $1
    end

    version = get_version_with_parenthese(text) unless version
    version = get_version_without_device(text) unless version
    return version
  end

  def get_version_with_parenthese(text)
    version = nil
    if /（([^）]+)、バージョン ([^）]+)）/ =~ text
      version = $2
    end
    return version
  end

  def get_version_without_device(text)
    version = nil
    if /バージョン ([0-9\.]+)<span/ =~ text
      version = $1
    end
    return version
  end

  def get_device(text)
    device = nil
    if /- ([A-Za-z].+)、バージョン/ =~ text
      device = $1
    end
    return get_device_with_parenthese(text) unless device
    return device
  end

  def get_device_with_parenthese(text)
    device = nil
    if /（([^）]+)、バージョン (.+)）/ =~ text
      device = $1
    end
    return device
  end
end
