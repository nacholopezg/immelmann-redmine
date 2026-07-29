# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

module RedmineQuestions
  module TestHelper
    def compatible_request(type, action, parameters = {})
      return send(type, action, parameters) if Redmine::VERSION.to_s < '3.5' && Redmine::VERSION::BRANCH == 'stable'
      send(type, action, :params => parameters)
    end

    def compatible_xhr_request(type, action, parameters = {})
      return xhr type, action, parameters if Redmine::VERSION.to_s < '3.5' && Redmine::VERSION::BRANCH == 'stable'
      send(type, action, :params => parameters, :xhr => true)
    end

    def log_user(login, password)
      User.anonymous
      compatible_request :get, '/logout'
      compatible_request :get, '/login'
      assert_nil session[:user_id]
      assert_response :success
      compatible_request :post, '/login', :username => login, :password => password
      assert_equal login, User.find(session[:user_id]).login
    end    
  end
end

class RedmineQuestions::TestCase
  include ActionDispatch::TestProcess
  def self.plugin_fixtures(plugin, *fixture_names)
    plugin_fixture_path = "#{Redmine::Plugin.find(plugin).directory}/test/fixtures"
    if fixture_names.first == :all
      fixture_names = Dir["#{plugin_fixture_path}/**/*.{yml}"]
      fixture_names.map! { |f| f[(plugin_fixture_path.size + 1)..-5] }
    else
      fixture_names = fixture_names.flatten.map { |n| n.to_s }
    end

    ActiveRecord::Fixtures.create_fixtures(plugin_fixture_path, fixture_names)
  end

  def self.create_fixtures(fixtures_directory, table_names, class_names = {})
    if ActiveRecord::VERSION::MAJOR >= 4
      if Comment.column_names.include?('content')
        table_names.map!{ |x| x.to_s.gsub('comments', 'comments-3.4.6').to_sym }
        ActiveRecord::FixtureSet.create_fixtures(fixtures_directory, table_names, class_names = {})
      else
        ActiveRecord::FixtureSet.create_fixtures(fixtures_directory, table_names, class_names = {})
      end
    else
      ActiveRecord::Fixtures.create_fixtures(fixtures_directory, table_names, class_names = {})
    end
  end

  def self.prepare
    Role.where(:id => 1).each do |r|
      # user_2
      r.permissions << :view_questions
      r.permissions << :global_view_questions
      r.permissions << :add_questions
      r.permissions << :edit_questions
      r.permissions << :add_answers
      r.permissions << :update_questions
      r.permissions << :comment_question
      r.permissions << :vote_questions
      r.permissions << :convert_questions
      r.permissions << :accept_answers
      r.permissions << :global_accept_answer

      r.save
    end

    Role.where(:id => [5]).each do |r|
      # anonymous
      r.permissions << :global_view_questions
      r.save
    end

    # user_3 only developer (role #2) for project #1
    Role.where(:id => 2).each do |r|
      r.permissions << :view_questions
      r.save
    end

    Project.where(:id => [1, 2, 3, 4, 5]).each do |project|
      EnabledModule.create(:project => project, :name => 'questions')
    end
  end
end

include RedmineQuestions::TestHelper
