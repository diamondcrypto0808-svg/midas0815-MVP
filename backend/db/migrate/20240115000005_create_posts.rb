class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :likes_count, default: 0, null: false
      t.integer :comments_count, default: 0, null: false

      t.timestamps
    end

    add_index :posts, :user_id
    add_index :posts, :created_at
    add_index :posts, [:user_id, :created_at]
    add_index :posts, :likes_count
    add_index :posts, :content, using: :gin, opclass: :gin_trgm_ops
  end
end
