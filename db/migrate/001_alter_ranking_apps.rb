# usage 
#   up:
#   sequel -m db/migrate sqlite://appdebug.db 
#   down:
#   sequel -m db/migrate -M 0 sqlite://appdebug.db 

Sequel.migration do
  up do
    add_column :ranking_apps, :price, String
    add_column :ranking_records, :ranking_type, Integer
    self[:ranking_records].update(:ranking_type=>0)
  end

  down do
    drop_column :ranking_apps, :price
    drop_column :ranking_records, :ranking_type
  end
end
