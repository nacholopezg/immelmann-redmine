Rails.configuration.to_prepare do
  require 'redmine_checklists/patches/compatibility/application_helper_patch'

  require 'redmine_checklists/hooks/views_issues_hook'
  require 'redmine_checklists/hooks/views_layouts_hook'
  require 'redmine_checklists/hooks/controller_issues_hook'

  require 'redmine_checklists/patches/issue_patch'
  require 'redmine_checklists/patches/project_patch'
  require 'redmine_checklists/patches/issues_controller_patch'
  require 'redmine_checklists/patches/add_helpers_for_checklists_patch'
  require 'redmine_checklists/patches/compatibility_patch'
  # <PRO>
  require 'redmine_checklists/patches/projects_helper_patch'
  require 'redmine_checklists/patches/notifiable_patch'
  require 'redmine_checklists/patches/issue_query_patch'
  # </PRO>
  require 'redmine_checklists/patches/issues_helper_patch'
  require 'redmine_checklists/patches/compatibility/open_struct_patch'
  require 'redmine_checklists/patches/compatibility/journal_patch'
end

module RedmineChecklists
  def self.settings() Setting.plugin_redmine_checklists.blank? ? {} : Setting.plugin_redmine_checklists end

  def self.block_issue_closing?
    settings['block_issue_closing'].to_i > 0
  end

  def self.issue_done_ratio?
    settings['issue_done_ratio'].to_i > 0
  end
end
