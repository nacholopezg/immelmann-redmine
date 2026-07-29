require File.expand_path('../../test_helper', __FILE__)
class ChecklistsControllerTest < ActionController::TestCase
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
    Project.find(1).enable_module!(:checklists)
    User.current = nil
    @project_1 = Project.find(1)
    @issue_1 = Issue.find(1)
    @checklist_1 = Checklist.find(1)
  end

  test "should post done" do
    # log_user('admin', 'admin')
    @request.session[:user_id] = 1

    compatible_xhr_request :put, :done, :is_done => 'true', :id => '1'
    assert_response :success, 'Post done not working'
    assert_equal true, Checklist.find(1).is_done, 'Post done not working'
  end

  # <PRO>
  test 'sends email about checklists' do
    @request.session[:user_id] = 1
    Setting[:plugin_redmine_checklists] = { :save_log => 1, :issue_done_ratio => 0 }
    EmailAddress.create!(:user_id => 2, :address =>  'test@example.com') if Redmine::VERSION.to_s >= '3.0'
    compatible_xhr_request :put, :done, :is_done => 'true', :id => '1'
    assert ActionMailer::Base.deliveries.last
    email = ActionMailer::Base.deliveries.last
    assert_include 'Checklist item [x] First todo set to Done', email.text_part.body.to_s
    # Test changes fixup
    compatible_xhr_request :put, :done, :is_done => 'false', :id => '2'
    email = ActionMailer::Base.deliveries.last
    assert_include 'Checklist item [x] First todo set to Done', email.text_part.body.to_s
  end
  # </PRO>

  test "should not post done by deny user" do
    # log_user('admin', 'admin')
    @request.session[:user_id] = 5

    compatible_xhr_request :put, :done, :is_done => true, :id => "1"
    assert_response 403, "Post done accessible for all"
  end

  test "should view issue with checklist" do
    # log_user('admin', 'admin')
    @request.session[:user_id] = 1
    @controller = IssuesController.new
    compatible_request :get, :show, :id => @issue_1.id
    assert_select 'ul#checklist_items li#checklist_item_1', @checklist_1.subject, "Issue won't view for admin"
  end

  test "should not view issue with checklist if deny" do
    # log_user('anonymous', '')
    @request.session[:user_id] = 5
    @controller = IssuesController.new
    compatible_request :get, :show, :id => @issue_1.id
    assert_select 'ul#checklist_items', false, "Issue view for anonymous"
  end
end
