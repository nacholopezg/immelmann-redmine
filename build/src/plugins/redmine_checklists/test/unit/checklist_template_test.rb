require File.expand_path('../../test_helper', __FILE__)

class ChecklistTemplateTest < ActiveSupport::TestCase

  def test_save_with_category
    ch_temp_cat = ChecklistTemplateCategory.create(:name => 'Category 1', :position => 1)
    check_list_template = ChecklistTemplate.new(:name => 'name', :category_id => ch_temp_cat.id, :template_items => 's')
    check_list_template.save
    assert_equal ch_temp_cat.id, check_list_template.reload.category.id
  end

  def test_checklist_template_items
    checklist_template = ChecklistTemplate.create(name: 'name', template_items: "--New Section\r\nFirst item\r\nSecond item")
    checklists = checklist_template.checklists
    assert_equal checklists.size, 3
    assert_equal checklists.first.subject, 'New Section'
    assert checklists.first.is_section
    assert !checklists.second.is_section
  end
end
