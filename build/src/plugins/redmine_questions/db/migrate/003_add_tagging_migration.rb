class AddTaggingMigration < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def up
    ActiveRecord::Base.create_taggable_table
  end

  def down
  end
end
