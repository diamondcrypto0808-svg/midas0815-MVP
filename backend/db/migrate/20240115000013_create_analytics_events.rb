class CreateAnalyticsEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :analytics_events do |t|
      t.references :user, foreign_key: true
      t.string :event_type, null: false
      t.string :event_category, null: false
      t.jsonb :properties, default: {}

      t.timestamps
    end

    add_index :analytics_events, :user_id
    add_index :analytics_events, :event_type
    add_index :analytics_events, :created_at
    add_index :analytics_events, [:event_type, :created_at]
    add_index :analytics_events, :event_category
  end
end
