# -*- encoding: utf-8 -*-

require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require File.dirname(__FILE__) + '/config/init'
require 'koala/helpers'
require 'koala/util/string'
require 'koala/util/time_util'


use Rack::Session::Cookie,
  :expire_after => 2592000,
  :secret => 'ChangeMe'

helpers Koala::Helpers

before do
  @apps = Apps.all
  @app_store_genres = AppConfig::APP_STORE_RANKING_GENRES
  @genre_id = params[:genre_id]
  @genre_name = _get_genre_name(params[:genre_id])
end

get '/' do
  @app  = nil

  if params[:app_id]
    @app = Apps.filter(:app_id => params[:app_id]).first
  else
    @app = @apps.first
  end

  if @app
    @versions = Reviews.versions(@app[:app_id]).sort_by{|val| -val[:version].to_f}
    if params[:version] && params[:version]!='ALL'
      @version = params[:version].to_s
      @reviews = Reviews.filter(:app_id => @app[:app_id], :version => params[:version])
    elsif params[:version] && params[:version]=='ALL'
      @reviews = Reviews.filter(:app_id => @app[:app_id])
    elsif @versions != nil && 0 < @versions.length
      @version = @versions.first[:version]
      @reviews = Reviews.filter(:app_id => @app[:app_id], :version => @version)
    else
      @reviews = Reviews.filter(:app_id => @app[:app_id])
    end
    @keywords = _get_keywords(@reviews)
    @stars = _get_star_count(@reviews)
  else
    @stars = _get_star_count
  end

  erb :index
end

post '/app/create' do
  begin
  app = Apps.create(:app_id =>  params[:app_id],
                    :name => params[:app_name],
                    :created_at => Time.now)
  'ok'
  rescue => exception
    log.debug(exception)
    halt 403, "bad parameters"
  end
end

post '/app/delete' do
  begin
    Apps[params[:id]].delete
    'ok'
  rescue => exception
    p(exception)
    halt 403, "bad parameters"
  end
end

get '/ranking' do
  params[:store_type] = 0 unless params[:store_type]
  params[:ranking_type] = 0 unless params[:ranking_type]
  @store_type = params[:store_type]
  @ranking_type = params[:ranking_type]
  @date = params[:date]
  @date_list = RankingRecords.dates(@genre_id)
  @month_list = []
  return erb :ranking unless @date_list.first

  unless @date
    latest_time = @date_list.first[:date]
    @date = latest_time.strftime("%Y-%m-%d")
  end

  @ranking_path = "?store_type=" + @store_type.to_s
  if @genre_id
    @ranking_path += "&genre_id=" + @genre_id
    @records = RankingRecords.filter(:store_type => @store_type,
                                     :date => Time.parse(@date),
                                     :ranking_type => @ranking_type,
                                     :ranking_records__genre => @genre_id)\
                                     .join_table(:left, :ranking_apps___app, [:app_id]).order(:rank)
  else
    @records = RankingRecords.filter(:store_type => @store_type,
                                     :date => Time.parse(@date),
                                     :ranking_type => @ranking_type,
                                     :ranking_records__genre => nil)\
                                     .join_table(:left, :ranking_apps___app, [:app_id]).order(:rank)
  end

  if @ranking_type
    @ranking_path += "&ranking_type=" + @ranking_type.to_s
  end

  @genres = {}
  total_count = 0
  @records.each do | record |
    next unless record[:genre]
    if @genres[record[:genre]]
      @genres[record[:genre]] += 1
    else
      @genres[record[:genre]] = 1
    end
    total_count += 1
  end

  erb :ranking
end

get '/ranking/new' do
  params[:store_type] = 0 unless params[:store_type]
  @store_type = params[:store_type]
  @date = params[:date]
  @date_list = RankingRecords.dates(@genre_id)
  return erb :ranking unless @date_list.first

  @is_new = 1
  unless @date
    latest_time = @date_list.first[:date]
    @date = latest_time.strftime("%Y-%m-%d")
  end

  @records = RankingRecords.news(@store_type, @date, @genre_id)

  @genres = {}
  total_count = 0
  @records.each do | record |
    next unless record[:genre]
    if @genres[record[:genre]]
      @genres[record[:genre]] += 1
    else
      @genres[record[:genre]] = 1
    end
    total_count += 1
  end

  erb :ranking
end

get '/graph' do
  if params[:app_id]
    @app = RankingApps.filter(:app_id => params[:app_id]).first
  else
    return 'not found'
  end

  if @app==nil
    return 'not found'
  end

  if @genre_id
    @records = RankingRecords.filter(
      :app_id => params[:app_id],
      :ranking_type => params[:ranking_type],
      :ranking_records__genre => @genre_id
    )\
      .join_table(:left, :ranking_apps___app, [:app_id]).order(Sequel.desc(:date))
  else
    @records = RankingRecords.filter(
      :app_id => params[:app_id],
      :ranking_type => params[:ranking_type],
      :ranking_records__genre => nil
    )\
      .join_table(:left, :ranking_apps___app, [:app_id]).order(Sequel.desc(:date))
  end

  erb :graph
end

get '/csv' do
  if @genre_id
    @records = RankingRecords.filter(:app_id => params[:app_id], :ranking_records__genre => @genre_id)\
      .join_table(:left, :ranking_apps___app, [:app_id]).order(Sequel.desc(:date))
  else
    @records = RankingRecords.filter(:app_id => params[:app_id], :ranking_records__genre => nil)\
      .join_table(:left, :ranking_apps___app, [:app_id]).order(Sequel.desc(:date))
  end
  csv = "Date,Rank\n"
  @records.each do |r|
    csv += r[:date].strftime("%Y-%m-%d") + "," + r[:rank].to_s + "\n"
  end

  return csv
end



get '/tsv' do
  if params[:app_id]
    @app = RankingApps.filter(:app_id => params[:app_id]).first
  else
    return ''
  end

  @records = RankingRecords.filter(:app_id => params[:app_id])\
    .join_table(:left, :ranking_apps___app, [:app_id]).order(:rank)
  tsv = ''
  @records.each do |r|
    tsv += r[:date].strftime("%Y-%m-%d") + "\t" + r[:rank].to_s + "\n"
  end

  return tsv
end

get '/ranking/apps' do
  erb :apps_graph
end

get '/ranking/tsv' do
  params[:store_type] = 0 unless params[:store_type]
  params[:ranking_type] = 0 unless params[:ranking_type]
  @store_type = params[:store_type]
  @ranking_type = params[:ranking_type]

  ym = params[:ym]
  ym = '2013-06'

  @records = RankingRecords.filter(:store_type => @store_type,
                                   :ranking_type => @ranking_type,
                                   :ranking_records__genre => nil)\
                                   .filter('date LIKE ?', ym + '%')\
                                   .filter('rank <= 10')\
                                   .join_table(:left, :ranking_apps___app, [:app_id]).order(:rank)

  grouped_data = {}
  apps = []
  @records.each do |r|
    rank_date = r[:date].strftime("%Y%m%d")
    app_name = r[:name]
    apps.push app_name

    grouped_data[rank_date] = {} unless grouped_data[rank_date]
    grouped_data[rank_date][app_name] = r[:rank]
  end

  apps.uniq!
  title = "date\t" + apps.join("\t") + "\n"
  tsv = title

  app_count = apps.count
  grouped_data.each do |date, record|
    row = [].fill("NA",0,app_count + 1)
    row[0] = date

    record.each do |name, rank|
       app_index = apps.index(name)
       row[app_index + 1] = rank
    end

    tsv += row.join("\t") + "\n"
  end

  content_type "text/tsv"
  attachment "#{ym}.tsv"
  tsv.sjisable.encode('Shift_JIS')
end

#
# private methods
#

def _get_star_count(reviews=[])
  stars = [0,0,0,0,0]
  reviews.each do |review|
    key = review[:star].to_i - 1
    stars[key] += 1
  end
  return stars
end

def _get_keywords(reviews=[])
  keywords = {}
  reviews.each do |review|
    if review[:nodes]
      nodes = review[:nodes].to_s.split(',')
      nodes.each do |node|
        if keywords[node]
          keywords[node] += 1
        else
          keywords[node] = 1
        end
      end
    end
  end
  return keywords.sort_by{|key, value| -value}
end

def _get_genre_name(genre_id)
  @app_store_genres.each do |genre|
    if genre[:id]==genre_id
      return genre[:name]
    end
  end
  return ''
end
