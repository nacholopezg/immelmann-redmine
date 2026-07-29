class AddViewingMigration < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def self.up
    unless table_exists?(:viewings)
      ActiveRecord::Base.create_viewings_table
    end
  end

  def self.down
  end
end
