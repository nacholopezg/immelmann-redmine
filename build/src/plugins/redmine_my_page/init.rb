require 'redmine'
require 'my_page_patches/my_controller_patch'
require 'my_page_patches/activities_controller_patch'
require 'my_page_patches/user_preference_patch'
require 'my_page_patches/welcome_controller_patch'

def to_prepare(*args, &block)
  if defined? ActiveSupport::Reloader
    ActiveSupport::Reloader.to_prepare(*args, &block)
  else
    ActionDispatch::Callbacks.to_prepare(*args, &block)
  end
end

to_prepare do
  require_dependency 'my_page_patches/redmine_my_page_hook'
end

Rails.application.config.to_prepare do
  require_dependency 'my_controller'
  MyController.prepend(MyPagePatches::MyControllerPatch) unless MyController.included_modules.include?(MyPagePatches::MyControllerPatch)

  require_dependency 'activities_controller'
  ActivitiesController.prepend(MyPagePatches::ActivitiesControllerPatch) unless ActivitiesController.included_modules.include?(MyPagePatches::ActivitiesControllerPatch)

  require_dependency 'welcome_controller'
  WelcomeController.prepend(MyPagePatches::WelcomeControllerPatch) unless WelcomeController.included_modules.include?(MyPagePatches::WelcomeControllerPatch)
end

Redmine::Plugin.register :redmine_my_page do
  name 'My Page Customization'
  author 'Rupesh J'
  description 'Adds additional options to the My Page of users.\nCustom Queries and Activities ( filtered ) will be shown in a single page.'
  version '0.1.13-redmine51'

  requires_redmine :version_or_higher => '5.1'

  settings :default => { 'my_activity_enable' => 0, 'homelink_override' => 1 },
            :partial => 'settings/my_page_option_settings'

  menu :top_menu, :my_landing_page, { controller: 'welcome', action: 'index', force_redirect: 1},
       caption: :label_my_page,
       if: Proc.new{User.current.logged?}
end
