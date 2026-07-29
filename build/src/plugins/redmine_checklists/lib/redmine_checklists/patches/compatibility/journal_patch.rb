require_dependency 'journal'

module RedmineChecklists
  module Patches
    module JournalPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          # <PRO>
          after_create :send_checklist_notification
          # </PRO>
        end
      end

      module InstanceMethods
        # <PRO>
        def send_checklist_notification
          detail = detail_for_attribute('checklist')
          deliver_checklist_notification if !Setting.notified_events.include?('issue_updated') &&
                                            Setting.notified_events.include?('checklist_updated') &&
                                            detail.present? &&
                                            !JournalChecklistHistory.new(detail.old_value, detail.value).empty_diff?
        end
        # </PRO>

        if Redmine::VERSION.to_s < '2.6'
          def send_notification
            if notify? &&
                (Setting.notified_events.include?('issue_updated') ||
                  (Setting.notified_events.include?('issue_note_added') && notes.present?) ||
                  (Setting.notified_events.include?('issue_status_updated') && new_status.present?) ||
                  (Setting.notified_events.include?('issue_priority_updated') && new_value_for('priority_id').present?)
                )
              deliver_checklist_notification
            end
          end

          def detail_for_attribute(attribute)
            details.detect { |detail| detail.prop_key == attribute }
          end
        end

        def deliver_checklist_notification
          if Redmine::VERSION.to_s >= '4.0'
            (notified_watchers | notified_users).each do |user|
              Mailer.issue_edit(user, self).deliver
            end
          else
            checklist_email_notification(self).deliver
          end
        end

        def checklist_email_notification(journal)
          if Redmine::VERSION.to_s < '2.4'
            Mailer.issue_edit(journal)
          else
            Mailer.issue_edit(journal, journal.notified_users, journal.notified_watchers - journal.notified_users)
          end
        end
      end
    end
  end
end

unless Journal.included_modules.include?(RedmineChecklists::Patches::JournalPatch)
  Journal.send(:include, RedmineChecklists::Patches::JournalPatch)
end
