# -*- encoding: utf-8 -*-

class AbstractRanking

  def initialize
    super
  end

  def register_apps(apps)
    apps.each do |app|
      next unless app["app_id"]
      if RankingApps.filter(:app_id => app["app_id"]).count == 0
        begin
          RankingApps.create(
            :app_id     => app["app_id"],
            :name       => app["name"],
            :genre      => app["genre"],
            :developer  => app["developer"],
            :url        => app["url"],
            :price      => app["price"],
            :thumbnail  => app["thumbnail"],
            :created_at => Time.now
          )
        rescue Sequel::ValidationFailed => e
          return false
	rescue => e
	  p e.backtrace
        end
      end
    end
    return true
  end

  def register_rankings(apps, opt)
    if opt[:date]==nil || opt[:date].empty?
      now = Time.now
      ranking_date = Time.local(now.year, now.month, now.day)
    else
      ranking_date = Time.parse(opt[:date])
    end

    ranking_type = (opt[:ranking_type])?opt[:ranking_type]:0

    if opt[:genre]
      return unless RankingRecords.filter(:date => ranking_date,
                                          :store_type => opt[:store_type],
                                          :ranking_type => ranking_type,
                                          :genre => opt[:genre]).count == 0
    else
      return unless RankingRecords.filter(:date => ranking_date,
                                          :store_type => opt[:store_type],
                                          :ranking_type => ranking_type,
                                          :genre => nil).count == 0
    end

    apps.each do |app|
      next unless app["app_id"]

      begin
        RankingRecords.create(
          :app_id     => app["app_id"],
          :rank       => app["rank"].to_i,
          :rating     => app["rating"],
          :date       => ranking_date,
          :genre      => opt[:genre],
          :store_type => app["store_type"],
          :ranking_type => ranking_type,
          :created_at => Time.now
        )
      rescue Sequel::ValidationFailed
        p "Sequel::ValidationFailed"
        return false
      rescue Sequel::Error
        p "Sequel::Error"
        return false
      rescue => e
      end
    end

    return true
  end

end
