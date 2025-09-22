class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name

      t.timestamps
    end

    # Unique functional index on lower(name) to prevent case-insensitive duplicate user names and speed up searches
    # (e.g., User.where('lower(name) = ?', 'yosef'))
    add_index :users, 'lower(name)', unique: true, name: 'index_users_on_lower_name_unique'
  end
end
