class ResourceBookingQuery < Query
  self.queried_class = ResourceBooking
  self.view_permission = :view_resources if Redmine::VERSION.to_s >= '3.4'

  def initialize(attributes = nil, *args)
    super attributes
    self.filters ||= {}
  end

  def initialize_available_filters
    add_available_filter 'assigned_to_id', type: :list_optional, values: assigned_to_values
    if project.nil?
      add_available_filter 'project_id', type: :list_optional, values: all_projects_values
    end
    add_available_filter 'issue_id', type: :integer
  end

  def base_scope
    ResourceBooking.joins(:assigned_to, :project).includes(:issue).where(statement)
  end

  def resource_bookings_between(from, to)
    base_scope.between(from, to)
  end

  def resource_bookings_by_users(from, to)
    ResourceBooking.where(values_for(:assigned_to_id)).between(from, to)
  end

  def show_issues; options[:show_issues] end
  def show_issues=(arg); set_boolean_option(:show_issues, arg) end

  def show_versions; options[:show_versions] end
  def show_versions=(arg); set_boolean_option(:show_versions, arg) end

  def line_title_type; options[:line_title_type] end

  def line_title_type=(arg)
    if ResourceBookingChart::LINE_TITLE_TYPES.include?(arg)
      options[:line_title_type] = arg
    else
      raise ArgumentError.new("value must be one of: #{ResourceBookingChart::LINE_TITLE_TYPES.join(', ')}")
    end
  end

  def date_from; options[:date_from] end
  def date_from=(arg); options[:date_from] = arg.to_date end

  def build_from_params(params)
    super
    self.show_issues = params[:show_issues] || (params[:query] && params[:query][:show_issues]) || true
    self.show_versions = params[:show_versions] || (params[:query] && params[:query][:show_versions]) || true
    self.line_title_type = params[:line_title_type] || (params[:query] && params[:query][:line_title_type]) || ResourceBookingChart::ISSUE_SUBJECT
    self.date_from = params[:date_from].presence || (params[:query] && params[:query][:date_from].presence) || RedmineResources.beginning_of_week
    self
  end

  private

  def set_boolean_option(name, value)
    options[name] = value == '1' || value == true
  end
end
