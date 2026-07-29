class ModifyChecklistSubjectLength < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def self.up
    change_column :checklists, :subject, :string, :limit => 512
  end

  def self.down
    change_column :checklists, :subject, :string, :limit => 256
  end
end
