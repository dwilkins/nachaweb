class CreateAchInputFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :ach_input_files do |t|
      t.references :ach_file, null: false, foreign_key: true
      t.string :name
      t.integer :format
      t.integer :modality
      t.text :source

      t.timestamps
    end
  end
end
