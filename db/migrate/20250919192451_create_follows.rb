class CreateFollows < ActiveRecord::Migration[8.1]
  def change
    create_table :follows do |t|
      t.bigint :follower_id
      t.bigint :followed_id

      t.timestamps
    end

    # Unique composite index on follower_id and followed_id to prevent duplicate follows and speed up uniqueness checks
    # (e.g., Follow.where(follower_id: user.id, followed_id: other_user.id))
    add_index :follows, [:follower_id, :followed_id], unique: true, name: 'index_follows_on_follower_followed'
    # Index on followed_id for fast queries on who is following a user
    # (e.g., Follow.where(followed_id: user.id))
    add_index :follows, :followed_id, name: 'index_follows_on_followed_id'
    # Index on follower_id for fast queries on who a user is following
    # (e.g., Follow.where(follower_id: user.id))
    add_index :follows, :follower_id, name: 'index_follows_on_follower_id'
  end
end
