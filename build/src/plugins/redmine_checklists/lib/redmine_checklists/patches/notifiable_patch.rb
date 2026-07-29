# <PRO>
module RedmineChecklists
  module Patches
    module NotifiablePatch
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          unloadable
          class << self
            alias_method :all_without_checklists, :all
            alias_method :all, :all_with_checklists
          end
        end
      end

      module ClassMethods
        def all_with_checklists
          notifications = all_without_checklists
          last_issue_child_index = notifications.find_index(notifications.select{ |element| element.parent == 'issue_updated' }.last)
          notifications.insert(last_issue_child_index + 1, Redmine::Notifiable.new('checklist_updated', 'issue_updated'))
          notifications
        end
      end
    end
  end
end

unless Redmine::Notifiable.included_modules.include?(RedmineChecklists::Patches::NotifiablePatch)
  Redmine::Notifiable.send(:include, RedmineChecklists::Patches::NotifiablePatch)
end
# </PRO>
