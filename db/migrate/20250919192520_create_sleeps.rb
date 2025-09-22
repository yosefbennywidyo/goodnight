class CreateSleeps < ActiveRecord::Migration[8.1]
  def change
    create_table :sleeps do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :clock_in
      t.datetime :clock_out
      t.integer :duration

      t.timestamps
    end

    # Index on clock_in for sorting/filtering by bed time
    # (e.g., Sleep.order(:clock_in))
    add_index :sleeps, :clock_in, name: 'index_sleeps_on_clock_in'
    # Index on clock_out for filtering by wake time
    # (e.g., Sleep.where.not(clock_out: nil))
    add_index :sleeps, :clock_out, name: 'index_sleeps_on_clock_out'
    # Index on created_at for ordering clock-ins by creation time
    # (e.g., Sleep.order(:created_at))
    add_index :sleeps, :created_at, name: 'index_sleeps_on_created_at'
    # Index on duration for general sorting (complements the partial index)
    # (e.g., Sleep.order(:duration))
    add_index :sleeps, :duration, name: 'index_sleeps_on_duration'
    # Partial unique index on user_id for open sleeps (no clock_out) to ensure one active sleep per user
    # (e.g., Sleep.where(user_id: user.id, clock_out: nil))
    add_index :sleeps, :user_id, unique: true, where: 'clock_out IS NULL', name: 'index_sleeps_on_user_id_clock_out_null'
    # Partial index on duration (descending) for completed sleeps to speed up sorting by duration
    # (e.g., Sleep.where.not(clock_out: nil).order(duration: :desc))
    add_index :sleeps, :duration, order: { duration: :desc }, where: 'clock_out IS NOT NULL', name: 'index_sleeps_on_duration_partial'

    # Composite index on user_id, created_at, and duration for filtering friends' sleeps by week and sorting by duration
    # (e.g., current_user.following.joins(:sleeps).where('sleeps.created_at >= ?', 1.week.ago).order('sleeps.duration DESC'))
    add_index :sleeps, [:user_id, :created_at, :duration], name: 'index_sleeps_on_user_id_created_at_duration'
    # Composite index on user_id, clock_in, and duration for queries filtering by user and time, then sorting by duration
    # (e.g., Sleep.where(user_id: user.id).where('clock_in >= ?', 1.week.ago).order(:duration))
    add_index :sleeps, [:user_id, :clock_in, :duration], name: 'index_sleeps_on_user_id_clock_in_duration'
    # Composite index on user_id and created_at for filtering user's sleeps by week
    # (e.g., Sleep.where(user_id: user.id).where('created_at >= ?', 1.week.ago))
    add_index :sleeps, [:user_id, :created_at], name: 'index_sleeps_on_user_id_created_at'
  end
end
