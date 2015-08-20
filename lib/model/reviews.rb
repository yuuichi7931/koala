class Reviews < Sequel::Model
  plugin :schema
  unless table_exists?
    set_schema do
      primary_key :id
      string :hash
      string :user
      string :date
      string :title
      string :body
      string :version
      string :device
      string :app_id
      string :nodes
      int :star
      timestamp :created_at
      index [:hash, :app_id, :version]
    end
    create_table
  end

  def self.versions(app_id)
    versions = db.fetch("SELECT DISTINCT version FROM reviews WHERE app_id = ?", app_id)
    return versions.sort_by{|val| -val[:version].to_f}
  end

  def self.find_stars(app_id, version)
    if version==nil || version=='ALL'
      return select(:star).filter(:app_id => app_id)
    end

    return select(:star).filter(:app_id => app_id, :version => version)
  end

  def self.find_by_version(app_id, version, limit, offset)
    if version==nil || version=='ALL'
      return db.fetch("SELECT * FROM reviews WHERE app_id = ? ORDER BY date LIMIT ? OFFSET ?", app_id.to_s, limit, offset)
    end

    return db.fetch("SELECT * FROM reviews WHERE app_id = ? AND version = ? ORDER BY date LIMIT ? OFFSET ?", app_id, version, limit, offset)
  end

  def self.count_by_version(app_id, version)
    count_query = Sequel::SQL::Function.new(:count, Sequel::Dataset::WILDCARD).as(:count_value)

    unless version || version=='ALL'
      return self.select(count_query).where(:app_id => app_id).first[:count_value]
    end
    return self.select(count_query).where(:app_id => app_id, :version => version).first[:count_value]
  end
end
