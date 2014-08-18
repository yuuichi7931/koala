Sequel.migration do
  up do
    create_table(:apps) do
      primary_key :id
      string :name
      string :app_id
      timestamp :created_at
      index [:name, :app_id]
    end

    create_table(:ranking_apps) do
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

    create_table(:ranking_records) do
      primary_key :id
      int :rank
      int :store_type   # 0 => Apple, 1 => Google play
      int :ranking_type # 0 => free app, 1 => paid app, 2 => top-sales app
      string :app_id
      string :rating
      string :keyword
      string :genre     # genre of App Store
      timestamp :date
      timestamp :created_at
      index [:created_at, :app_id]
    end

    create_table(:reviews) do
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
  end

  down do
    drop_table(:apps)
    drop_table(:ranking_apps)
    drop_table(:ranking_records)
    drop_table(:reviews)
  end
end
