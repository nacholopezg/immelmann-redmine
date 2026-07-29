require 'redmine'

Redmine::Plugin.register :redmine_silencer do
  name 'Redmine Silencer 3'
  author 'Ready Redmine'
  description 'A Redmine plugin to suppress email notifications (at will) when updating issues or by using a global switch. This is a fork of Silencer 2 by Tobias which was a fork of the original plugin made by @a1exsh!'
  version '0.5.0'
  url 'https://readyredmine.com'
  author_url 'https://readyredmine.com'
  requires_redmine :version_or_higher => '5.0.0'

  permission :suppress_mail_issue_switch, {}
  permission :suppress_mail_global_switch, {}

  settings :default => {
    'silencer_issue_on_default' => false
  }, :partial => 'redmine_silencer_settings'

  global_switch_available = Proc.new do 
    User.current.allowed_to?(:suppress_mail_global_switch, nil, :global => true)
  end

  menu :account_menu, :redmine_silencer, { controller: 'redmine_silencer', action: 'index' }, 
       :first => true, caption: :supress_email_menu_switch_label, html: {id: "redmine_silencer_menu_link"},
       :if => global_switch_available

end

prepare_block = Proc.new do
  Journal.send(:include, RedmineSilencer::JournalPatch)
end

if Rails.env.development?
  ActiveSupport::Reloader.to_prepare { prepare_block.call }
else
  prepare_block.call
end

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib/redmine_silencer"
require 'controller_hooks'
require 'view_hooks'
require 'assets_hooks'
