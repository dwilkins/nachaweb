class CreateAchFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :ach_files do |t|
      t.references :user, null: false, foreign_key: true
      t.uuid :uuid, default: 'gen_random_uuid()', null: false
      t.string :filename
      t.integer :status, default: 0, null: false
      t.integer :storage_type, default: 0, null: false
      t.jsonb :parsed_data
      t.text :error_message

      t.timestamps
    end
    add_index :ach_files, :uuid, unique: true
  end
end
