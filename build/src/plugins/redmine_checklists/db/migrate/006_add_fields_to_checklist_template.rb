class AddFieldsToChecklistTemplate < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def self.up
    add_column :checklist_templates, :is_default, :boolean, :default => false
    add_column :checklist_templates, :tracker_id, :integer
    add_index :checklist_templates, :tracker_id
  end

  def self.down
    remove_column :checklist_templates, :is_default
    remove_column :checklist_templates, :tracker_id
  end
end
