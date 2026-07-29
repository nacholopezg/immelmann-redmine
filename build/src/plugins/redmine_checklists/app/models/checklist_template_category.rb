class ChecklistTemplateCategory < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes

  attr_protected :id if ActiveRecord::VERSION::MAJOR <= 4
  scope :ordered, lambda { order(:position) }
  safe_attributes 'name', 'position'

  rcrm_acts_as_list

  def to_s
    name
  end
end
