ActionDispatch::Callbacks.to_param do
  require 'query_patch4'
end

Redmine::Plugin.register :_query do
  name 'Using OR in query '
  author 'LTT Quan/e_reisinger'
  description 'This plugin allows simple use of OR operator in query and is compatible with Redmine 4.x. It\'s based on version 0.0.3 of author LTT Quan.'
  version '0.0.5'
  requires_redmine :version_or_higher => '4'
end

