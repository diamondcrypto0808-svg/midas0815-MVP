class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :display_name, limit: 50
      t.text :bio, limit: 500
      t.string :avatar_url
      t.jsonb :interests, default: []
      t.jsonb :skills, default: []
      t.jsonb :preferences, default: {}

      t.timestamps
    end

    add_index :profiles, :interests, using: :gin
    add_index :profiles, :skills, using: :gin
  end
end
