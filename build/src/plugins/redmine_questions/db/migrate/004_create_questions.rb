class CreateQuestions < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :questions do |t|
      t.string :subject
      t.text :content
      t.references :section, :index => true
      t.references :status, :index => true
      t.references :author, :index => true
      t.boolean :featured, :default => false
      t.boolean :locked, :default => false
      t.integer :cached_weighted_score, :default => 0
      t.integer :comments_count, :default => 0
      t.integer :answers_count, :default => 0
      t.integer :views, :default => 0
      t.integer :total_views, :default => 0
      t.datetime :created_on
      t.datetime :updated_on
    end
  end
end
