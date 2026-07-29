require File.expand_path('../../test_helper', __FILE__)

class QuestionsVotesControllerTest < ActionController::TestCase
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
    RedmineQuestions::TestCase.prepare
    @controller = QuestionsVotesController.new
    @project = projects(:projects_001)
    @comment = Comment.new(:comments => 'Text', :author => users(:users_001))
    questions(:question_001).comments << @comment
    User.current = nil
  end

  def test_question_upvote
    @request.session[:user_id] = 2
    assert_difference 'RedmineCrm::ActsAsVotable::Vote.count', 1 do
      compatible_request :post, :create, :source_type => 'question', :source_id => questions(:question_001), :up => 'true'
    end
    assert_redirected_to :controller => 'questions', :action => 'show', :id => questions(:question_001), :anchor => ''
  end

  def test_answer_upvote
    @request.session[:user_id] = 1
    assert_difference 'RedmineCrm::ActsAsVotable::Vote.count', 1 do
      compatible_request :post, :create, :source_type => 'questions_answer', :source_id => questions_answers(:answer_001), :up => 'true'
    end
    assert_redirected_to :controller => 'questions', :action => 'show', :id => questions(:question_001), :anchor => 'question_item_1'
  end

  def test_answer_upvote_xhr
    @request.session[:user_id] = 1
    assert_difference 'RedmineCrm::ActsAsVotable::Vote.count', 1 do
      compatible_xhr_request :post, :create, :source_type => 'questions_answer', :source_id => questions_answers(:answer_001), :up => 'true'
    end
  end

  def test_own_vote_with_permission
    @request.session[:user_id] = 2
    with_settings :plugin_redmine_questions => { 'vote_own' => 1 } do
      assert_difference 'RedmineCrm::ActsAsVotable::Vote.count', 1 do
        compatible_request :post, :create, :source_type => 'question', :source_id => questions(:question_001), :up => 'true'
      end
    end
    assert_redirected_to :controller => 'questions', :action => 'show', :id => questions(:question_001), :anchor => ''
  end

  def test_own_vote_without_permission
    @request.session[:user_id] = 1
    assert_no_difference 'RedmineCrm::ActsAsVotable::Vote.count' do
      compatible_request :post, :create, :source_type => 'question', :source_id => questions(:question_001), :up => 'true'
    end
    assert_response 403
  end
end
