require 'redmine'

Rails.application.config.to_prepare do
  require_dependency 'query_patch4'
end

Redmine::Plugin.register :_query do
  name 'Using OR in query '
  author 'LTT Quan/e_reisinger'
  description 'This plugin allows simple use of OR operator in query and is compatible with Redmine 5.1. It is based on version 0.0.3 of author LTT Quan.'
  version '0.0.5-redmine51'
  requires_redmine :version_or_higher => '5.1'
end
