class CreateMatchRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :match_requests do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false
      t.text :message

      t.timestamps
    end

    add_index :match_requests, :sender_id
    add_index :match_requests, :receiver_id
    add_index :match_requests, :status
    add_index :match_requests, [:sender_id, :receiver_id, :status]
  end
end
