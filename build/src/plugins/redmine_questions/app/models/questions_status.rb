class QuestionsStatus < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes

  belongs_to :question

  attr_protected :id if ActiveRecord::VERSION::MAJOR <= 4
  safe_attributes 'name', 'is_closed', 'position', 'color'

  validates :name, presence: true, uniqueness: true

  scope :sorted, lambda { order(:position) }

  rcrm_acts_as_list

  def to_s
    name
  end
end
