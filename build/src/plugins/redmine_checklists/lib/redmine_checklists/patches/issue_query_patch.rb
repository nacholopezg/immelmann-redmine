require_dependency 'query'

module RedmineChecklists
  module Patches
    module IssueQueryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        # <PRO>
        base.class_eval do
          unloadable
          alias_method :available_filters_without_checklists, :available_filters
          alias_method :available_filters, :available_filters_with_checklists
        end
        # </PRO>
      end

      module InstanceMethods
        # <PRO>

        def available_filters_with_checklists
          if @available_filters.blank?
            add_available_filter('checklists_status', :type => :list, :name => l(:label_checklist_status),
                                             :values => [[l(:label_checklist_status_done), '1'], [l(:label_checklist_status_undone), '0']]) unless available_filters_without_checklists.key?('checklists_status') && !User.current.allowed_to?(:view_checklists, project, :global => true)

            add_available_filter('checklists_item', :type => :string, :name => l(:label_checklist_item)) unless available_filters_without_checklists.key?('checklists_item') && !User.current.allowed_to?(:view_checklists, project, :global => true)
          else
            available_filters_without_checklists
          end
          @available_filters
        end

        def sql_for_checklists_status_field(_field, operator, value)
          case operator
          when '='
            compare = '='
          when '!'
            compare = '!='
          end

          condition =
            if value.size > 1
              '1=1'
            else
              is_done_val = value.join == '1' ? self.class.connection.quoted_true : self.class.connection.quoted_false
              "is_section = #{self.class.connection.quoted_false} AND is_done #{compare} #{is_done_val}"
            end

          issue_ids = "SELECT DISTINCT(#{Checklist.table_name}.issue_id) FROM #{Checklist.table_name} WHERE #{condition}"
          "(#{Issue.table_name}.id IN (#{issue_ids}))"
        end

        def sql_for_checklists_item_field(_field, operator, value)
          case operator
          when '=', '!'
            condition = "#{Checklist.table_name}.subject = ?"
          when '~', '!~'
            condition = "LOWER(#{Checklist.table_name}.subject) LIKE LOWER(?)"
            value = "%#{value.join}%"
          when '*', '!*'
            condition = '1=1'
          end
          issue_ids = Checklist.where(condition, value).pluck(:issue_id).uniq
          if ['!', '!~'].include?(operator)
            all_issue_ids = Checklist.pluck(:issue_id).uniq
            issue_ids = all_issue_ids - issue_ids
          end
          return '1=0' if issue_ids.empty?
          "(#{Issue.table_name}.id #{'NOT' if operator == '!*'} IN (#{issue_ids.join(',')}))"
        end

        # </PRO>
      end
    end
  end
end

unless IssueQuery.included_modules.include?(RedmineChecklists::Patches::IssueQueryPatch)
  IssueQuery.send(:include, RedmineChecklists::Patches::IssueQueryPatch)
end
