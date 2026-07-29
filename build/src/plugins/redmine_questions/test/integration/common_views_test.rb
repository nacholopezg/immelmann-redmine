require File.expand_path('../../test_helper', __FILE__)
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

class RedmineQuestions::CommonViewsTest < ActionDispatch::IntegrationTest
  fixtures :users, 
           :projects,
           :roles,
           :members,
           :member_roles,
           :trackers,
           :enumerations,
           :projects_trackers,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :workflows,
           :questions,
           :questions_answers,
           :questions_sections

  fixtures :email_addresses if ActiveRecord::VERSION::MAJOR >= 4

  RedmineQuestions::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_questions).directory + '/test/fixtures/', [:questions, :questions_answers, :questions_sections])

  def setup
    @project_1 = Project.find(1)
    EnabledModule.create(:project => @project_1, :name => 'questions')
  end

  def test_view_activity_with_questions
    log_user('admin', 'admin')
    compatible_request :get, '/activity', :show_questions => 1
    assert_response :success
  end

  def test_global_search_with_questions
    log_user('admin', 'admin')
    get '/search?q=simple&questions=1'
    assert_response :success
  end
end
