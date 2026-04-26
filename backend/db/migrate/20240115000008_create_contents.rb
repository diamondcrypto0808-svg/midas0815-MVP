class CreateContents < ActiveRecord::Migration[7.1]
  def change
    create_table :contents do |t|
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false, limit: 200
      t.text :body, null: false
      t.integer :status, default: 0, null: false
      t.string :slug, null: false
      t.datetime :published_at

      t.timestamps
    end

    add_index :contents, :slug, unique: true
    add_index :contents, :status
    add_index :contents, :published_at
    add_index :contents, [:status, :published_at]
    add_index :contents, :body, using: :gin, opclass: :gin_trgm_ops
  end
end
