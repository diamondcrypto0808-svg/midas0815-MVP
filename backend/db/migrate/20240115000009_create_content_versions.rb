class CreateContentVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :content_versions do |t|
      t.references :content, null: false, foreign_key: true
      t.integer :version_number, null: false
      t.text :body, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :content_versions, [:content_id, :version_number], unique: true
  end
end
