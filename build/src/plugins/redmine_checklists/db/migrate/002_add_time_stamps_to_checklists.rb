class AddTimeStampsToChecklists < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    add_column :checklists, :created_at, :timestamp
    add_column :checklists, :updated_at, :timestamp
  end
end
