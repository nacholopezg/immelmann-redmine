class AddIsSectionToChecklists < (Rails.version < '5.1') ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    add_column :checklists, :is_section, :boolean, default: false
  end
end
