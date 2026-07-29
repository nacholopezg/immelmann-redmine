# Logs plugin for Redmine
# Copyright (C) 2010-2017  Haruyuki Iida
require 'redmine'
require_dependency 'admin_menu_hooks'

Redmine::Plugin.register :redmine_logs do
  name 'Redmine Logs plugin'
  author 'Haruyuki Iida'
  author_url 'http://twitter.com/haru_iida'
  url "http://www.r-labs.org/projects/logs" if respond_to?(:url)
  description 'This is a Logs plugin for Redmine'
  version '0.2.0-redmine51'
  requires_redmine :version_or_higher => '5.1'

  menu :admin_menu, 'icon redmine-logs', { :controller => 'logs', :action => 'index'}, :caption => :logs
end
