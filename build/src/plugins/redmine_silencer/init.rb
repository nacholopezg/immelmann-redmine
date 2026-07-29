require 'redmine'

Redmine::Plugin.register :redmine_silencer do
  name 'Redmine Silencer 2'
  author 'Tobias Fischer'
  description 'A Redmine plugin to suppress email notifications (at will) when updating issues.'
  version '0.4.2-redmine51'
  url 'https://github.com/paginagmbh/redmine_silencer'
  author_url 'https://github.com/tofi86'
  requires_redmine :version_or_higher => '5.1'

  permission :suppress_mail_notifications, {}

  settings :default => {
    'silencer_default' => false
  }, :partial => 'redmine_silencer_settings'
end

Rails.application.config.to_prepare do
  require_dependency 'journal'
  Journal.prepend(RedmineSilencer::JournalPatch) unless Journal.included_modules.include?(RedmineSilencer::JournalPatch)
end

require_dependency 'redmine_silencer/issue_hooks'
require_dependency 'redmine_silencer/view_hooks'
