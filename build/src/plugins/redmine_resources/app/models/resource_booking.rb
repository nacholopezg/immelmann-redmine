class ResourceBooking < ActiveRecord::Base
  include Redmine::SafeAttributes
  include Redmine::Utils::DateCalculation

  belongs_to :project
  belongs_to :assigned_to, class_name: 'User'
  belongs_to :issue
  belongs_to :author, class_name: 'User'

  acts_as_event(
    title: Proc.new { |o| o.event_title },
    datetime: :created_at,
    project_key: "#{Project.table_name}.id",
    url: Proc.new { |o| o.url_options },
    author: Proc.new { |o|  o.author },
    description: Proc.new { |o| o.event_description }
  )

  if ActiveRecord::VERSION::MAJOR >= 4
    acts_as_activity_provider(
      type: 'resource_bookings',
      permission: :view_resources,
      timestamp: "#{table_name}.created_at",
      author_key: "#{table_name}.author_id",
      scope: eager_load(:project, :assigned_to, :issue, :author)
    )
  else
    acts_as_activity_provider(
      type: 'resource_bookings',
      permission: :view_resources,
      timestamp: "#{table_name}.created_at",
      author_key: "#{table_name}.author_id",
      find_options: { include: [:project, :assigned_to, :issue, :author] }
    )
  end

  attr_protected :id if ActiveRecord::VERSION::MAJOR <= 4
  safe_attributes 'project_id', 'assigned_to_id', 'issue_id', 'start_date', 'end_date', 'hours_per_day', 'notes'

  validates :project_id, :assigned_to_id, :start_date, :hours_per_day, presence: true
  validates :hours_per_day, numericality: { allow_nil: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 24 }
  validate :check_interval
  validate :check_issue_params

  after_create :send_create_notification, on: :create
  after_update :send_update_notification, on: :update

  scope :between, lambda { |from, to|
    condition_sql = <<-SQL.squish
      #{table_name}.start_date >= :from AND #{table_name}.start_date <= :to OR
      :from >= #{table_name}.start_date AND :from <= #{table_name}.end_date
    SQL
    where(condition_sql, from: from.to_datetime, to: to.to_datetime)
  }

  def self.allowed_projects
    Project.active
  end

  def get_end_date
    end_date || start_date
  end

  def can_add_to?(resource_bookings)
    resource_bookings.all? { |rb| !self.interval.overlaps?(rb.interval) }
  end

  def interval
    (start_date.to_date..get_end_date.to_date)
  end

  def working_days_amount
    interval.sum { |date| non_working_week_days.include?(date.cwday) ? 0 : 1 }
  end

  def total_days
    (get_end_date.to_date - start_date.to_date).to_i + 1
  end

  def total_hours
    working_days_amount * hours_per_day
  end

  def notified_users
    [author, assigned_to].uniq
  end

  def recipients
    notified_users.map(&:mail)
  end

  def email_users
    Redmine::VERSION.to_s < '4.0' ? recipients : notified_users
  end

  def event_title
    related   = issue if issue && issue.visible?
    related ||= project
    "#{l_hours(total_hours)} (#{related.event_title})"
  end

  def event_description
    "#{l(:label_resource_booking_added)} - #{l(:label_resources_assigned_to_user)}: #{assigned_to}"
  end

  def url_options
    options = {
      controller: 'resource_bookings',
      action: 'index',
      set_filter: 1,
      f: [:project_id, :assigned_to_id, :issue_id],
      op: { project_id: '=', assigned_to_id: '=' },
      v: { project_id: [project_id], assigned_to_id: [assigned_to_id] },
      months: distance_in_months,
      date_from: start_date.to_date
    }

    if issue_id
      options[:op][:issue_id] = '='
      options[:v][:issue_id] = [issue_id]
    else
      options[:op][:issue_id] = '!*'
    end

    options
  end

  def distance_in_months
    distance_in_days = get_end_date - start_date
    distance_in_days > 0 ? (distance_in_days / 1.month).ceil : 1
  end

  private

  def check_interval
    if start_date && end_date && end_date < start_date
      errors.add(:end_date, :greater_than_or_equal_to_start_date)
    end
  end

  def check_issue_params
    if issue.try(:due_date) && issue.due_date < get_end_date.to_date
      errors.add(:end_date, :less_than_or_equal_to_issue_due_date, due_date: format_date(issue.due_date))
    end

    if start_date && issue.try(:estimated_hours) && issue.estimated_hours < issue_assignments_total_time
      errors.add(:base, :total_time_exceeds_estimated_time)
    end
  end

  def issue_assignments_total_time
    self.class.where(issue_id: issue.id).where('id != ?', id).to_a.sum(&:total_hours) + total_hours
  end

  def send_create_notification
    ResourceBookingsMailer.deliver_resource_booking_create(self)
  end

  def send_update_notification
    ResourceBookingsMailer.deliver_resource_booking_update(self)
  end
end
