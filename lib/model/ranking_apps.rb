class RankingApps < Sequel::Model
  plugin :schema
  plugin :validation_helpers

  unless table_exists?
    set_schema do
      primary_key :id
      string :app_id
      string :name
      string :url
      string :price
      string :developer
      string :thumbnail
      string :genre
      timestamp :created_at
      index :app_id
      index :genre
      index :developer
    end
    create_table
  end

  def validate
    super
    validates_presence [:app_id, :name]
  end

  def self.no_genres
    query = 'SELECT  DISTINCT(ranking_apps.app_id) FROM ranking_apps'
    query += ' LEFT JOIN ranking_records'
    query += ' ON ranking_apps.app_id = ranking_records.app_id'
    query += ' WHERE ( (store_type = 1) AND (ranking_apps.genre IS NULL))'
    self.db.fetch(query)
  end
end
