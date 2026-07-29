class CreateQuestionsStatuses < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :questions_statuses do |t|
      t.string :name
      t.boolean :is_closed, :default => false
      t.string :color
      t.integer :position
    end

    add_index :questions_statuses, :is_closed
    add_index :questions_statuses, :position
  end
end
