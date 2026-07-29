module RedmineQuestions
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return stylesheet_link_tag(:redmine_questions, :plugin => 'redmine_questions')
      end
    end
  end
end