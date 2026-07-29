module RedmineSilencer
  class ControllerHooks < Redmine::Hook::Listener
    
    def controller_issues_edit_before_save(context)
      update_journal_notify(context[:params], context[:journal])
    end

    def controller_issues_bulk_edit_before_save(context)
      update_journal_notify(context[:params], context[:issue].current_journal)
    end

    def controller_account_success_authentication_after(context)
      context[:user].pref[:silencer_global_on] = false 
      context[:user].pref.save
    end

    private

    def update_journal_notify(params, journal)
      if journal && params && params[:suppress_mail] == '1'
        if (User.current.allowed_to?(:suppress_mail_issue_switch, journal.project) ||
            User.current.allowed_to?(:suppress_mail_global_switch, nil, :global => true))
          journal.notify = false
        else
          # what?
        end
      end
    end
  end
end
