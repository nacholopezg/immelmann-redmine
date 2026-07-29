module RedmineChecklists
  module Patches

    module IssuesControllerPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          alias_method :build_new_issue_from_params_without_checklist, :build_new_issue_from_params
          alias_method :build_new_issue_from_params, :build_new_issue_from_params_with_checklist
          before_action :save_before_state, :only => [:update]
        end
      end

      module InstanceMethods
        def build_new_issue_from_params_with_checklist
          if params[:id].blank?
            if params[:copy_from].blank?
              # <PRO>
              fill_default_checklist
              # </PRO>
            else
              fill_checklist_attributes
            end
          end
          build_new_issue_from_params_without_checklist
        end

        def save_before_state
          @issue.old_checklists = @issue.checklists.to_json
          checklists_params = params[:issue].present? && params[:issue][:checklists_attributes].present? ? params[:issue][:checklists_attributes] : {}
          @issue.removed_checklist_ids =
            if checklists_params.present?
              checklists_params = checklists_params.respond_to?(:to_unsafe_hash) ? checklists_params.to_unsafe_hash : checklists_params
              checklists_params.map { |_k, v| v['id'].to_i if ['1', 'true'].include?(v['_destroy']) }.compact
            else
              []
            end
        end

        def fill_checklist_attributes
          return unless params[:issue].blank?
          begin
            @copy_from = Issue.visible.find(params[:copy_from])
            add_checklists_to_params(@copy_from.checklists)
          rescue ActiveRecord::RecordNotFound
            render_404
            return
          end
        end

        # <PRO>
        def fill_default_checklist
          return if custom_checklists_included?(params[:issue])
          params[:issue] ||= {}
          tracker_id = params[:issue].try(:[], :tracker_id) || issue_project.trackers.first.try(:id)
          default_template = issue_project.default_checklist_template(tracker_id)
          return params[:issue][:checklists_attributes] = {} if default_template.nil?
          params[:issue][:checklist_template_id] = default_template.id
          add_checklists_to_params(default_template.checklists)
        end
        # </PRO>

        def add_checklists_to_params(checklists)
          params[:issue].blank? ? params[:issue] = { :checklists_attributes => {} } : params[:issue][:checklists_attributes] = {}
          checklists.each_with_index do |checklist_item, index|
            params[:issue][:checklists_attributes][index.to_s] = {
              is_done: checklist_item.is_done,
              subject: checklist_item.subject,
              position: checklist_item.position,
              is_section: checklist_item.is_section
            }
          end
        end

        # <PRO>
        def custom_checklists_included?(issue_attr)
          return if issue_attr.blank? || issue_attr[:checklists_attributes].blank? || checklist_subjects(issue_attr[:checklists_attributes]).empty?
          default_template = issue_project.checklist_templates.visible.where(:id => issue_attr[:checklist_template_id]).first
          return true unless default_template
          checklist_subjects(issue_attr[:checklists_attributes]) != default_template.checklists.map(&:subject)
        end

        def checklist_subjects(attrs)
          if attrs.is_a?(Array) # JSON/XML
            attrs.map { |checklist_attr| checklist_attr[:subject] }.compact
          else
            attrs = attrs.permit!.to_h if Rails::VERSION::MAJOR >= 5
            attrs.map { |_k, v| v[:subject] if v[:subject].present? }.compact
          end
        end

        def issue_project
          @project || Project.where(:id => Issue.new.allowed_target_projects.map(&:id)).order(:id).first
        end
        # </PRO>
      end
    end
  end
end

unless IssuesController.included_modules.include?(RedmineChecklists::Patches::IssuesControllerPatch)
  IssuesController.send(:include, RedmineChecklists::Patches::IssuesControllerPatch)
end
