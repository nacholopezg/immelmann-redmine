require File.expand_path('../../test_helper', __FILE__)

class ProjectTest < ActiveSupport::TestCase
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

  RedmineChecklists::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_checklists).directory + '/test/fixtures/',
                                         [:checklists])
  def setup
    RedmineChecklists::TestCase.prepare
    Setting.default_language = 'en'
    @project_1 = Project.find(1)
    @issue_1 = Issue.create(:project => @project_1, :tracker_id => 1, :author_id => 1,
                            :status_id => 1, :priority => IssuePriority.first,
                            :subject => 'TestIssue')
    @checklist_1 = Checklist.create(:subject => 'TEST1', :position => 1, :issue => @issue_1)
    @checklist_1 = Checklist.create(:subject => 'TEST2', :position => 2, :issue => @issue_1, :is_done => true)
  end

  test 'should copy checklists' do
    project_copy = Project.copy_from(Project.find(1))
    project_copy.name = 'Test name'
    project_copy.identifier = Project.next_identifier
    project_copy.copy(Project.find(1))

    checklists_copies = project_copy.issues.where(:subject => 'TestIssue').first.checklists
    assert_equal(checklists_copies.count, 2)
    assert_equal(checklists_copies.where(:subject => 'TEST1').first.is_done, false)
    assert_equal(checklists_copies.where(:subject => 'TEST2').first.is_done, true)
  end
end
