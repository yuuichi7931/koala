class RankingRecords < Sequel::Model
  plugin :schema
  plugin :validation_helpers

  unless table_exists?
    set_schema do
      primary_key :id
      int :rank
      int :store_type #0=> Apple, 1=>Google play
      string :app_id
      string :rating
      string :keyword
      string :genre # genre of App Store
      timestamp :date
      timestamp :created_at
      index [:created_at, :app_id]
    end
    create_table
  end

  def validate
    super
    validates_presence [:rank, :app_id]
  end

  def self.dates(genre_id)
    if genre_id
      self.db.fetch("SELECT DISTINCT date FROM ranking_records WHERE genre = ? ORDER BY date DESC", genre_id)
    else
      self.db.fetch("SELECT DISTINCT date FROM ranking_records ORDER BY date DESC")
    end
  end

  def self.news(store_type, start_date, genre_id=nil)
    start_time = Time.parse(start_date)
    end_time = Time.parse(start_date) + 86400
    unless genre_id
      query = 'SELECT  * FROM ranking_records'
      query += ' LEFT JOIN ranking_apps'
      query += ' ON ranking_apps.app_id = ranking_records.app_id'
      query += ' WHERE ( (store_type = ?)'
      query += ' AND (ranking_apps.created_at > ?) AND (ranking_apps.created_at < ?)'
      query += ' AND (date = ?))'
      query += ' ORDER BY rank'
      self.db.fetch(query, store_type, start_time, end_time, start_time)
    else
      query = 'SELECT  * FROM ranking_records'
      query += ' LEFT JOIN ranking_apps'
      query += ' ON ranking_apps.app_id = ranking_records.app_id'
      query += ' WHERE ( (store_type = ?)'
      query += ' AND (ranking_apps.created_at > ?) AND (ranking_apps.created_at < ?)'
      query += ' AND (date = ?) AND genre = ?)'
      query += ' ORDER BY rank'
      self.db.fetch(query, store_type, start_time, end_time, start_time, genre_id)
    end
  end
end
