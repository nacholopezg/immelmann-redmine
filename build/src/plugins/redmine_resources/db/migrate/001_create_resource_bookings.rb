class CreateResourceBookings < (Rails.version < '5.1') ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :resource_bookings do |t|
      t.references :project, index: true, foreign_key: true, null: false
      t.integer :assigned_to_id, index: true, null: false
      t.references :issue, index: true, foreign_key: true
      t.integer :author_id, index: true, null: false

      t.datetime :start_date, null: false
      t.datetime :end_date

      t.float :hours_per_day, null: false
      t.text :notes
      t.timestamps null: false
    end

    if Rails.version < '4.2'
      add_index :resource_bookings, :project_id
      add_index :resource_bookings, :assigned_to_id
      add_index :resource_bookings, :issue_id
      add_index :resource_bookings, :author_id
    else
      add_foreign_key :resource_bookings, :users, column: :assigned_to_id
      add_foreign_key :resource_bookings, :users, column: :author_id
    end
  end
end
