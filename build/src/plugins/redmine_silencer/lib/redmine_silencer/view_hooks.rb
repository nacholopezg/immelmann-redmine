module RedmineSilencer
  class ViewHooks < Redmine::Hook::ViewListener

    render_on :view_layouts_base_html_head,
      :partial => 'hooks/silencer_modify_header'

    def view_issues_bulk_edit_details_bottom(context={})
      view_issues_edit_notes_bottom(context)
    end

    def view_issues_edit_notes_bottom(context={})
      context[:controller].send(:render_to_string, {
        :partial => 'hooks/silencer_suppress_mail',
        :locals => {context: context, 
          silencer_global_on: User.current.pref[:silencer_global_on], 
          silencer_issue_on_default: Setting.plugin_redmine_silencer['silencer_issue_on_default']}
      })
    end

  end
end
