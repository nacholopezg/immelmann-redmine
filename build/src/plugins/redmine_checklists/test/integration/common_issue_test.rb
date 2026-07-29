require File.expand_path('../../test_helper', __FILE__)
class CommonIssueTest < RedmineChecklists::IntegrationTest
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries
  RedmineChecklists::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_checklists).directory + '/test/fixtures/', [:checklists])

  def setup
    RedmineChecklists::TestCase.prepare
    Setting.default_language = 'en'
    @project_1   = Project.find(1)
    @issue_1     = Issue.find(1)
    @checklist_1 = Checklist.find(1)
  end

  # <PRO>
  def test_checklist_settings
    log_user('admin', 'admin')
    ChecklistTemplate.create!(:name => 'template1', :template_items => 'item1 item2', :is_public => true, :project => @project_1)
    ChecklistTemplate.create!(:name => 'template2', :template_items => 'item1 item2', :is_public => true)
    compatible_request :get, '/settings/plugin/redmine_checklists'
    assert_response :success
    assert_select 'tr.checklist-template', 2
  end

  def test_checklist_project_settings
    log_user('admin', 'admin')
    ChecklistTemplate.create!(:name => 'template1', :template_items => 'item1 item2', :is_public => true, :project => @project_1)
    ChecklistTemplate.create!(:name => 'template2', :template_items => 'item1 item2', :is_public => true)
    compatible_request :get, '/projects/ecookbook/settings/checklist_template'
    assert_response :success
    assert_select 'tr.checklist-template', 2
  end
  # </PRO>

  def test_global_search_with_checklist
    log_user('admin', 'admin')
    compatible_request :get, '/search?q=First'
    assert_response :success
  end
end
