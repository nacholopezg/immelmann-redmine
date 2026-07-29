require 'redmine'
require 'redmine_checklists/redmine_checklists'

CHECKLISTS_VERSION_NUMBER = '3.1.16'.freeze
# <PRO>
CHECKLISTS_VERSION_TYPE = 'PRO version'.freeze
# </PRO>
# <LIGHT/> CHECKLISTS_VERSION_TYPE = "Light version"

Redmine::Plugin.register :redmine_checklists do
  name "Redmine Checklists plugin (#{CHECKLISTS_VERSION_TYPE})"
  author 'RedmineUP'
  description 'This is a issue checklist plugin for Redmine'
  version CHECKLISTS_VERSION_NUMBER
  url 'https://www.redmineup.com/pages/plugins/checklists'
  author_url 'mailto:support@redmineup.com'

  requires_redmine :version_or_higher => '2.3'

  settings :default => {
    :save_log => true,
    :issue_done_ratio => false
  }, :partial => 'settings/checklists/checklists'

  Redmine::AccessControl.map do |map|
    map.project_module :issue_tracking do |map|
      map.permission :view_checklists, { :checklists => [:show, :index] }
      map.permission :done_checklists, { :checklists => :done }
      map.permission :edit_checklists, { :checklists => [:done, :create, :destroy, :update] }
      # <PRO>
      map.permission :manage_checklist_templates, { :checklist_templates => [:new, :create, :destroy, :edit, :update] }
      # </PRO>
    end
  end

  Redmine::Search.map do |search|
    # search.register :checklists
  end
end
