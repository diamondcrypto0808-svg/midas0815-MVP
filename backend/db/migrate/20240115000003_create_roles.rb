class CreateRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :roles, :name, unique: true

    # Join table for users and roles
    create_table :roles_users, id: false do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
    end

    add_index :roles_users, [:user_id, :role_id], unique: true
  end
end
