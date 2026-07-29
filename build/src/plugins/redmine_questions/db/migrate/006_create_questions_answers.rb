class CreateQuestionsAnswers < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :questions_answers do |t|
      t.text :content
      t.references :author, :index => true
      t.references :question, :index => true
      t.boolean :accepted, :default => false
      t.integer :cached_weighted_score, :default => 0
      t.integer :comments_count, :default => 0
      t.datetime :created_on
      t.datetime :updated_on
    end

    add_index :questions_answers, :accepted
  end
end
