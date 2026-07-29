module RedmineChecklists
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return javascript_include_tag(:checklists, :plugin => 'redmine_checklists') +
          stylesheet_link_tag(:checklists, :plugin => 'redmine_checklists')
      end
    end
  end
end