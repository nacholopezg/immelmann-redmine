requires_redmine_crm version_or_higher: '0.0.42' rescue raise "\n\033[31mRedmine requires newer redmine_crm gem version.\nPlease update with 'bundle update redmine_crm'.\033[0m"
require 'redmine_resources'

Redmine::Plugin.register :redmine_resources do
  name 'Redmine Resources plugin (PRO version)'
  author 'RedmineUP'
  description 'Resource allocation and management for Redmine'
  version '1.0.1'
  url 'http://redmineup.com/pages/plugins/resources'
  author_url 'mailto:support@redmineup.com'

  requires_redmine :version_or_higher => '2.6'

  settings default: { 'workday_length' => 8 }, partial: 'settings/resource_bookings/index'

  project_module :resources do
    permission :view_resources, { resource_bookings: [:index] }
    permission :add_booking, { resource_bookings: [:new, :create] }
    permission :edit_booking, { resource_bookings: [:edit, :update, :destroy, :split] }
  end

  menu :top_menu, :resources,
       { controller: 'resource_bookings', action: 'index', project_id: nil }, caption: :label_resources,
       if: Proc.new { User.current.allowed_to?(:view_resources, nil, global: true) }

  menu :application_menu, :resources,
       { controller: 'resource_bookings', action: 'index' }, caption: :label_resources, after: :gantt,
       if: Proc.new { User.current.allowed_to?(:view_resources, nil, global: true) }

  menu :project_menu, :resources,
       { controller: 'resource_bookings', action: 'index' }, caption: :label_resources, after: :gantt, param: :project_id

  activity_provider :resource_bookings, default: false, class_name: 'ResourceBooking'
end
