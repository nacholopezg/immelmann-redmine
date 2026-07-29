require_dependency "issue_view_columns/project_helper_patch"

Redmine::Plugin.register :redmine_issue_view_columns do
  name "Redmine Issue View Columns"
  author "Kenan Dervišević"
  description "Customize shown columns in subtasks and related issues on issue page"
  version "1.0.1-redmine51"
  url "https://github.com/kenan3008/redmine_issue_view_columns"

  project_module :issue_view_columns do
    permission :manage_issue_view_columns, { issue_view_columns: :index }, { require: :member }
  end
  settings default: { "empty": true }, partial: "settings/issue_view_columns_settings"
end

Rails.application.config.to_prepare do
  require_dependency 'projects_controller'
  ProjectsController.helper(IssueViewColumnsHelper) unless ProjectsController.included_modules.include?(IssueViewColumnsHelper)

  require_dependency 'issues_controller'
  IssuesController.helper(IssueViewColumnsIssuesHelper) unless IssuesController.included_modules.include?(IssueViewColumnsIssuesHelper)
end
