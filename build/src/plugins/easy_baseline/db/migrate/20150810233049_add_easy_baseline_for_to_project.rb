class AddEasyBaselineForToProject < RedmineExtensions::Migration
  def change
    add_reference :projects, :easy_baseline_for, index: true
  end
end
