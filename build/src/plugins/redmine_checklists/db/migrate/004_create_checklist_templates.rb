class CreateChecklistTemplates < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]

  def self.up
    create_table :checklist_templates do |t|
      t.string :name
      t.references :project
      t.references :category
      t.references :user
      t.boolean :is_public
      t.text :template_items
    end
  end

  def self.down
    drop_table :checklist_templates
  end
end
