require File.expand_path('../../test_helper', __FILE__)

class QuestionsSectionTest < ActiveSupport::TestCase
  fixtures :questions, :questions_sections

  RedmineQuestions::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_questions).directory + '/test/fixtures/', [:questions, :questions_sections])

  def test_relations
    assert questions_sections(:section_001).questions
  end

  def test_to_s
    assert_equal questions_sections(:section_001).name, questions_sections(:section_001).to_s
  end

  def test_l_type
    assert_equal "Questions", questions_sections(:section_001).l_type
    I18n.locale = "es"
    assert_equal "Questions", questions_sections(:section_001).l_type
  end
end
