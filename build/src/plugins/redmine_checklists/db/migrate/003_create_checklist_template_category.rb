class CreateChecklistTemplateCategory < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]

  def self.up
    create_table :checklist_template_categories do |t|
      t.string :name
      t.integer :position, :default => 1
    end
  end

  def self.down
    drop_table :checklist_template_categories
  end
end
