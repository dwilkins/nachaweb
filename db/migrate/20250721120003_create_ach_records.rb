class CreateAchRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :ach_records do |t|
      t.references :ach_file, null: false, foreign_key: true
      t.string :ach_record_name
      t.jsonb :parsed_data

      t.timestamps
    end
  end
end