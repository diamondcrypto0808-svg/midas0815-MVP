class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :notification_type, null: false
      t.string :title, null: false
      t.text :message
      t.jsonb :data, default: {}
      t.boolean :read, default: false, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, :user_id
    add_index :notifications, [:user_id, :read]
    add_index :notifications, :created_at
    add_index :notifications, :notification_type
  end
end
