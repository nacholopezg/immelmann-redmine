require_dependency 'issue'

module RedmineChecklists
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          attr_accessor :old_checklists
          attr_accessor :removed_checklist_ids
          attr_reader :copied_from

          alias_method :copy_without_checklist, :copy
          alias_method :copy, :copy_with_checklist
          after_save :copy_subtask_checklists

          if ActiveRecord::VERSION::MAJOR >= 4
            has_many :checklists, lambda { order("#{Checklist.table_name}.position") }, :class_name => 'Checklist', :dependent => :destroy, :inverse_of => :issue
          else
            has_many :checklists, :class_name => 'Checklist', :dependent => :destroy, :inverse_of => :issue, :order => 'position'
          end

          accepts_nested_attributes_for :checklists, :allow_destroy => true, :reject_if => proc { |attrs| attrs['subject'].blank? }

          validate :block_issue_closing_if_checklists_unclosed

          safe_attributes 'checklists_attributes',
            :if => lambda { |issue, user| (user.allowed_to?(:done_checklists, issue.project) || user.allowed_to?(:edit_checklists, issue.project)) }
        end
      end

      module InstanceMethods
        def copy_checklists(arg)
          issue = arg.is_a?(Issue) ? arg : Issue.visible.find(arg)
          if issue
            issue.checklists.each do |checklist|
              Checklist.create(checklist.attributes.except('id', 'issue_id').merge(issue: self))
            end
          end
        end

        def copy_subtask_checklists
          return if !copy? || parent_id.nil? || checklists.any?
          copy_checklists(@copied_from)
        end

        def copy_with_checklist(attributes = nil, copy_options = {})
          copy = copy_without_checklist(attributes, copy_options)
          copy.copy_checklists(self)
          copy
        end

        def all_checklist_items_is_done?
          (checklists - checklists.where(id: removed_checklist_ids)).reject(&:is_section).all?(&:is_done)
        end

        def need_to_block_issue_closing?
          RedmineChecklists.block_issue_closing? &&
            checklists.reject(&:is_section).any? &&
            status.is_closed? &&
            !all_checklist_items_is_done?
        end

        def block_issue_closing_if_checklists_unclosed
          if need_to_block_issue_closing?
            errors.add(:checklists, l(:label_checklists_must_be_completed))
          end
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineChecklists::Patches::IssuePatch)
  Issue.send(:include, RedmineChecklists::Patches::IssuePatch)
end
