module RedmineResources
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context = {})
        stylesheet_link_tag(:redmine_resources, plugin: 'redmine_resources')
      end
    end
  end
end
