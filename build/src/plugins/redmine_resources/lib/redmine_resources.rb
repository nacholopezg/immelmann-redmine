require 'redmine_resources/hooks/views_layouts_hook'
require 'redmine_resources/patches/issue_patch'
require 'redmine_resources/patches/query_patch'

require 'redmine_resources/charts/helpers/chart_helper'
require 'redmine_resources/charts/components/base_component'
require 'redmine_resources/charts/components/base_card'
require 'redmine_resources/charts/components/booked_card'
require 'redmine_resources/charts/components/booked_card_progress_bar'
require 'redmine_resources/charts/components/unbooked_card'
require 'redmine_resources/charts/components/workload_card'
require 'redmine_resources/charts/components/plan'
require 'redmine_resources/charts/my_resource_bookings_chart'

module RedmineResources
  include Redmine::I18n

  def self.settings() Setting.plugin_redmine_resources end

  def self.default_workday_length
    (people_plugin_installed? ? Setting.plugin_redmine_people : settings)['workday_length'].to_f
  end

  def self.workday_length
    settings['workday_length'].to_f
  end

  def self.people_plugin_installed?
    @@people_plugin_installed ||= (Redmine::Plugin.installed?(:redmine_people) && Redmine::Plugin.find(:redmine_people).version >= '1.4.0')
  end

  # Return the first day of week
  # 1 = Monday ... 7 = Sunday
  def self.first_wday
    if Setting.start_of_week.blank?
      (l(:general_first_day_of_week).to_i - 1)%7 + 1
    else
      Setting.start_of_week.to_i
    end
  end

  def self.beginning_of_week(user = User.current)
    user.today.beginning_of_week(Date::DAYS_INTO_WEEK.key(first_wday - 1))
  end
end
