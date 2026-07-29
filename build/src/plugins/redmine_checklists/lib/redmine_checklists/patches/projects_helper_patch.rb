# <PRO>
module RedmineChecklists
  module Patches
    module ProjectsHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          alias_method :project_settings_tabs_without_checklists, :project_settings_tabs
          alias_method :project_settings_tabs, :project_settings_tabs_with_checklists
        end
      end

      module InstanceMethods
        def project_settings_tabs_with_checklists
          tabs = project_settings_tabs_without_checklists
          tab = { :name => 'checklist_template',
                  :action => :manage_checklist_templates,
                  :partial => 'projects/settings/checklist_templates',
                  :label => :label_checklist_templates }
          tabs << tab if User.current.allowed_to?(:edit_issues, @project) && User.current.allowed_to?(tab[:action], @project)
          tabs
        end
      end
    end
  end
end

unless ProjectsHelper.included_modules.include?(RedmineChecklists::Patches::ProjectsHelperPatch)
  ProjectsHelper.send(:include, RedmineChecklists::Patches::ProjectsHelperPatch)
end
# </PRO>
