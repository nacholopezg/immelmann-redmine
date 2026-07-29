require_dependency 'queries_helper'

module RedmineQuestions
  module Patches
    module ProjectsHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method :project_settings_tabs_without_questions, :project_settings_tabs
          alias_method :project_settings_tabs, :project_settings_tabs_with_questions
        end
      end

      module InstanceMethods
        # include ContactsHelper

        def project_settings_tabs_with_questions
          tabs = project_settings_tabs_without_questions

          tabs.push({ :name => 'questions',
            :action => :manage_sections,
            :partial => 'projects/questions_settings',
            :label => :label_questions }) if User.current.allowed_to?(:manage_sections, @project)
          tabs

        end
      end

    end
  end
end

unless ProjectsHelper.included_modules.include?(RedmineQuestions::Patches::ProjectsHelperPatch)
  ProjectsHelper.send(:include, RedmineQuestions::Patches::ProjectsHelperPatch)
end
