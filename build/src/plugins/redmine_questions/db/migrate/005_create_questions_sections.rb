class CreateQuestionsSections < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :questions_sections do |t|
      t.string :name
      t.text :description
      t.references :project, :index => true
      t.string :section_type
      t.integer :position
    end
    add_index :questions_sections, :position
  end
end
