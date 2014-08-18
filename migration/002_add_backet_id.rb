Sequel.migration do
  up do
    alter_table(:apps) do
      add_column :bucket_id, String
    end
  end

  down do
    alter_table(:apps) do
      drop_column :bucket_id
    end
  end
end
