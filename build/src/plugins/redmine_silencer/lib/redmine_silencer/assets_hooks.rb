module RedmineSilencer
  class AssetsHooks < Redmine::Hook::ViewListener
    include ActionView::Helpers::TagHelper

    def view_layouts_base_html_head(context)
      stylesheet_link_tag(:application, :plugin => 'redmine_silencer')
    end
  end
end

