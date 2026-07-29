require 'redmine_my_page_paginations/patches/user_preference_patch'
require 'redmine_my_page_paginations/patches/my_helper_patch'

Rails.application.config.to_prepare do
  require_dependency 'user_preference'
  UserPreference.prepend(RedmineMyPagePaginationLinks::Patches::UserPreferencePatch) unless UserPreference.included_modules.include?(RedmineMyPagePaginationLinks::Patches::UserPreferencePatch)

  require_dependency 'my_helper'
  MyHelper.prepend(RedmineMyPagePaginationLinks::Patches::MyHelperPatch) unless MyHelper.included_modules.include?(RedmineMyPagePaginationLinks::Patches::MyHelperPatch)
end
