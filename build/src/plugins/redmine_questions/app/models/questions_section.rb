class QuestionsSection < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes

  belongs_to :project
  has_many :questions, :foreign_key => "section_id", :dependent => :destroy

  attr_protected :id if ActiveRecord::VERSION::MAJOR <= 4
  safe_attributes 'name', 'project', 'position', 'description', 'section_type'

  scope :with_questions_count, lambda { select("#{QuestionsSection.table_name}.*, count(#{QuestionsSection.table_name}.id) as questions_count").joins(:questions).order("project_id ASC").group("#{QuestionsSection.table_name}.id, #{QuestionsSection.table_name}.name, #{QuestionsSection.table_name}.project_id, #{QuestionsSection.table_name}.section_type") }
  scope :for_project, lambda { |project| where(:project_id => project) unless project.blank? }
  scope :visible, lambda {|*args|
    joins(:project).
    where(Project.allowed_to_condition(args.shift || User.current, :view_questions, *args))
  }
  scope :sorted, lambda { order(:position) }

  rcrm_acts_as_list :scope => 'project_id = #{project_id}'
  acts_as_watchable

  SECTION_TYPE_QUESTIONS = 'questions'
  # <PRO>
  SECTION_TYPE_SOLUTIONS = 'solutions'
  SECTION_TYPE_IDEAS = 'ideas'

  TYPES =[
    SECTION_TYPE_QUESTIONS,
    SECTION_TYPE_SOLUTIONS,
    SECTION_TYPE_IDEAS
  ]
  # </PRO>

  validates_presence_of :section_type, :project_id, :name
  validates_uniqueness_of :name, :scope => :project_id

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      self.section_type ||= SECTION_TYPE_QUESTIONS
    end
  end

  def to_param
    "#{id}-#{ActiveSupport::Inflector.transliterate(name).parameterize}"
  end

  def is_questions?
    # <PRO>
    section_type == SECTION_TYPE_QUESTIONS
    # </PRO>
    # <LIGHT/> true
  end

  def is_solutions?
    # <PRO>
    section_type == SECTION_TYPE_SOLUTIONS
    # </PRO>
    # <LIGHT/> false
  end

  def is_ideas?
    # <PRO>
    section_type == SECTION_TYPE_IDEAS
    # </PRO>
    # <LIGHT/> false
  end

  def allow_voting?
    # <PRO>
    !is_solutions?
    # </PRO>
    # <LIGHT/> false
  end

  def allow_liking?
    # <PRO>
    is_solutions?
    # </PRO>
    # <LIGHT/> false
  end

  def allow_answering?
    is_questions?
  end

  def self.types_list
    # <PRO>
    TYPES.map { |type| [I18n.t("label_questions_section_type_#{type}"), type] }
    # </PRO>
  end

  def l_type
    I18n.t("label_questions_section_type_#{section_type}") if section_type
  end

  def to_s
    name
  end
end
