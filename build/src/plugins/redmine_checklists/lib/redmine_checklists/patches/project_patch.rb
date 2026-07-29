require_dependency 'project'

module RedmineChecklists
  module Patches
    module ProjectPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          alias_method :copy_issues_without_checklist, :copy_issues
          alias_method :copy_issues, :copy_issues_with_checklist

          # <PRO>
          has_many :checklist_templates
          # </PRO>
        end
      end

      module InstanceMethods
        # <PRO>
        def default_checklist_template(tracker_id = nil)
          default_templates = checklist_templates.visible.default
          default_by_tracker = default_templates.for_tracker_id(tracker_id).first
          default_by_tracker || default_templates.for_tracker_id(nil).first
        end
        # </PRO>

        def copy_issues_with_checklist(project)
          copy_issues_without_checklist(project)
          issues.each{ |issue| issue.copy_checklists(issue.copied_from)}
        end
      end
    end
  end
end

unless Project.included_modules.include?(RedmineChecklists::Patches::ProjectPatch)
  Project.send(:include, RedmineChecklists::Patches::ProjectPatch)
end
