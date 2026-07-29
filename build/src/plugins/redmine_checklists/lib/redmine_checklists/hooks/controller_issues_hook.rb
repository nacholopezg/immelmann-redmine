module RedmineChecklists
  module Hooks
    class ControllerIssuesHook < Redmine::Hook::ViewListener
      def controller_issues_edit_after_save(context = {})
        # <PRO>
        old_checklists = context[:issue].old_checklists
        new_checklists = context[:issue].checklists.to_json
        journal = context[:journal]
        details = JournalChecklistHistory.new(old_checklists, new_checklists).journal_details
        if JournalChecklistHistory.can_fixup?(details)
          JournalChecklistHistory.fixup(details)
        elsif details.old_value != details.value
          journal.details << details
          journal.save
        else
          journal.save
        end
        # </PRO>

        if (Setting.issue_done_ratio == 'issue_field') && RedmineChecklists.issue_done_ratio?
          Checklist.recalc_issue_done_ratio(context[:issue].id)
        end
      end
    end
  end
end
